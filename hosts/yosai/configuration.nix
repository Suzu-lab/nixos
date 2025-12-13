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
  suzu.ai = {
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
  
}
