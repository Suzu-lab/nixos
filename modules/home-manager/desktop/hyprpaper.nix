# Settings for wallpaper on Hyprland
{ pkgs, config, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/nixos/wallpapers/wall1-DP-1.png"
        "~/nixos/wallpapers/wall1-DP-2.png"
        "~/nixos/wallpapers/wall1-DP-3.png"
        "~/nixos/wallpapers/wall1-HDMI-A-1.png"
      ];
      wallpaper = [
        "DP-1, ~/nixos/wallpapers/wall1-DP-1.png"
        "DP-2, ~/nixos/wallpapers/wall1-DP-2.png"
        "DP-3, ~/nixos/wallpapers/wall1-DP-3.png"
        "HDMI-A-1, ~/nixos/wallpapers/wall1-HDMI-A-1.png"
      ];
    };
  };
}
