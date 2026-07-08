# Phase 0 host prep for the containerized local AI companion stack.
#
# The whole point of the containerized design (see the build guide) is that the
# host stays minimal: it only provides the in-kernel amdgpu driver + firmware,
# the /dev/dri device nodes, and Docker. Every AI service (llama.cpp Vulkan,
# Open-LLM-VTuber, SearXNG, Letta, TTS) runs in containers managed imperatively
# via `docker compose` on the NVMe. No ROCm on the host.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.suzu.ai.companionHost;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.suzu.ai.companionHost = {
    enable = mkEnableOption "Docker host prep for the containerized AI companion stack";

    dataDir = mkOption {
      type = types.str;
      default = "/home/${username}/ai-models";
      description = ''
        Base directory on the dedicated NVMe for all AI stack data (models and
        per-service container volumes). Reuses the existing mount from
        suzu.system.disks; subdirectories are created declaratively below.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Container runtime. The stack itself is brought up by hand with docker
    # compose; NixOS only provides the daemon.
    virtualisation.docker.enable = true;
    users.users.${username}.extraGroups = [ "docker" ];

    # Host GPU bits the containers rely on: amdgpu/RDNA4 firmware and the
    # /dev/dri render node. Host Mesa is harmless and handy for debugging.
    hardware.graphics.enable = true;
    hardware.enableRedistributableFirmware = true;

    # `ask-screen` (Phase 7): native screen -> vision-model -> her voice hotkey. Bound
    # in modules/desktop/niri/keybinds.nix. Talks straight to llama-server + Kokoro
    # (published on 127.0.0.1), independent of OLV so it survives a frontend swap.
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "ask-screen";
        runtimeInputs = with pkgs; [ grim slurp jq curl mpv libnotify coreutils ];
        text = builtins.readFile ./companion/ask-screen.sh;
      })
      # Control channel client for the custom Electron app: prompt-summon + in-conversation
      # screen capture. Bound in modules/desktop/niri/keybinds.nix (needs the app running).
      (pkgs.writeShellApplication {
        name = "companion-ctl";
        # docker + gnused + libnotify for the gaming-mode model swap; wireplumber for wpctl
        # (mic-gain knob). noctalia/niri come from the inherited PATH (writeShellApplication keeps it).
        runtimeInputs = with pkgs; [ curl grim slurp coreutils docker gnused libnotify wireplumber ];
        text = builtins.readFile ./companion/companion-ctl.sh;
      })
      # The custom multi-surface Electron client itself (VRM avatar + text prompt), providing
      # the `companion` binary. Autostarted + pinned to the Y70 in modules/desktop/niri.
      pkgs.companion-client
    ];

    # Declarative version of the guide's `mkdir -p .../{models,olv,...}` step,
    # owned by the user so imperative docker/hf work needs no sudo.
    systemd.tmpfiles.rules = map (d: "d ${cfg.dataDir}/${d} 0755 ${username} users -") [
      "models"
      "llama-swap"
      "olv"
      "olv/chat_history"   # persisted OLV chat logs (read by the consolidation job)
      "searxng"
      "letta"
      "tts"
      "memory"             # long-term memory SQLite store + training-data corpus
      "compose"
      "dropbox"
      "src"
      "avatar"             # the companion's VRM model (model.vrm) — read by the Electron client
      "avatar/animations"  # optional authored .vrma clips (idle.vrma, <emotion>.vrma) the client plays
    ];

    # Sleep-time memory consolidation (see modules/ai/companion/consolidate.py):
    # nightly, distills the day's chat logs into long-term memories + a fine-tuning
    # corpus by asking the local llama-server. Stdlib-only script on a bare python3.
    systemd.services.companion-memory-consolidation = {
      description = "Distill the AI companion's daily chat logs into long-term memory";
      after = [ "docker.service" ];
      environment = {
        MEMORY_DB = "${cfg.dataDir}/memory/memory.db";
        CHAT_HISTORY_DIR = "${cfg.dataDir}/olv/chat_history";
        TRAINING_JSONL = "${cfg.dataDir}/memory/training_data.jsonl";
        LLAMA_URL = "http://localhost:8080/v1/chat/completions";
        CONF_UID = "mao_pro_001";
      };
      serviceConfig = {
        Type = "oneshot";
        # Runs as root: reads the root-owned chat_history + memory.db the container writes.
        ExecStart = "${pkgs.python3}/bin/python3 ${./companion/consolidate.py}";
      };
    };

    systemd.timers.companion-memory-consolidation = {
      description = "Nightly AI companion memory consolidation";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;          # run on next boot if the machine was off at 4 AM
        RandomizedDelaySec = "10m";
      };
    };
  };
}
