# Reika on Hermes — build log

Gate record for the build described in `reika-hermes-spec.md` (v1). One section per gate: the
checks run, the command output that proves them, and pass/fail. Nothing here is a plan — the spec
owns the plan, this file owns the evidence.

---

## Phase 0 — Inventory and questions

**Date:** 2026-11-08
**Status:** all questions answered; **Gate 0 pending [APPROVAL] only.**

### Pinned revision under verification

| Thing | Pin | How checked |
|---|---|---|
| Hermes Agent | `5d3723e1172ed3b86eb57f456b1b7b7543e33ef5` (2026-11-08) | `git clone --depth 1`, read-only, outside the repo |
| Repo nixpkgs | `e554fab72f` (2026-09-17), NixOS 26.11.20260917 | `flake.lock`, `nixos-version` |
| Noctalia | `noctalia-5.1.0` (flake input `960d4d46bd`, 2026-09-18) | `readlink -f $(which noctalia)` |

Every **VERIFY** below was checked against that Hermes revision's source, not against web docs.

### VERIFY results — claims confirmed

| Spec claim | Result | Evidence |
|---|---|---|
| Hermes rejects context windows below 64,000 at startup | **CONFIRMED** — hard `raise ValueError` | `MINIMUM_CONTEXT_LENGTH = 64_000` (`agent/model_metadata.py:277`); `_enforce_minimum_context` raises (`agent/agent_init.py:1905-1944`). For a local endpoint the window is the server's `-c`, so today's `-c 32768` means Hermes will not boot. |
| Pet atlas: 1536×1872, 8×9, cells 192×208, 6 frames, 1100 ms, row order | **CONFIRMED exactly** | `agent/pet/constants.py`: `FRAME_W=192`, `FRAME_H=208`, `FRAMES_PER_STATE=6`, `LOOP_MS=1100`, `CODEX_STATE_ROWS` = idle, running-right, running-left, waving, jumping, failed, waiting, running, review. |
| Pet install = manifest + spritesheet | **CONFIRMED** | `agent/pet/store.py`: a dir under `pets_dir()` holding `pet.json` (`id`, `displayName`, `description`, `spritesheetPath`) + `spritesheet.webp`/`.png`. |
| `container.enable` pulls `ubuntu:24.04` at runtime | **CONFIRMED** | `nix/nixosModules.nix`: `container.image` default `"ubuntu:24.04"`, "pulls this at runtime via Docker/Podman". |
| Defaults of `user` / `createUser` | **CONFIRMED, and already what the spec wants** | `user` = `group` = `"hermes"`, `createUser` = `true`, `stateDir` = `/var/lib/hermes`. A dedicated service user needs no extra config. |
| The `docker` terminal backend skips dangerous-command checks | **CONFIRMED** | `tools/approval.py:1124` — "True when the backend is isolated enough to skip dangerous-command prompts. Docker is the…"; `tools/approval_detection.py:90` — "containerized backends already bypass the dangerous-command layer". |
| Plugin hooks `pre_tool_call` / `post_tool_call` / `transform_tool_result` / `pre_llm_call` exist | **CONFIRMED** | `agent/agent_runtime_helpers.py:2457` (`_dispatch_pre_tool_call_hooks`), `:2480` (`apply_transform_tool_result`, `emit_terminal_post_tool_call`), `agent/context_engine.py:132` (`pre_llm_call`), `agent/turn_finalizer.py:595`. Manifest format is `plugin.yaml` (e.g. `plugins/security-guidance/plugin.yaml`). |
| `gateway.platforms.api_server.model_routes` | **CONFIRMED** | `gateway/platforms/api_server.py:1785` `_parse_model_routes`: alias → `{model, provider?, api_key?, base_url?}`. `/v1/models` lists aliases (`:2317`); runs report `route_source: "model_routes"` (`:1872`). |
| Noctalia 5.x is native, not Quickshell | **CONFIRMED** | `noctalia-5.1.0/bin/.noctalia-wrapped` is an ELF linking `libGLESv2.so.2`; no Qt, no Quickshell in its closure. The "Quickshell based" comment in `flake.nix` is stale. |

**Not yet verified, deferred to its own phase:** whether `pre_tool_call` hooks still fire under the
`docker` terminal backend (dispatch sits in the tool-call path *above* the backend, so they should —
to be *proved* in Phase 3, not assumed); llama-swap's residency mechanism at its pinned version
(Phase 1); Hermes' skill format (Phase 6); desktop-app placement under Niri (Phase 5).

### VERIFY results — findings that change the spec

1. **The Electron desktop app is not in the NixOS module.** `nix/nixosModules.nix` contains zero
   occurrences of "desktop". The app ships only as `programs.hermes-agent.desktop.enable` in
   `nix/homeManagerModules.nix`. That module's own header argues user-level is the correct shape:
   *"Hermes is an agent for one person. The credentials, the memory, the sessions and the cron jobs
   all belong to that person."* The app reaches a service backend through
   `backend.mode = "serve"` (`/api/ws` + `/api/pty`, port 9119 default) authorized by
   `backend.sessionTokenFile`. In native NixOS mode state lives in `/var/lib/hermes/.hermes` owned
   by `hermes`; the only state-sharing bridge (`container.hostUsers`) exists **only in container
   mode**, with `addToSystemPackages` (group-writable `0660` config) as the native alternative.

2. **64,000 is a floor to clear, not a target to hit.** `ContextCompressor._compute_threshold_tokens`
   (`agent/context_compressor.py:2765-2798`) floors the compaction trigger at
   `MINIMUM_CONTEXT_LENGTH`; at a 65,536 window that floor exceeds the window, so it is capped at
   85% of the effective input budget instead. A model run at exactly 64k therefore auto-compacts
   almost continuously. Separately, the auxiliary compression model must clear 64k *independently*
   (`agent/conversation_compression.py:2089-2096`). Since compression follows the active model (see the
   plan diff), that makes ≥64k a hard requirement on `fast`, not a preference.

3. **mem0 is no longer in-tree.** `CONTRIBUTING.md:72` — the built-in provider set under
   `plugins/memory/` is **closed** at `byterover` + `retaindb`; mem0, honcho, supermemory,
   openviking, hindsight and holographic now ship from the plugin catalog. Hermes' built-in memory
   is plain **`MEMORY.md` / `USER.md`**, and external providers are purely additive
   (`website/docs/user-guide/features/memory-providers.md:30-43`).

4. **Pet Plan A is 3× the stock size.** `DEFAULT_SCALE = 0.33`, bounds `0.1`–`3.0`
   (`agent/pet/constants.py`). Running at `display.pet.scale: 1.0` for pixel-exactness means a
   192×208 px sprite on screen. Plan B (opt-in pixelated mode) is more likely to be needed than the
   spec assumes.

### Measured state of the machine

| Measure | Value | Command |
|---|---|---|
| Total VRAM | 16,304 MiB | `/sys/class/drm/card1/device/mem_info_vram_total` = 17095983104 B; `dmesg`: "Detected VRAM RAM=16304M" |
| VRAM used at idle, **no model loaded** | 4,268 MiB | `mem_info_vram_used`, with `/v1/models` showing `chat` registered but unloaded |
| **VRAM actually available to AI** | **~12 GB** | the two above |
| GPU | AMD `1002:7550` (Navi 48, RDNA4), 1 card | `/sys/class/drm/card1/device/{vendor,device}` |
| Long-term memory store | **3 facts** (2 `fact`, 1 `name`), last write 2026-07-05 | `sqlite3 memories` count on `~/ai-models/memory/memory.db` |
| OLV stack | **running, untouched** — 7 containers: `companion-{olv,llama-swap,searxng,kokoro}`, `roleplay-{sillytavern,llama-swap}`, `spotdl-webui` | `docker ps` |
| Current `chat` model window | `-c 32768` — **below the Hermes floor** | `modules/ai/companion/llama-swap.yaml` |

Two caveats on these numbers, both from Suzu at the Phase 0 review:

- The 4,268 MiB was measured with a game and several video-playing browser windows open, so it is a
  **pessimistic** figure, not an idle floor. Phase 1 records both a quiesced and a busy-desktop number.
- The "~12 GB available" line is not a pool to be divided. Under answer 1b only one model is resident
  at a time, so each is sized against what the desktop leaves free on its own. `yosai` is a
  workstation that must stay usable; that constraint is the reason for a small model in the first
  place, and when `deep` is needed Suzu downsizes what else is running.

### Follow-up VERIFY — the desktop app and the pet (asked at Phase 0 review)

Suzu asked whether the Hermes desktop app is "mostly a chat window", whether our own Electron client
could serve instead, and whether the app can be used without Home Manager.

**The app is not mostly a chat window.** `website/docs/user-guide/desktop.md` §"What's in the app"
lists, beyond chat: file browser, artifacts, windows/tabs/panes, terminal, live subagents, git review
and worktrees, memory graph, quick entry, voice, HUD mode, management panes, bot mode, sessions and
profiles, remote-backend connection, and a desktop plugin SDK. The **model picker is in the composer**
(`:283`), which is the Phase 2 requirement.

**The pet's desktop features already cover Suzu's wishlist** (`website/docs/user-guide/features/pets.md`):

| Wanted | Hermes already has it |
|---|---|
| Idle animation | `idle` state, plus a **Roam** toggle — the pet wanders the window while the agent is at rest |
| Thinking / working animation | `review` while the model thinks, `run` while a tool executes; the popped-out pet shows a speech bubble (`working…`, `thinking…`, `your turn`) |
| Mouse-click interaction | **Pop-out overlay** (shift-click) is a transparent always-on-top desktop window with per-pixel click-through: **drag** to anywhere on screen (position persists), **single-click** opens a mini composer that sends a prompt to the latest session, **double-click** toggles the app window, **Alt+wheel** resizes, mail icon on a turn finished while away |
| — (bonus) | **Vibe reactions**: affection or thanks aimed at the agent ("good bot", `<3`) makes the pet emit hearts; locally matched lexicon, no model call |

Two honest limits: the 7 states are driven by **agent activity, not mood** — there is no talking or
emotion state and no lip-sync, so the rig's mouth states differentiate working/thinking/waiting rather
than speech; and the click gestures are **fixed by the app**, not declared per-pet, so they cannot be
customised from the atlas.

**The pet overlay exists only in the desktop app.** Without it the pet renders only inside a terminal
(kitty/Ghostty/WezTerm/iTerm2/sixel, else truecolor half-blocks). Our own client would have to
reimplement the overlay, roaming, drag, mini composer, model picker and approvals UI from scratch.

**The desktop app does not need Home Manager.** Confirmed: the flake exposes
`packages.<system>.desktop` (`nix/packages.nix:100`), and `nix/desktop.nix` takes `extraEnv` /
`extraRun` as package arguments. The HM module is only a thin wrapper
(`nix/homeManagerModules.nix:74-125`) that sets four things:

- `HERMES_HOME` — the state dir, because a GUI launcher reads no shell profile;
- `HERMES_MANAGED` — makes the CLI refuse config edits and name the rebuild command;
- `HERMES_DESKTOP_REMOTE_URL = http://<backend.host>:<backend.port>`;
- `HERMES_DESKTOP_REMOTE_TOKEN` — read from `backend.sessionTokenFile` **at start time** via
  `extraRun`, never `--set`, because `makeWrapper` writes a `--set` value into the world-readable store.

The two remote variables travel together or the resolver throws. All of it is reproducible in a NixOS
module with `environment.systemPackages = [ (desktop.override { extraEnv; extraRun; }) ]`.

**Wayland / Niri placement (early read, to be proved in Phase 5/6).** The app launches with
`--ozone-platform=wayland` on a Wayland session, and "drag, click-through, and resize work on the
native Wayland path". But HUD mode is explicitly degraded on Wayland: tap-to-summon is unavailable,
snap-to-pointer is a no-op, and the compositor owns placement. Hyprland gets special-cased by
floating and pinning the HUD over its IPC; **Niri is not handled**, so the HUD will likely be tiled
and `always-on-top` ignored without our own Niri window rules. `desktop.ozone_platform_hint: x11` is
the escape hatch, at the cost of click-through.

### Phase 0 answers

| # | Question | Answer |
|---|---|---|
| 1 | Fast-model VRAM budget; gaming-mode behaviour | **Measure first**, and the budget question is largely dissolved by answer 1b below: only one model is resident at a time, so each gets the headroom the desktop is not using. The 16 GB is shared with daily desktop use by design; `yosai` is a workstation, not an AI host. When `deep` is needed, Suzu downsizes what else is running. |
| 1b | **Do `fast` and `deep` coexist in VRAM?** (raised by Suzu, not in spec v1) | **No.** Loading `deep` must unload `fast`. There is no value in holding both. This **reverses** the spec's Residency section and Gate 2. |
| 2 | Memory backend; migrate the SQLite facts? | **Built-in `MEMORY.md` / `USER.md` now, external provider later.** Built-in writes mirror to an external provider if one is added, so switching loses nothing. The 3 existing facts are hand-carried; no migration script. |
| 3 | Persona — reuse `SOUL.md`? | **Keep it, minus anything that fights Hermes.** Drop the `[emotion]` bracket tags (nothing parses them; the pet is driven by agent activity) and the "speakable prose, no markdown, no lists" rule (it fights an agent that must return `<result>` blocks and diffs). Character, voice and boundaries stay. Further persona tuning is a later pass, once the thing runs. |
| 4 | Messaging platforms to enable | **None.** Revisited only after everything else works. |
| 5 | Hermes placement | **Native NixOS service + `hermes` service user.** |
| 5a | Desktop app vs. our own Electron client | **Hermes desktop app**, wired through a NixOS module with no Home Manager (see the follow-up VERIFY above). Our client cannot provide the pet overlay without reimplementing it. |
| 5b | Host folders the service user may read/write | **Her own workspace only.** Everything else is whitelisted by Suzu per folder, read or write, on an as-needed basis. No standing `~/nixos` access, not even read. |
| 6 | Kitsune — tails, palette, outfit, references | **No VRM features carry over**; Suzu will generate a reference image to a spec Claude provides. Wanted behaviour — idle animation, thinking/working animation, click interaction — is **already delivered by the pet overlay** (table above). Tail count and palette are deferred to Phase 5 steps 1–2, where they are chosen against concepts rather than in the abstract. |
| meta | Who edits `~/nixos` | **Standing no-edit rule suspended for this build only.** Claude edits the Reika/Hermes work directly, small changes, one concern each; Suzu reviews diffs and makes his own commits. Everything outside this build stays hands-off. |
| meta | nixpkgs currency | The generation has not been updated in a while. Suzu will update it, and Hermes-vs-nixpkgs conflicts get checked **then**, not now. Phase 2 pins Hermes without `nixpkgs.follows` regardless. |

### Plan diff against spec v1

Nothing below is built yet.

**Phase 1 — Two models in llama-swap**
- **The Residency section is reversed** (answer 1b). The spec requires "the fast model must stay loaded
  while deep loads and unloads"; the actual requirement is the opposite — loading `deep` unloads
  `fast`. This is llama-swap's *default* behaviour (one model at a time, swapped on the request's
  `model` field), so the work shrinks: no groups, no non-swapping members, no persistent-member
  syntax to get right. Phase 1 must still **prove** it, because `ttl: 0` is currently set on `chat`
  and the interaction between "never auto-unload on idle" and "evict on an explicit request for
  another model" is exactly the kind of thing that should be tested, not assumed.
- **VRAM budgeting is no longer a split.** Each model is sized against what the desktop leaves free
  while it is the only one loaded. Gate 1 still measures llama.cpp's reported KV size per candidate at
  **64k / 96k / 128k**, but now to find each model's own ceiling rather than to divide a pool.
- The ≥64k requirement on `fast` stands and gets firmer — see the Phase 2 note on compression below.
- Re-measure the idle VRAM baseline. The 4,268 MiB recorded above was taken with a game and several
  video-playing browser windows open, so it is a pessimistic figure. Record **both** a quiesced and a
  busy-desktop number; both are real operating conditions.

**Phase 2 — Hermes up, declaratively**
- **"Route compression and titling to fast" is dropped.** Under answer 1b that instruction causes
  llama-swap thrash: a `deep` session whose compression calls `fast` would unload and reload a 30B MoE
  around every summary. Hermes' default is already correct — `auxiliary.compression.model: ""` means
  "uses your main provider and main model" (`website/docs/user-guide/configuration.md:1150`), so the
  summariser follows whichever model is active. Consequence: `fast` must clear 64k on its own account,
  because when `fast` is active it is also the summariser.
- Placement confirmed as the native NixOS service with the `hermes` user. `createUser`, `user`,
  `group` and `stateDir` defaults already match; nothing to override.
- **New work the spec does not list** — the desktop app, with no Home Manager:
  - `backend.mode = "serve"` on `127.0.0.1`, `backend.sessionTokenFile` pointing at a sops secret
    (never a Nix path literal — the module's own docs warn the store is world-readable);
  - `packages.desktop` overridden with the four environment variables the HM module sets, the token
    read at start time through `extraRun`;
  - a decision on how `suzu` reaches `hermes`-owned state for the CLI/TUI — `addToSystemPackages`
    plus `hermes` group membership is the only native-mode mechanism upstream provides. **Open
    question for Phase 2:** whether the app needs `HERMES_HOME` read/write at all once
    `HERMES_DESKTOP_REMOTE_URL` points it at the service's backend. Test, do not assume.
  - Fallback if this fights back: text/TUI first. The pet renders in the terminal, so Phase 5 is not
    hostage to Electron — but the pop-out overlay Suzu wants *is* Electron-only.
- **Memory section rewritten** (answer 2): built-in `MEMORY.md` / `USER.md`. `mem0.json` and
  `mem0-migrate.py` drop out of the plan — mem0 is out-of-tree now (finding 3) and the store holds 3
  facts. No Qdrant, no embeddings service. Retiring `memory_mcp.py`, `consolidate.py` and the nightly
  `companion-memory-consolidation` timer moves to **Phase 7** with the rest of the old stack.
- **New:** pin the Hermes flake input **without** `inputs.nixpkgs.follows = "nixpkgs"` for first
  bring-up. Hermes builds through uv2nix + pnpm + Electron against its own `nixos-unstable`; forcing
  it onto the repo's nixpkgs is a second variable in the same step, which the repo's
  one-variable-per-upgrade rule forbids. Revisit after Suzu's nixpkgs update, as its own step.

**Phase 3 — `reika-guard`**
- Unchanged, with one addition: the pet's **vibe-reaction lexicon** matches on each user message
  locally. Confirm it reads only Suzu's messages and never tool output, or a page saying "good bot"
  could drive the pet. Low severity, but it belongs in the taint review.

**Phase 5 — The kitsune pet**
- Carry finding 4 in from the start: Plan A at `scale: 1.0` is 3× the stock pet. Evaluate the size on
  `DP-1` **before** the art pipeline begins, so a Plan B decision does not arrive after 9 rows of
  frames are baked. Note `scale` is a single master knob shared with the terminal surfaces, and
  **Alt+wheel over the pet persists a new scale** — so a stray scroll can silently undo Plan A's
  pixel-exactness. Worth a note in the module README.
- The spec's steps 6–7 (split into parts, rig in code) stand, but their *purpose* narrows: the states
  are agent-driven, so the eye and mouth channels distinguish working / thinking / waiting, not speech.
- Tail count is chosen at step 2 against real concepts. The constraint to respect: 48×52 art pixels
  and ≤24 colours. Nine tails will not read; two or three will, and each gets its own sway phase.

**Phase 6 — Summon and quick actions**
- The spec already flags that the desktop app's tap-to-summon does not work on Wayland. Confirmed, and
  worse than stated: snap-to-pointer is also a no-op and the compositor owns placement. Hyprland is
  special-cased over IPC; **Niri is not**, so expect to write Niri window rules for the HUD and the
  popped-out pet. `companion-ctl summon` driving `niri msg` plus the in-app HUD shortcut is the likely
  shape.

**Docs placement note**
- This file sits at the spec's literal path, `docs/companion/LOG.md`, a new top-level `docs/` tree. The
  repo's convention — and the spec's own non-negotiable list — put docs in the module folder they
  describe, i.e. `modules/ai/companion/`. It is a build log rather than component documentation, which
  is why the spec's path was followed. Say the word and it moves.

### Gate 0 — awaiting approval only

- [x] Repo, pinned Hermes source and spec read.
- [x] VERIFY items relevant to Phase 0 checked against `5d3723e`, results recorded above.
- [x] Machine state measured, OLV stack left running and untouched.
- [x] No repo files edited during inventory; this log is the only file created.
- [x] All Phase 0 questions answered.
- [x] Plan diff written.
- [ ] **[APPROVAL] from Suzu.**

Phase 1 does not start until that box is ticked.
