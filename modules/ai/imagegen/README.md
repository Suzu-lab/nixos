# Local Anime Image Generation — ComfyUI + SwarmUI (containerized)

Containerized **ComfyUI** (engine, owns the GPU) + **SwarmUI** (GPU-less frontend) for local,
uncensored anime image generation on the RX 9070 XT (gfx1201, 16 GB). Same design as the AI
companion: **all ROCm userspace is inside the container**, the NixOS host stays ROCm-free. A broken
ROCm release is fixed by editing one `FROM` line, never a `nixos-rebuild`.

- **Config (git-backed):** this directory — `Dockerfile`, `compose.yaml`, `extra-requirements.txt`,
  `.env`, `swarmui/`, `imagegen-ctl.sh`.
- **Data (on the AI NVMe):** models at `$AI_MODELS_ROOT/image/`, disposable volumes
  (`custom_nodes`, `input`, `user`) at `$AI_MODELS_ROOT/imagegen/`.
- **Generated images (on the 12TB HDD RAID1):** `$IMAGEGEN_OUTPUT_ROOT/{output,swarm-output}` —
  mirrored + roomy, since outputs grow unbounded. All dirs created declaratively by
  `modules/ai/imagegen-host.nix`.

## Pins (single source of truth)

| Item | Value | Notes |
|---|---|---|
| Engine base image | `rocm/pytorch:rocm7.2.4_ubuntu24.04_py3.12_pytorch_release_2.9.1` | ROCm 7.2 fixes the gfx1201 stall (ROCm/ROCm#5581) and is ~2× faster than 6.4.4 (ROCm/TheRock#1795) |
| Rollback base image | `rocm/pytorch:rocm6.4.4_ubuntu24.04_py3.12_pytorch_release_2.7.1` | Last known-good; swap the `FROM` line if the stall ever recurs |
| ComfyUI ref | `COMFYUI_REF` build arg (default `master`) | Pin to a release tag once verified |
| Ports | ComfyUI `127.0.0.1:8188`, SwarmUI `127.0.0.1:7801` | Localhost-only |
| Models root | `$AI_MODELS_ROOT/image` | `AI_MODELS_ROOT=/home/suzu/ai-models` in `.env` |

## First build (Phase B)

```bash
cd ~/nixos/modules/ai/imagegen

# One-time: ComfyUI's expected model subfolders on the NVMe (the data roots are made by Nix).
mkdir -p "$HOME"/ai-models/image/{checkpoints,loras/{illustrious,noobai,pony,sdxl},vae,embeddings,controlnet,upscale_models,clip,clip_vision,diffusion_models,text_encoders}

docker compose build
docker compose up -d
docker compose logs -f comfyui        # wait for "To see the GUI go to: http://0.0.0.0:8188"

# GPU visibility from inside the container:
docker compose exec comfyui python3 -c \
  "import torch; print(torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_name(0))"
# Expected: <ver>+rocm...  True  AMD Radeon RX 9070 XT
docker compose exec comfyui rocminfo | grep -m1 gfx    # Expected: gfx1201
```

Open <http://127.0.0.1:8188> — the graph UI should load (real generation needs a model, below).

## Models (Phase C)

Download SDXL-family checkpoints into `$AI_MODELS_ROOT/image/checkpoints/` (browser works; `curl`
for gated files). Starter: **WAI-Illustrious-SDXL** (uncensored variant). Refresh the ComfyUI page
after adding files. The CivitAI token is managed by sops-nix — read it from `/run/secrets`:

```bash
curl -L -H "Authorization: Bearer $(cat /run/secrets/civitai_api_token)" \
  -o "$HOME/ai-models/image/checkpoints/<name>.safetensors" \
  "https://civitai.com/api/download/models/<versionId>"
```

**LoRA family-lock:** LoRAs only work on checkpoints of their base family (Illustrious/NoobAI ↔
Illustrious-family; Pony ↔ Pony). Check the "Base Model" tag on CivitAI and sort into
`loras/{illustrious,noobai,pony,sdxl}/`.

## Custom nodes

Node *clones* live in the `custom_nodes/` volume; their *pip deps* go in `extra-requirements.txt` →
`docker compose build` (never runtime `pip install`). To add **ComfyUI-Manager** (the GUI gateway
for everything else):

```bash
git clone https://github.com/Comfy-Org/ComfyUI-Manager \
  "$HOME/ai-models/imagegen/custom_nodes/ComfyUI-Manager"
docker compose build && docker compose up -d    # its deps are already in extra-requirements.txt
```

Then install FaceDetailer (ComfyUI-Impact-Pack) etc. from the Manager UI.

## SwarmUI frontend (Phase D)

Raw ComfyUI is enough to start (community workflows are ComfyUI JSON). Add SwarmUI when you want an
A1111-style "prompt → image" tab; it runs GPU-less and drives the same engine.

```bash
docker compose up -d swarmui           # first start compiles the .NET project — give it a minute
docker compose logs -f swarmui
```

> Note: SwarmUI warns it will require **.NET 10** in a future version. The `dotnet/sdk:8.0` base
> works today; when that day comes, bump `swarmui/Dockerfile` to `mcr.microsoft.com/dotnet/sdk:10.0`
> and `docker compose build swarmui`.

**Prerequisite — install SwarmUI's ComfyUI nodes into the engine.** SwarmUI drives ComfyUI with its own
custom nodes (`SwarmSaveImageWS`, etc.); when it self-installs ComfyUI it adds them automatically, but for
our external engine we copy them once from the SwarmUI container into `custom_nodes/`:

```bash
nodes=$AI_MODELS_ROOT/imagegen/custom_nodes
docker cp swarmui:/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/ExtraNodes/SwarmComfyCommon "$nodes/"
docker cp swarmui:/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/ExtraNodes/SwarmComfyExtra  "$nodes/"
docker compose build comfyui && docker compose up -d comfyui   # cv2 + imageio deps are in extra-requirements.txt
```

`SwarmComfyCommon` needs `opencv-python-headless` + `imageio-ffmpeg` (baked in `extra-requirements.txt`) or
its import fails on `No module named 'cv2'` and Swarm reports "missing the Swarm core nodes". `SwarmComfyExtra`'s
background-removal / YOLO nodes additionally need `rembg`/`dill`/`ultralytics` (commented as opt-in). Verify:
`curl -s http://127.0.0.1:8188/object_info | grep -c Swarm` should report dozens of `Swarm*` nodes.

One-time UI setup at <http://127.0.0.1:7801>:
1. Installer wizard → choose the **custom / advanced config** path so you can **skip installing a backend**.
   Do NOT pick the plain "comfyui" backend option — it force-installs a *fresh* ComfyUI inside the SwarmUI
   container (no python/ROCm there → "ComfyUI install failed"). We attach the existing engine by URL next.
2. `Server → Backends → Add → ComfyUI API By URL` → address **`http://comfyui:8188`** → save, wait for green.
   **The `http://` scheme is mandatory** — `comfyui:8188` alone makes SwarmUI read `comfyui` as the URL scheme
   (`The 'comfyui' scheme is not supported` / `Invalid port`), and the textarea can sneak in a trailing char.
   `comfyui` resolves via Docker's embedded DNS (same compose network) — no host nameserver needed; and
   `127.0.0.1` would be SwarmUI's *own* loopback, not the engine. The saved value lives in the swarm-data
   volume at `Data/Backends.fds` if you ever need to fix it by hand.
3. **Model paths are set for you** — `swarmui/entrypoint.sh` enforces `ModelRoot: /models` + the
   ComfyUI folder names (`checkpoints`, `loras`, `vae`, …) into `Settings.fds` on every start, so they're
   declarative (repo-owned) and survive a volume wipe. No manual `Server → Configuration → Paths` needed.
   (`/models` is mounted read-WRITE: SwarmUI insists on creating its own folder types under ModelRoot and
   writes model thumbnails/metadata there — a read-only mount makes it abort with "Read-only file system".)
4. Generate tab → pick a checkpoint → test. Outputs land in `$IMAGEGEN_OUTPUT_ROOT/swarm-output` (HDD).

## VRAM coexistence with the companion (Phase E)

16 GB holds the LLM **or** an SDXL generation, not both. Reuse the companion's gaming-mode discipline:

```bash
companion-ctl gpu-free   # LLM → CPU, GPU freed (she keeps talking, no vision)
#   …generate in SwarmUI / ComfyUI…
imagegen-ctl free        # release ComfyUI's cached checkpoint from VRAM
companion-ctl gpu-back   # LLM back on the GPU, vision restored
```

`imagegen-ctl free` POSTs ComfyUI's `/free` (unload models + free cache) — the counterpart to
llama-swap's unload. Map it to a spare OpenDeck LCD key (OpenDeck "Run Command" → `imagegen-ctl free`).

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Generation stalls: GPU 100% but power/temps sag, no progress | gfx1201 ROCm 7.x stall (should be fixed in 7.2) | Swap the `FROM` line to the 6.4.4 rollback, `docker compose build` |
| `Memory access fault by GPU node … Page not present`, esp. after a system update | Host kernel amdgpu regression | Roll back the NixOS kernel generation (see the kernel-pin note in the build plan) |
| Black / NaN images at VAE decode | fp16 VAE overflow | Start engine with `--fp32-vae`, or drop `sdxl-vae-fp16-fix` in `vae/` + a VAE Loader |
| HIP out-of-memory when generating | LLM still resident | `companion-ctl gpu-free` before generating |
| First gen after start slow, then fast | MIOpen/Triton autotune warmup | Expected; the `miopen-cache` volume persists it — don't delete casually |
| `ImportError` from a custom node after recreate | deps installed at runtime, died with the container | Add them to `extra-requirements.txt` → rebuild |
| Model dropdown empty | volume path mismatch | Confirm `.env` `AI_MODELS_ROOT` and that files sit in `image/checkpoints/`, refresh browser |
| SwarmUI "backend errored" after a **reboot** (ComfyUI itself is up) | Boot race: ComfyUI is slower to accept connections (DB + node load); SwarmUI's fast retries hit "Connection refused" and give up | Fixed by `AllowIdle: true` on the backend (enforced by `swarmui/entrypoint.sh` → auto-recovers when the API returns). If ever stuck: `docker compose restart swarmui`, or the backend's Restart button in the UI |

## Update procedure

1. **ComfyUI:** bump `COMFYUI_REF` → `docker compose build && up -d`. Models/workflows/nodes/caches persist.
2. **ROCm/torch:** change the `FROM` tag deliberately; keep the previous tag commented as rollback. Re-verify GPU + a generation.
3. **Kernel:** on your schedule; re-verify a generation after.
4. Never update all three at once — you lose the ability to bisect.
