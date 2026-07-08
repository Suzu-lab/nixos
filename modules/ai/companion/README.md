# Local AI companion — runtime config (source of truth)

A local, uncensored, avatar-based voice+text AI companion running in Docker on `yosai`.
The host side (Docker, GPU firmware, NVMe data dirs) is declared in Nix
([../companion-host.nix](../companion-host.nix)). The container stack itself is run
imperatively with `docker compose` — this folder holds the small text files that define
it, kept in the repo (GitHub-backed) so they survive an NVMe loss and are edited centrally.

## Files here (the live, editable config)

| File | What it is |
|---|---|
| `docker-compose.yml` | The stack: `llama-swap` (model hot-swap proxy over llama.cpp Vulkan) + `olv` (Open-LLM-VTuber) + `kokoro` (natural TTS) + `searxng`, on one network, `restart: unless-stopped`. **Run the stack from here.** |
| `llama-swap.yaml` | llama-swap profiles: `chat` (VL MoE on GPU, daily driver) + `chat-cpu` (text-only on CPU, gaming mode). Loaded by `model` name. Mounted at `/app/config.yaml`. |
| `conf.yaml` | Open-LLM-VTuber config (LLM endpoint `http://llama-swap:8080/v1` model `chat`, ASR/TTS/VAD, Reika's persona). Mounted into `olv` **from this path** — edit here, then restart `olv`. |
| `dockerfile` | Recipe to build the `open-llm-vtuber:local` image. ~4 KB of instructions — NOT the 22 GB image (that lives in Docker's storage, rebuildable from this). |

## What stays on the NVMe (`/home/suzu/ai-models`, too big for git)

- `models/` — GGUF weights (~18 GB) — the daily-driver `Huihui-Qwen3-30B-A3B-Instruct-2507-abliterated`
- `tts/` — sherpa-onnx MeloTTS voice
- `olv/models/` — auto-downloaded ASR/whisper models (persisted so they don't re-download)
- `olv/app/` — the cloned Open-LLM-VTuber v1.2.1 source (the build context for the image)

## Running the stack

```bash
docker compose -f ~/nixos/modules/ai/companion/docker-compose.yml up -d      # start
docker compose -f ~/nixos/modules/ai/companion/docker-compose.yml down       # stop
docker compose -f ~/nixos/modules/ai/companion/docker-compose.yml logs -f    # tail logs
docker compose -f ~/nixos/modules/ai/companion/docker-compose.yml restart olv  # apply conf.yaml edits
```

Open the UI at <http://localhost:12393>. llama.cpp chat UI (debug) at <http://localhost:8080>.

## Rebuilding the OLV image (only when needed)

The upstream v1.2.1 dockerfile is broken; our `dockerfile` here contains the fixes
(Python 3.11 via deadsnakes, strip macOS pyobjc pins, setuptools<80, sherpa-onnx pin,
add mcp + pin starlette/uvicorn/anyio, add faster-whisper, correct `run_server.py` entry,
skip MeloTTS). To reproduce the image from scratch:

```bash
# 1. Clone the pinned OLV source (the build context) if not already present:
git clone --recursive --branch v1.2.1 \
  https://github.com/Open-LLM-VTuber/Open-LLM-VTuber.git /home/suzu/ai-models/olv/app

# 2. Build using THIS dockerfile against that source tree:
docker build -f ~/nixos/modules/ai/companion/dockerfile \
  -t open-llm-vtuber:local /home/suzu/ai-models/olv/app
```

The llama image is pulled, not built: `ghcr.io/ggml-org/llama.cpp:server-vulkan`.

## Gaming mode (llama-swap)

The GPU model (`chat`) holds ~11 GB of VRAM. `gpu-free` frees the GPU for a game but **keeps her
running on the CPU profile** (`chat-cpu`) so she's still there — text-only (no vision), ~8-15 t/s:

```bash
companion-ctl gpu-free   # → CPU: flips OLV to chat-cpu, restarts olv, frees the GPU. She stays alive.
companion-ctl gpu-back   # → GPU: back to the chat (VL) model, vision restored.
```

Both flip OLV's `model:` in conf.yaml + `docker restart companion-olv-1` + load the target in
llama-swap (which evicts the other). Toggling `gpu-back` returns conf.yaml to its original state
(no lingering diff). Manual full unload (she sleeps entirely): `curl -X POST http://localhost:8080/api/models/unload`.

## Stream deck — Ajazz AKP03E (OpenDeck)

The AKP03E (a rebadged Mirabox N3) is installed as `pkgs.opendeck` (AppImage) with a udev
`uaccess` rule for `0300:3002` ([../../desktop/opendeck.nix](../../desktop/opendeck.nix)).

**One-time setup (GUI):**
1. Launch **OpenDeck**. Plug in the deck; it should appear (udev grants access to the logged-in user).
2. Install the device plugin: OpenDeck → **Plugins** → install **`4ndv/opendeck-akp03`**
   (from its GitHub releases). Restart OpenDeck. The 6 LCD keys + 3 knobs become mappable.
3. Map each key to a **command** action (all one-liners you already have):

| Input | Action | Command |
|---|---|---|
| LCD 1 | Gaming mode (free GPU, stay on CPU) | `companion-ctl gpu-free` |
| LCD 2 | Back to GPU (vision) | `companion-ctl gpu-back` |
| LCD 3 | Ask about my screen | `companion-ctl look` |
| LCD 4 | Mic mute toggle | `companion-ctl toggle-mic` |
| LCD 5 | Silence her | `companion-ctl interrupt` |
| LCD 6 | Summon text prompt | `companion-ctl toggle-prompt` |
| Knob 1 | Her voice volume | `wpctl set-volume <tts-sink> 5%+` / `5%-` on rotate |
| Knob 2 | Mic gain | `wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+` / `5%-` |
| Knob 3 | Scroll niri columns | `niri msg action focus-column-left` / `focus-column-right` |

`companion-ctl` and `ask-screen` are on `PATH`. The `look`/`toggle-mic`/`interrupt`/`toggle-prompt`
actions need the companion app running (they poke its control server on `127.0.0.1:12395`).

## Notes

- Containers talk by service name (`http://llama-swap:8080`); `host.docker.internal` does NOT
  work here (NixOS host firewall blocks container→host published ports).
- ASR is faster-whisper `small` + `OMP_NUM_THREADS=16` (snappy, multilingual EN + pt-BR).
- The stack survives reboots via `restart: unless-stopped` + Docker starting on boot.
