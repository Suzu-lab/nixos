# Host prep + control for the containerized local image-generation stack (ComfyUI + SwarmUI).
#
# Deliberately split from modules/ai/companion-host.nix for modularity — the two AI stacks are
# independent compose projects. They only share the host baseline (Docker, amdgpu firmware,
# /dev/kfd + /dev/dri) and the AI NVMe. Like the companion, this stays containerized: all ROCm
# userspace lives inside the ComfyUI image, the host never gains a ROCm dependency. The stack
# itself is brought up imperatively via `docker compose` from modules/ai/imagegen/ — this module
# only creates the data dirs on the NVMe and installs the stream-deck control script.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.suzu.ai.imagegenHost;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.suzu.ai.imagegenHost = {
    enable = mkEnableOption "Data dirs + control script for the containerized ComfyUI/SwarmUI image-generation stack";

    dataDir = mkOption {
      type = types.str;
      default = "/home/${username}/ai-models";
      description = ''
        Base directory on the dedicated AI NVMe (shared with the companion stack).
        Matches AI_MODELS_ROOT in modules/ai/imagegen/.env.
      '';
    };

    outputDir = mkOption {
      type = types.str;
      default = "/home/${username}/hdd/imagegen";
      description = ''
        Where generated images are written. Defaults to the 12TB HDD RAID1 (mirrored + roomy)
        rather than the AI NVMe: outputs grow unbounded and the save is a tiny one-time write.
        Matches IMAGEGEN_OUTPUT_ROOT in modules/ai/imagegen/.env.
      '';
    };
  };

  config = mkIf cfg.enable {
    # ComfyUI model tree + disposable per-service volumes on the NVMe, owned by the user so
    # imperative docker/hf work needs no sudo. The model subfolders
    # ($AI_MODELS_ROOT/image/{checkpoints,loras/*,vae,controlnet,upscale_models,…}) are created by
    # a one-time `mkdir -p` at build time (ComfyUI convention) — these are just the data roots.
    systemd.tmpfiles.rules =
      # Fast NVMe: models, custom nodes, inputs, saved workflows.
      map (d: "d ${cfg.dataDir}/${d} 0755 ${username} users -") [
        "image"                # ComfyUI model tree (checkpoints, loras, vae, controlnet, upscale_models…)
        "imagegen"             # per-service disposable volumes for the imagegen compose project
        "imagegen/custom_nodes"
        "imagegen/input"
        "imagegen/user"        # ComfyUI saved workflows — back this up
        "imagegen/cache"       # HOME for the non-root comfyui container: MIOpen/Triton cache + temp
        "imagegen/swarm-data"  # SwarmUI settings/backends (host-owned bind, so it can run non-root)
        "imagegen/swarm-cache" # HOME for the non-root swarmui container: dotnet/nuget/git caches
      ]
      # HDD RAID1: the image library (ComfyUI output + SwarmUI output).
      ++ map (d: "d ${cfg.outputDir}/${d} 0755 ${username} users -") [
        ""
        "output"
        "swarm-output"
      ];

    # Stream-deck / CLI control for the image stack (OpenDeck "Run Command" + niri keybinds), kept
    # separate from companion-ctl so the two stacks stay decoupled. Talks to ComfyUI's API on the
    # published 127.0.0.1:8188 — the same localhost pattern companion-ctl uses for llama/kokoro.
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "imagegen-ctl";
        runtimeInputs = with pkgs; [ curl libnotify ];
        text = builtins.readFile ./imagegen/imagegen-ctl.sh;
      })
    ];
  };
}
