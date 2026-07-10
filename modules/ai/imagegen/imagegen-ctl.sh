#!/usr/bin/env bash
# Control client for the local image-generation stack (ComfyUI + SwarmUI), called by the Ajazz
# AKP03E stream deck (OpenDeck "Run Command") and niri keybinds. Talks to ComfyUI's HTTP API on
# the published 127.0.0.1:8188 — the same localhost pattern companion-ctl uses for llama/kokoro.
# Kept separate from companion-ctl so the two AI stacks stay decoupled.
#
#   imagegen-ctl free     # drop ComfyUI's cached checkpoint from VRAM (do this when done generating)
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
  status)
    if curl -fsS -m5 "$comfy/system_stats" >/dev/null 2>&1; then
      echo "comfyui: up"
    else
      echo "comfyui: down"; exit 1
    fi ;;
  *) echo "usage: imagegen-ctl {free|status}" >&2; exit 1 ;;
esac
