#!/usr/bin/env bash
# rp-off — end the roleplay session and hand the GPU back to the companion. Bound to the AKP03E via
# OpenDeck next to rp-on. The mirror of rp-on: the other explicit VRAM handoff.
#
#   1. Drop whatever RP model is loaded, freeing the GPU.
#   2. `companion-ctl gpu-back` — repoint her active config to the GPU-VL variant, restart her
#      llama-swap, and warm her weights so she's ready with vision restored. That command already
#      does exactly this (and its own notify), so we reuse it rather than duplicate the swap logic.
set -euo pipefail

RP="http://127.0.0.1:8081"            # this stack's llama-swap (SillyTavern backend)
notify() { notify-send "$@" 2>/dev/null || true; }

notify "🎭 RP mode OFF" "Dropping the RP model, waking the companion…"

curl -sf -X POST "$RP/api/models/unload" >/dev/null || true   # free the GPU
companion-ctl gpu-back                                          # her back on the GPU (vision + warm)

echo "RP mode OFF — RP backend: $(curl -s "$RP/running" 2>/dev/null || echo unreachable). Companion warming."
