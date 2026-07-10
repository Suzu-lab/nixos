#!/usr/bin/env bash
# Control client for the local AI companion — called by the Ajazz stream deck (OpenDeck "Run
# Command") and niri keybinds. Talks to the Electron app's control channel (:12395), llama-swap
# (:8080), and docker.
#
#   companion-ctl toggle-prompt   # summon/hide the text prompt
#   companion-ctl look            # capture the whole screen INTO the conversation
#   companion-ctl look-region     # capture a drag-selected region into the conversation
#   companion-ctl toggle-mic      # mute/unmute the mic
#   companion-ctl interrupt       # stop her talking now
#   companion-ctl gpu-free        # GAMING MODE: free the GPU's VRAM, keep her running on CPU (no vision)
#   companion-ctl gpu-back        # back to the GPU model (vision restored)
#   companion-ctl volume %d       # knob "Dial rotate": output volume by signed ticks (noctalia)
#   companion-ctl mic-gain %d     # knob rotate: mic input gain by signed ticks (wpctl)
#   companion-ctl brightness %d   # knob rotate: monitor brightness by signed ticks (noctalia/ddcutil)
#   companion-ctl displays-toggle # knob press: power all monitors off/on (DPMS), toggled
#
# `look`/`look-region` send the screenshot as an in-conversation image (she keeps the context).
# The knob commands take %d = signed ticks (+ clockwise, - counterclockwise). `noctalia`/`niri`
# come from the inherited PATH (writeShellApplication keeps $PATH), like the knob's direct
# `noctalia msg volume-mute` press does.
set -euo pipefail
base="http://127.0.0.1:12395"        # Electron client control channel
llama="http://127.0.0.1:8080"        # llama-swap proxy
shot="${XDG_RUNTIME_DIR:-/tmp}/companion-screen.png"

# GPU ↔ CPU WITHOUT restarting OLV (so her live conversation survives): OLV always requests model
# `chat`; we swap which config that name resolves to by repointing the active.yaml symlink, then
# restart ONLY llama-swap. OLV's process (and its in-memory conversation) is never touched; its next
# request transparently hits the new backend. See llama-swap.yaml and docker-compose.yml.
llamaswap="companion-llama-swap-1"
active="/home/suzu/ai-models/llama-swap/active.yaml"
cfg_gpu="/home/suzu/nixos/modules/ai/companion/llama-swap.yaml"       # chat = VL MoE on GPU
cfg_cpu="/home/suzu/nixos/modules/ai/companion/llama-swap-cpu.yaml"   # chat = text MoE on CPU

# Repoint the active config symlink, restart only llama-swap, warm `chat` so she's ready.
swap_llama() { # $1 = target config file
  ln -sfn "$1" "$active"
  docker restart "$llamaswap" >/dev/null
  curl -sf -m300 "$llama/v1/chat/completions" -H 'Content-Type: application/json' \
    -d '{"model":"chat","messages":[{"role":"user","content":"hi"}],"max_tokens":1}' >/dev/null || true
}
notify() { notify-send "$@" 2>/dev/null || true; }

case "${1:-}" in
  toggle-prompt) curl -sf -m2 "$base/toggle-prompt" >/dev/null ;;
  show-prompt)   curl -sf -m2 "$base/show-prompt" >/dev/null ;;
  hide-prompt)   curl -sf -m2 "$base/hide-prompt" >/dev/null ;;
  look)          grim "$shot"               && curl -sf -m5 -X POST "$base/capture" --data "$shot" >/dev/null ;;
  look-region)   grim -g "$(slurp)" "$shot" && curl -sf -m5 -X POST "$base/capture" --data "$shot" >/dev/null ;;
  toggle-mic)    curl -sf -m2 "$base/toggle-mic" >/dev/null ;;
  interrupt)     curl -sf -m2 "$base/interrupt" >/dev/null ;;
  volume)        # knob "Dial rotate": $2 = signed ticks (%d). + = clockwise/up, - = ccw/down.
                 t="${2:-0}"
                 case "$t" in ''|*[!0-9-]*) exit 0 ;; esac          # ignore non-integers
                 [ "$t" -eq 0 ] && exit 0
                 step=3                                             # % per tick
                 if [ "$t" -lt 0 ]; then noctalia msg volume-down "$(( -t * step ))"
                 else noctalia msg volume-up "$(( t * step ))"; fi ;;
  mic-gain)      # knob rotate: mic input gain, via wpctl on the default source
                 t="${2:-0}"
                 case "$t" in ''|*[!0-9-]*) exit 0 ;; esac
                 [ "$t" -eq 0 ] && exit 0
                 if [ "$t" -lt 0 ]; then wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "$(( -t * 3 ))%-"
                 else wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "$(( t * 3 ))%+"; fi ;;
  brightness)    # knob rotate: monitor brightness via noctalia (ddcutil) — needs hardware.i2c
                 t="${2:-0}"
                 case "$t" in ''|*[!0-9-]*) exit 0 ;; esac
                 [ "$t" -eq 0 ] && exit 0
                 if [ "$t" -lt 0 ]; then noctalia msg brightness-down "$(( -t * 5 ))"
                 else noctalia msg brightness-up "$(( t * 5 ))"; fi ;;
  displays-toggle) # knob PRESS ("Dial down"): power ALL monitors off/on (DPMS), toggled via a flag file
                 f="${XDG_RUNTIME_DIR:-/tmp}/companion-displays-off"
                 if [ -e "$f" ]; then niri msg action power-on-monitors; rm -f "$f"
                 else niri msg action power-off-monitors; : > "$f"; fi ;;
  gpu-free)      notify "🎮 GPU freed" "Moving Reika to CPU (keeping her conversation)…"
                 swap_llama "$cfg_cpu"
                 notify "🎮 GPU freed" "Reika on CPU (no vision). GPU free for a game or image gen." ;;
  gpu-back)      notify "Reika" "Bringing her back to the GPU…"
                 swap_llama "$cfg_gpu"
                 notify "Reika" "Back on the GPU — vision restored." ;;
  *) echo "usage: companion-ctl {toggle-prompt|show-prompt|hide-prompt|look|look-region|toggle-mic|interrupt|gpu-free|gpu-back|volume <ticks>|mic-gain <ticks>|brightness <ticks>|displays-toggle}" >&2; exit 1 ;;
esac
