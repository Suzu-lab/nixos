#!/usr/bin/env bash
# Dev launcher for the companion Electron client: stop any running instance, then (re)launch.
# Idempotent — run it again to restart her (e.g. after dropping a new model.vrm). The VRM is
# read from $COMPANION_VRM or /home/suzu/ai-models/avatar/model.vrm (see main.js).
# M4 replaces this with a Nix-packaged binary + autostart; this is the interim shortcut.
set -u
cd "$(dirname "$(readlink -f "$0")")" || exit 1

# Kill any previous instance (dev `electron .` OR the packaged `…/share/companion-client`), so
# the single-instance lock doesn't just make this launch quit. This script's own argv is
# "bash …/run.sh" — it matches neither pattern, so no self-match.
pkill -f "electron \." 2>/dev/null || true
pkill -f "share/companion-client" 2>/dev/null || true
sleep 0.6

unset ELECTRON_RUN_AS_NODE  # otherwise electron runs as plain node
exec nix shell nixpkgs#electron --command electron . \
  --ozone-platform-hint=auto --enable-features=UseOzonePlatform --ozone-platform=wayland
