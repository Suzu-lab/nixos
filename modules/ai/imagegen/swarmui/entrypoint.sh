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

# Enforce AllowIdle on the ComfyUI backend (if configured yet): on a reboot both containers start
# together and ComfyUI is slower to accept connections (DB migration + node load), so SwarmUI's few
# fast retries hit "Connection refused" and it gives up permanently. AllowIdle makes an unresponsive
# backend go idle and AUTO-RECOVER when the API returns, instead of staying errored until a restart.
BF=/SwarmUI/Data/Backends.fds
[ -f "$BF" ] && sed -i -E 's|^([[:space:]]*AllowIdle:).*|\1 true|' "$BF"

exec bash launch-linux.sh --launch_mode none --host 0.0.0.0
