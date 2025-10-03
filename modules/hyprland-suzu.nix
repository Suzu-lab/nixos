  # Declarative config files for the desktop environment
  { pkgs, ... }:
  {

    # Hyprland config (~/.config/hypr/hyprland.conf)
    xdg.configFile."hypr/hyprland.conf".source = ./hyprland/hyprland.conf;

    # Waybar config (~/.config/waybar/config.jsonc)
    xdg.configFile."waybar/config.jsonc".source = ./hyprland/waybar.jsonc;

    # Config of waybar style sheet (~/.config/waybar/style.css)
    xdg.configFile."waybar/style.css".source = ./hyprland/waybar.style;
  }
