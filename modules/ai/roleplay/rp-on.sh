#!/usr/bin/env bash
# rp-on — clear the decks for a SillyTavern roleplay session. Bound to the Ajazz AKP03E via OpenDeck
# alongside the gaming toggle. The single moment the GPU (and the companion's RAM) is handed to RP.
#
# What it does, and why it's MORE aggressive than gaming mode:
#   Gaming mode (`companion-ctl gpu-free`) parks the companion on CPU and keeps her warm in RAM so
#   she can still talk while you game. RP is different — you won't talk to her at all, and the 106B
#   GLM-Air wants that RAM/CPU. So we KILL her model outright:
#
#   1. Repoint her active config to the CPU variant and restart ONLY her llama-swap. It comes up
#      empty (llama-swap loads on demand), so nothing is resident — VRAM and RAM both freed. This is
#      `companion-ctl gpu-free`'s mechanism WITHOUT the warm-up curl, so she stays fully unloaded.
#   2. Because the active config is now the CPU one, any STRAY OLV request during RP (e.g. the 4 AM
#      consolidation, or you fat-fingering the mic) lazy-loads her text model into RAM only — never
#      the GPU the RP model is holding. It has a TTL and vanishes again.
#
# OLV's process stays alive the whole time, so the conversation/session is untouched (it lives in
# OLV's chat log, not the llama-server process — same guarantee the gaming toggle relies on).
set -euo pipefail

RP="http://127.0.0.1:8081"            # this stack's llama-swap (SillyTavern backend)
companion_swap="companion-llama-swap-1"
active="/home/suzu/ai-models/llama-swap/active.yaml"
cfg_cpu="/home/suzu/nixos/modules/ai/companion/llama-swap-cpu.yaml"   # chat = text MoE on CPU
notify() { notify-send "$@" 2>/dev/null || true; }

notify "🎭 RP mode ON" "Killing the companion, clearing the GPU…"

# Belt-and-suspenders: drop anything already resident in the RP instance (fresh sessions start clean).
curl -sf -X POST "$RP/api/models/unload" >/dev/null || true

# Kill the companion's model and make stray reloads RAM-only (repoint→CPU, restart, DON'T warm).
ln -sfn "$cfg_cpu" "$active"
docker restart "$companion_swap" >/dev/null

notify "🎭 RP mode ON" "GPU clear, companion unloaded. Open SillyTavern."
echo "RP mode ON — GPU is clear. RP backend: $(curl -s "$RP/running" 2>/dev/null || echo unreachable)"
