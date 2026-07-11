#!/usr/bin/env bash
# Declaratively enforce SwarmUI's model-folder paths so they're always set from the repo and survive
# a swarm-data volume wipe / fresh setup. SwarmUI reads+rewrites Data/Settings.fds on every startup
# (merging defaults), and has no per-setting env/arg override — so we set the Paths values here,
# BEFORE launch, and SwarmUI keeps them. We touch ONLY the path lines (version-safe); every other
# setting SwarmUI manages itself, so your UI tweaks (theme, etc.) are preserved.
#
# ModelRoot points at the read-only /models mount (the ComfyUI model tree); the subfolder names are
# ComfyUI's, so SwarmUI and the engine agree on the same files.
set -euo pipefail
SF=/SwarmUI/Data/Settings.fds
mkdir -p /SwarmUI/Data

if [ ! -f "$SF" ]; then
  # Fresh volume: seed a minimal Paths section (SwarmUI fills every other setting with defaults).
  printf 'Paths:\n\tModelRoot: /models\n\tSDModelFolder: checkpoints\n\tSDLoraFolder: loras\n\tSDVAEFolder: vae\n\tSDEmbeddingFolder: embeddings\n\tSDControlNetsFolder: controlnet\n\tSDClipFolder: text_encoders;clip\n\tSDClipVisionFolder: clip_vision\n' > "$SF"
else
  # Existing settings: enforce our path values in place (repo wins), leave all else untouched.
  sed -i -E \
    -e 's|^([[:space:]]*ModelRoot:).*|\1 /models|' \
    -e 's|^([[:space:]]*SDModelFolder:).*|\1 checkpoints|' \
    -e 's|^([[:space:]]*SDLoraFolder:).*|\1 loras|' \
    -e 's|^([[:space:]]*SDVAEFolder:).*|\1 vae|' \
    -e 's|^([[:space:]]*SDEmbeddingFolder:).*|\1 embeddings|' \
    -e 's|^([[:space:]]*SDControlNetsFolder:).*|\1 controlnet|' \
    -e 's|^([[:space:]]*SDClipFolder:).*|\1 text_encoders;clip|' \
    -e 's|^([[:space:]]*SDClipVisionFolder:).*|\1 clip_vision|' \
    "$SF"
fi

# Enforce AllowIdle=FALSE on the ComfyUI backend. Counter-intuitively this is the FIX, not the cause:
# with AllowIdle=true, SwarmUI drops the backend to an 'idle' state ~5s after every init, and THIS
# SwarmUI version does NOT wake an idle backend on a generate request — it just answers "No backends
# available!". (Verified live: AllowIdle=true → backend runs ~5s then sits idle forever, generate
# fails; AllowIdle=false → backend stays 'running' indefinitely and generates fine.) A single always-on
# local ComfyUI (restart: unless-stopped, reachable over the compose net) never needs the idle/auto-
# recover dance; it just needs to stay running. The boot-race case (init hitting ComfyUI before its API
# is up → 'errored') is handled by the self-heal re-init below, after which — with AllowIdle off — it
# stays running permanently.
BF=/SwarmUI/Data/Backends.fds
[ -f "$BF" ] && sed -i -E 's|^([[:space:]]*AllowIdle:).*|\1 false|' "$BF"

# --- Backend self-heal (fixes "SwarmUI can't reach the backend after a PC restart") ----------------
# On a host reboot Docker's daemon auto-restarts both containers IN PARALLEL with no ordering
# (depends_on / healthchecks are only honored by `docker compose up`, NOT by boot auto-restart). If
# SwarmUI inits the backend before ComfyUI's API is up (node-load + DB-migration), the backend lands
# 'errored' and stays there until a manual restart. A disable→enable TOGGLE forces a clean re-init.
# This background task waits for ComfyUI to actually answer + SwarmUI's own API to come up, then, if
# the backend isn't already 'running', toggles it once — after which (AllowIdle=false) it stays
# running. Detached so it never blocks launch; a no-op on a healthy boot. Self-contained (curl only —
# no python) so it works however the container was started (compose up OR daemon auto-restart).
API=http://127.0.0.1:7801
newsess() { curl -fsS -m5 -X POST "$API/API/GetNewSession" -H 'Content-Type: application/json' -d '{}' 2>/dev/null \
  | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p'; }
(
  # 1) wait until the ComfyUI engine's API genuinely answers (up to ~4 min)
  for _ in $(seq 1 120); do curl -fsS -m3 http://comfyui:8188/system_stats >/dev/null 2>&1 && break; sleep 2; done
  # 2) wait until SwarmUI's own API is serving (post-launch/.NET build)
  for _ in $(seq 1 150); do [ -n "$(newsess)" ] && break; sleep 2; done
  # give the backend a moment to reach its initial (possibly idle) state, then poke if not running
  sleep 5
  sess=$(newsess); [ -z "$sess" ] && exit 0
  st=$(curl -fsS -m5 -X POST "$API/API/ListBackends" -H 'Content-Type: application/json' \
        -d "{\"session_id\":\"$sess\",\"nonreal\":true,\"full_data\":true}" 2>/dev/null \
        | grep -o '"status": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  if [ "$st" != "running" ]; then
    echo "[self-heal] backend status='$st' after boot — toggling backend 0 to force re-init"
    curl -fsS -m15 -X POST "$API/API/ToggleBackend" -H 'Content-Type: application/json' \
      -d "{\"session_id\":\"$sess\",\"backend_id\":\"0\",\"enabled\":false}" >/dev/null 2>&1
    sleep 2
    curl -fsS -m15 -X POST "$API/API/ToggleBackend" -H 'Content-Type: application/json' \
      -d "{\"session_id\":\"$sess\",\"backend_id\":\"0\",\"enabled\":true}" >/dev/null 2>&1
    echo "[self-heal] backend re-init requested"
  fi
) &

exec bash launch-linux.sh --launch_mode none --host 0.0.0.0
