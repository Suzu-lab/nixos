{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # System modules
    ./nixos/audio.nix
    ./nixos/base.nix # Basic system module
    ./nixos/firewall.nix
    ./nixos/fonts.nix
    ./nixos/gayming.nix
    ./nixos/gui-essentials.nix
    ./nixos/networking.nix

    # Window managers
    ./desktop/hyprland/hyprland.nix
    ./desktop/niri/niri.nix

    # Shells/bars
    ./desktop/noctalia.nix

    # Desktop configs
    ./desktop/desktop-entries.nix # Customized .desktop entries
    ./desktop/fcitx5.nix # Input method for language support
    ./desktop/xdg.nix # Configuration for file associations

    # Themes
    ./desktop/catppuccin.nix

    # Terminal applications and settings
    ./cli/fish.nix
    ./cli/git.nix
    ./cli/micro.nix
    ./cli/mpv.nix # Terminal media player
    ./cli/yazi.nix  # Terminal file explorer

    # Programs
    ./programs/celluloid.nix  # GUI wrapper for mpv
    ./programs/chromium.nix # Web browser for communication webapps
    ./programs/floorp.nix # Web browser
    ./programs/gthumb.nix # Image viewer
    ./programs/kitty.nix  # Terminal
    ./programs/onlyoffice.nix
    ./programs/thunar.nix # File manager
    ./programs/vscodium.nix
    ./programs/zathura.nix  # Light and fast document viewer
    ./programs/zen.nix  # Backup browser
  ];
#  config.networking = {
#      networkmanager = {
#        enable = true;
#      };};
}