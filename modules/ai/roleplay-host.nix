# Host prep + control for the containerized local roleplay stack (SillyTavern + a dedicated
# llama-swap). Third sibling to modules/ai/companion-host.nix and modules/ai/imagegen-host.nix, and
# deliberately split from both for the same reason: the three AI stacks are independent compose
# projects that only share the host baseline (Docker, amdgpu firmware, /dev/dri) and the AI NVMe.
#
# Like the others this stays containerized — no ROCm on the host, no GPU userspace here. SillyTavern
# is CPU-only Node; inference is Vulkan llama.cpp inside the llama-swap image. This module only:
#   - creates the stack's data dirs on the NVMe,
#   - installs the rp-on / rp-off handoff scripts (OpenDeck / CLI).
# Phone access (Tailscale + serve for SillyTavern :8000 and the dashboard :8081) is centralized in
# modules/nixos/tailscale.nix, since it spans all three AI stacks + system stats. The containers
# themselves are brought up imperatively via `docker compose` from modules/ai/roleplay/ (see that
# README), exactly like the companion and imagegen stacks.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.suzu.ai.roleplayHost;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.suzu.ai.roleplayHost = {
    enable = mkEnableOption "Data dirs + control scripts + phone access for the containerized SillyTavern roleplay stack";

    dataDir = mkOption {
      type = types.str;
      default = "/home/${username}/ai-models";
      description = ''
        Base directory on the dedicated AI NVMe (shared with the companion and imagegen stacks).
        RP model GGUFs live under $dataDir/models/rp; SillyTavern data under $dataDir/roleplay.
      '';
    };
  };

  config = mkIf cfg.enable {
    # RP model tree + SillyTavern volumes on the NVMe, owned by the user so imperative docker/hf work
    # needs no sudo. `models` already exists (companion-host creates it); models/rp is this stack's.
    systemd.tmpfiles.rules = map (d: "d ${cfg.dataDir}/${d} 0755 ${username} users -") [
      "models/rp"                        # RP GGUFs (Cydonia, Mag-Mell, GLM-Air, …) — download here
      "roleplay"                         # this stack's per-service volumes
      "roleplay/sillytavern"
      "roleplay/sillytavern/config"      # config.yaml lands here on first run, then edit + restart
      "roleplay/sillytavern/data"        # characters, chats, lorebooks, extensions — BACK THIS UP
      "roleplay/sillytavern/plugins"
    ];

    # Stream-deck / CLI control (OpenDeck "Run Command" + niri keybinds), kept separate from
    # companion-ctl / imagegen-ctl so the stacks stay decoupled. rp-on/rp-off are the two explicit
    # GPU handoffs. rp-off calls `companion-ctl gpu-back` (from companion-host), which the inherited
    # PATH makes resolvable; docker/coreutils are for rp-on's companion-llama-swap restart + symlink.
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "rp-on";
        runtimeInputs = with pkgs; [ curl docker coreutils libnotify ];
        text = builtins.readFile ./roleplay/rp-on.sh;
      })
      (pkgs.writeShellApplication {
        name = "rp-off";
        runtimeInputs = with pkgs; [ curl libnotify ];
        text = builtins.readFile ./roleplay/rp-off.sh;
      })
    ];
  };
}
