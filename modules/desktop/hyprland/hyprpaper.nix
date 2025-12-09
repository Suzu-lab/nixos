# Settings for wallpaper on Hyprland
{ pkgs, config, lib, ... }:
{
  config = lib.mkIf config.suzu.desktop.hyprland.enable {
    hm.hyprpaper = {
      enable = true;
      settings = {
        preload = [
          "~/Wallpapers/Landscape/shion_01_landscape.png"
          "~/Wallpapers/Portrait/guweiz_01_portrait.png"
        ];
        wallpaper = [
          "DP-1, ~/Wallpapers/Landscape/shion_01_landscape.png"
          "DP-2, ~/Wallpapers/Portrait/guweiz_01_portrait.png"
          "DP-3, ~/Wallpapers/Landscape/shion_01_landscape.png"
          "HDMI-A-1, ~/Wallpapers/Portrait/guweiz_01_portrait.png"
        ];
      };
    };
  };
}
