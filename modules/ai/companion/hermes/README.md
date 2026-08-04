# Reika on Hermes — one harness (Plan B)

Consolidates the companion onto a **single brain**: **Hermes Agent as the headless backend**
(model + memory + tools + skills + learning), driving the **existing Electron/VRM client**
(`../client/`) as its face. One Reika — voice, avatar, *and* agentic power — no two-harness split.

This folder is the live, GitHub-backed config (big data on the NVMe). **Nothing here is test-run
yet** — scaffolded while Suzu was away; values marked *VERIFY* are first-run checkpoints
(`hermes doctor` + the setup wizards are the source of truth).

## Architecture

```
  ┌─ client/ (Electron) ──────────────┐        ┌─ Hermes (headless) ─────────────┐
  │  avatar window (three-vrm)        │  HTTP  │  hermes gateway  :8642          │
  │  prompt window                    │  +SSE  │   ├ agent loop + skills         │
  │  main.js  ── transport ───────────┼───────►│   ├ mem0 (memory)               │
  │  control server :12395 (niri)     │◄───────┤   └ tools (web, files, …)       │
  │  VAD ─ STT svc ─ TTS svc (voice)  │        └─────────────┬───────────────────┘
  └───────────────────────────────────┘                     │ OpenAI /v1
                                                     llama-swap → Qwen3.6-35B-A3B (VL)
```

- **Brain = Hermes API server.** `hermes gateway`, `127.0.0.1:8642`, Bearer `API_SERVER_KEY`.
  Client talks to `POST /api/sessions/{id}/chat/stream` → SSE `assistant.delta` (text for
  subtitles + TTS), `tool.started`/`tool.completed` (drive expressions), `run.completed`.
  Session via `X-Hermes-Session-Id`/`X-Hermes-Session-Key`. Inline `data:image/...` → screen-vision
  still works. `POST /v1/runs/{id}/approval` → Reika confirms before destructive actions.
- **Voice = client-side** (the API server is **text+images only**). The client owns VAD
  (Web Audio RMS) + a **STT** service (faster-whisper, OpenAI-compatible `/v1/audio/transcriptions`)
  + a **TTS** service (Kokoro today / **Fish-Speech self-hosted** — the planned migration; both
  OpenAI-compatible `/v1/audio/speech`). Hermes only ever sees/returns text.
- **Model** = one multimodal `chat` in llama-swap: **Qwen3.6-35B-A3B abliterated (VL)** — vision +
  agentic + 262k ctx (clears Hermes' 64k min) + A3B speed. (See phase 1.)
- **Memory** = **mem0 OSS** (Qdrant + local embeddings), replacing the handmade SQLite store.

## Why this shape

- **One harness** — Suzu didn't want two Reikas with different capabilities. Hermes' API server
  makes it a real backend, so the client (already built by us, all transport centralized in
  `main.js`) just repoints at it.
- **Voice client-side is a feature, not a tax** — the client is ours and the TTS was moving to Fish
  local anyway; owning the loop means full control over latency + the Fish switch.
- **tui_gateway (JSON-RPC/WS) exists** for the richest interactive features (slash commands, session
  branching) but couples us to a first-party protocol. We take the documented API server instead.

## Files here

| File | What it is |
|---|---|
| `SOUL.md` | Reika's identity for Hermes (system-prompt slot #1). Speakable-lean + `[emotion]` tags (avatar is the primary face); may run long when actually working a task. |
| `config.yaml` | Hermes non-secret config → `/root/.hermes/config.yaml`. `provider: custom` → llama-swap; API server on. |
| `mem0.json` | mem0 OSS (LLM=llama-swap, embedder=embeddings svc, store=qdrant). *VERIFY schema.* |
| `Dockerfile` | Builds `hermes-agent:local`. Shakiest file — Hermes is host-install by design. |
| `compose.hermes.yaml` | Overlay: `qdrant` + `embeddings` + `hermes` (runs `hermes gateway`). |
| `mem0-migrate.py` | One-shot: handmade SQLite facts → mem0, before retiring the old store. |

## Bring-up (in order, at home, where you can test)

**Phase 1 — model swap** *(independent, upgrades the current OLV companion too)*
1. Download a `Qwen3.6-35B-A3B` abliterated GGUF **+ its mmproj** to `~/ai-models/models/`.
2. Point `../llama-swap.yaml` `chat` at the new files; keep `--n-cpu-moe` (tune for 35B), bump
   `-c` toward 64k, keep `-fa on -ctk q8_0 -ctv q8_0`. Restart llama-swap; confirm vision still works.

**Phase 2 — Hermes backend + mem0**
3. `docker compose -f ../docker-compose.yml -f compose.hermes.yaml up -d` (hermes + qdrant + embeddings).
4. Set secrets: `hermes config set CUSTOM_API_KEY local`; set `API_SERVER_KEY` (a real token) in
   `~/.hermes/.env` (or via sops). `hermes doctor` → reconcile every *VERIFY* note; run
   `hermes memory setup mem0 --mode oss --oss-llm openai` and diff the generated `mem0.json`.
5. Smoke-test the API: `curl -N -H "Authorization: Bearer $KEY" .../api/sessions/test/chat/stream`
   with a text turn; confirm SSE deltas + that she uses the local model, mem0, and can make a skill.

**Phase 3 — the client transport rewrite** *(the real coding — see `main.js` map below)*
6. Rewrite `../client/main.js`'s transport: replace the OLV WebSocket with the Hermes API-server
   SSE client; add client-side VAD + STT-service + TTS-service orchestration. Keep `avatar.js`,
   `prompt.js`, the IPC, the `:12395` control server, and screen-capture untouched.
7. Stand up the voice services (STT faster-whisper; TTS Kokoro now, Fish-Speech when migrating) as
   OpenAI-compatible endpoints on the companion network; wire the client at them.

**Phase 4 — migrate memory, retire the handmade store** *(after Phase 2 verified)*
8. `pip install mem0ai`; `MEMORY_DB=~/ai-models/memory/memory.db python3 mem0-migrate.py`; verify.
9. Retire `memory_mcp.py` + `consolidate.py` + `memory.db` (keep a backup).

## `main.js` transport map (Phase 3 detail)

Replace, don't rebuild — the client already centralizes the backend in `main.js`.

| Current (OLV, one WS `:12393/client-ws`) | Plan B (Hermes API `:8642`) |
|---|---|
| `connectWS()` / `ws.on("message", route)` | SSE reader on `/api/sessions/{id}/chat/stream` (Bearer) |
| send `{type:"text-input", text, images}` | POST turn (text + `data:image/...`) to the session stream |
| recv `{type:"audio", display_text}` | recv `assistant.delta` → subtitles + feed text to TTS svc |
| recv `{type:"user-input-transcription"}` | client did the STT itself → log it locally |
| recv `{type:"control","mic-audio-end"}` (server VAD) | client-side VAD emits the utterance boundary |
| send `{type:"interrupt-signal"}` | `POST /v1/runs/{id}/stop` |
| `[emotion]` tag inline in text | same (parse from `assistant.delta`); + `tool.*` → "working" states |

## Open questions / risks

- **Hermes config schema / API paths** — public docs are decent but thin; `hermes doctor` + a curl
  smoke test are ground truth. *VERIFY* markers flag where reality may differ.
- **Voice latency** — you re-earn OLV's tuned "first-comma TTS" feel on the new client loop. Expect
  iteration; client-side VAD + a snappy local STT + streaming TTS is the target.
- **Containerizing Hermes** — host-install by design; if Docker fights us, fall back to a host
  install with the API server bound on the tailnet/localhost.
- **Abliteration vs tool reliability** — if the abliterated 3.6-35B is flaky on the agent loop, use
  a non-abliterated 3.6-35B for the brain (uncensored only matters for persona, not tool-calling).
