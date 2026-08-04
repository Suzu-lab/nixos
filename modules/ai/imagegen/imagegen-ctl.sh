#!/usr/bin/env bash
# Control client for the local image-generation stack (ComfyUI + SwarmUI), called by the Ajazz
# AKP03E stream deck (OpenDeck "Run Command") and niri keybinds. Talks to ComfyUI's HTTP API on
# the published 127.0.0.1:8188 — the same localhost pattern companion-ctl uses for llama/kokoro.
# Kept separate from companion-ctl so the two AI stacks stay decoupled.
#
#   imagegen-ctl free     # unload the cached checkpoint (fast — but the process keeps its VRAM pool)
#   imagegen-ctl stop     # docker-stop comfyui+swarmui: fully returns VRAM, incl. the ROCm/PyTorch
#                         #   allocator reservation that `free` can NOT reclaim (held for process life)
#   imagegen-ctl start    # bring the engines back up
#   imagegen-ctl status   # is the ComfyUI engine up?
#
# VRAM coexistence: the 16 GB card holds the LLM *or* an SDXL generation, not both. Typical flow:
#   companion-ctl gpu-free   # LLM → CPU, GPU freed
#   …generate in SwarmUI…
#   imagegen-ctl free        # release ComfyUI's VRAM
#   companion-ctl gpu-back   # LLM back on the GPU, vision restored
# `free` is the ComfyUI counterpart to llama-swap's unload; it POSTs the built-in /free endpoint.
set -euo pipefail
comfy="http://127.0.0.1:8188"
notify() { notify-send "$@" 2>/dev/null || true; }

case "${1:-}" in
  free)
    if curl -fsS -m10 -X POST "$comfy/free" \
        -H 'Content-Type: application/json' \
        -d '{"unload_models":true,"free_memory":true}' >/dev/null; then
      notify "🎨 ComfyUI" "VRAM freed."
      echo "comfyui: flushed"
    else
      notify "🎨 ComfyUI" "Not running (nothing to free)."
      echo "comfyui: not running"
    fi ;;
  stop)
    # Full stop — returns ALL of ComfyUI/SwarmUI's VRAM, including the ROCm/PyTorch caching-allocator
    # reservation that `free` can NOT reclaim (that pool is mapped for the process's lifetime; only
    # killing the process releases it). Use when done generating and the GPU is needed elsewhere.
    # `restart: unless-stopped` means they stay down until `start` (or a daemon/host restart).
    docker stop comfyui swarmui >/dev/null
    notify "🎨 Imagegen" "Engines stopped — VRAM fully released."
    echo "imagegen: stopped (comfyui, swarmui)" ;;
  start)
    docker start comfyui swarmui >/dev/null
    notify "🎨 Imagegen" "Engines starting…"
    echo "imagegen: started (comfyui, swarmui)" ;;
  status)
    if curl -fsS -m5 "$comfy/system_stats" >/dev/null 2>&1; then
      echo "comfyui: up"
    else
      echo "comfyui: down"; exit 1
    fi ;;
  *) echo "usage: imagegen-ctl {free|stop|start|status}" >&2; exit 1 ;;
esac
