# Configuration file specific for this machine
{
  config,
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
}
