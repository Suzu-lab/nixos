# Configuration file specific for this machine
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Import machine hardware config
    ./hardware-configuration.nix
    ../../modules/modules.nix
    ../../modules/packages.nix
  ];

  networking.hostName = "yosai";

  # Increase timeout of home-manager-suzu service to 15 minutes so it can actually finish the download of the pytorch and other thing for comfyui.
  systemd.services."home-manager-suzu".serviceConfig = {
    TimeoutStartSec = lib.mkForce "20min";
  };

  suzu.desktop = {
    # Window managers
    hyprland.enable = false;
    niri.enable = true;

    # Shells/bars
    noctalia.enable = true;

    # Desktop integration
    desktopEntries.enable = true;
    fcitx5.enable = true;
    xdg.enable = true;
  };

  # System-level modules (hardware, services, essentials)
  suzu.system = {
    audio.enable = true;
    deepcool.enable = true;
    disks.enable = true;
    firewall.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    guiEssentials.enable = true;
    keychron.enable = true;
    netdata.enable = true;
    openrgb.enable = true;
  };

  # Terminal applications
  suzu.cli = {
    fish.enable = true;
    git.enable = true;
    micro.enable = true;
    mpv.enable = true;
    yazi.enable = true;
  };

  # GUI programs
  suzu.programs = {
    celluloid.enable = true;
    chromium.enable = true;
    gthumb.enable = true;
    kitty.enable = true;
    nemo.enable = true;
    onlyoffice.enable = true;
    vscodium.enable = true;
    zathura.enable = true;
    zen.enable = true;
  };

  # Network options
  suzu.networking = {
    enable = true;
    doh.enable = true;  # Enables DNS over HTTPS (using cloudflared)
  };

  suzu.themes = {
    catppuccin = {
      enable = true;
      # Define the base color scheme. From lightest to darkest: "latte", "frappe", "macchiato", "mocha"
      flavor = "mocha";
      # Define accent color. "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
      accent = "mauve";
      # Define icon color. "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
      icons = "rosewater";
    };
  };

  # Options for AI stuff
  # Phase 0 host prep for the containerized AI companion (Docker + GPU firmware
  # + NVMe data dirs). The container stack itself lives on the NVMe and is run
  # imperatively via `docker compose`.
  suzu.ai.companionHost.enable = true;

  # Legacy native-ROCm AI stack (Ollama/OpenWebUI/ComfyUI). Kept for reference;
  # superseded by the containerized companion above.
/*  suzu.ai = {
    # LLM service
    ollama = {
      enable = true;
      backend = "rocm";
      models = [ "llama3.2:3b" "llama3.1:8b-instruct-q4_0" ];
    };
    # Web service for LLM
    webui = {
      enable = true;
      openFirewall = false;
    };
    # Stable diffusion with PyTorch+ROCm and ComfyUI
    comfyui = {
      enable = true;
      envDir = "/home/suzu/.local/share/comfy-env";
      workspaceDir = "/home/suzu/ai/comfyui";
      port = 8188;  # Port of service for web access (local or remote)
      openFirewall = false;
    };
  }; 
*/  
}
