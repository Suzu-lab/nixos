# Configuration file specific for this machine
{
  catppuccin,
  config,
  pkgs,
  inputs,
  nixowos,
  niri,
  ...
}:
{
  imports = [
    # Import machine hardware config
    ./hardware-configuration.nix

    niri.nixosModules.niri

    # import theming module for system-level
    catppuccin.nixosModules.catppuccin
    # NixOwOS
    nixowos.nixosModules.default

    # Import system modules
    ../../modules/nixos/base.nix # default system module
    ../../modules/nixos/fonts.nix # system-wide fonts (includding embedded bitmap option for Noto Emoji on Floorp)
    ../../modules/nixos/hardware/audio.nix # pipewire module
    ../../modules/nixos/services/desktop-essentials.nix # essential services for GUI
    ../../modules/nixos/services/firewall.nix # Firewall settings
    ../../modules/nixos/services/gayming.nix # module for setting up Steam and other gaming options

    # Modules needed for desktop usage
    #      ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/desktop/noctalia.nix
    ../../modules/nixos/theme.nix

    # Importing system flakes modules
    inputs.nurpkgs.modules.nixos.default

    # Importing Home Manager module
    inputs.home-manager.nixosModules.home-manager

    # User config
    ../../users/suzu/user.nix
    ../../users/suzu/home.nix
  ];

  networking.hostName = "yosai";
}
