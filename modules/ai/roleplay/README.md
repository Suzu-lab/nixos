# Local roleplay stack — SillyTavern + dedicated llama-swap

Containerized RP frontend replacing SpicyChat. A **separate** compose project from the companion
and imagegen stacks — it shares only the host baseline (Docker, amdgpu firmware, `/dev/dri`) and the
AI NVMe. The companion is never touched. Full design rationale: `~/Projects/local-rp-stack-build-guide.md`.

**Architecture note (differs from that guide):** the guide's Phase 1 assumes one llama-swap with
native `groups` for companion↔RP *coexistence*. We don't coexist — during RP the companion is
**killed** to free RAM/CPU for the 106B. So RP runs its **own** llama-swap instance (host `:8081`),
which only ever holds one model at a time (llama-swap's default eviction — no `groups` needed). GPU
sharing is by discipline: `rp-on`/`rp-off` are the only two VRAM handoffs.

```
Phone/Desktop ─ Tailscale ─▶ SillyTavern :8000 ─(project net)─▶ llama-swap :8081 ─▶ RP model
                                                                 (companion :8080 is unloaded)
```

Repo holds the definitions (`docker-compose.yml`, `llama-swap-rp.yaml`, `rp-on.sh`, `rp-off.sh`);
big/user data lives on the NVMe under `~/ai-models/` (`models/rp/`, `roleplay/sillytavern/`).

## What the NixOS module does (`modules/ai/roleplay-host.nix`)

`nixos-rebuild switch` creates the NVMe data dirs, installs `rp-on`/`rp-off`, enables the Tailscale
daemon, and opens `:8000`/`:8081` on `tailscale0` only. It does **not** start containers or connect
Tailscale — those stay imperative (below).

## Bring-up

```bash
# 1. Download models into ~/ai-models/models/rp/  (paths must match llama-swap-rp.yaml)
huggingface-cli download bartowski/TheDrummer_Cydonia-24B-v4.3-GGUF \
  --include "*IQ4_XS*" --local-dir ~/ai-models/models/rp
#   Mag-Mell 12B Q6_K (inflatebot/MN-12B-Mag-Mell-R1) and GLM-Steam-106B-A12B Q4_K_M
#   (TheDrummer/GLM-Steam-106B-A12B, multi-part — hf-cli handles the split) similarly. ~100 GB total.

# 2. Start the stack
docker compose -f ~/nixos/modules/ai/roleplay/docker-compose.yml up -d

# 3. First run populates SillyTavern's config; edit it, then restart ST
#    ~/ai-models/roleplay/sillytavern/config/config.yaml:
#      listen: true      basicAuthMode: true      whitelistMode: false
#      basicAuthUser: { username: suzu, password: "<long-random>" }
docker compose -f ~/nixos/modules/ai/roleplay/docker-compose.yml restart sillytavern

# 4. Phone access (one-time)
sudo tailscale up
```

## Connect SillyTavern to the backend

API Connections → **Text Completion** → **Generic (OpenAI-compatible)** → URL
`http://llama-swap:8080` (append `/v1` if it fails). The model dropdown populates from the RP
instance; save one Connection Profile per model. Templates/samplers per model: guide §7.2–7.3.
Memory system (Summarize + Vector Storage + STMB): guide §8.

## Daily use — the handoff

Bind to OpenDeck next to the gaming toggle. These are the **only** two moments VRAM changes hands:

- `rp-on` — kills the companion's model (repoints her config → CPU, restarts her llama-swap, no
  warm-up) so the GPU **and** her RAM are free for the RP model. OLV stays alive; her session is in
  the chat log, not the process. Stray OLV calls during RP lazy-load her text model to RAM only.
- `rp-off` — drops the RP model, then `companion-ctl gpu-back` brings her back on the GPU with
  vision, warmed.

## Endpoints

| Action | Call |
|---|---|
| SillyTavern | `:8000` |
| RP llama-swap dashboard | `:8081/ui` |
| What's loaded (RP) | `GET :8081/running` |
| Unload RP model | `POST :8081/api/models/unload` |
| Companion llama-swap (separate) | `:8080` — untouched by this stack |

## Version pins

After first pull, pin `ghcr.io/sillytavern/sillytavern:latest` → a release tag in
`docker-compose.yml` (don't track `latest` past day one). Record the STMB extension commit and the
model quants per guide §11. `llama-swap:vulkan` and llama.cpp build are shared with the companion.
