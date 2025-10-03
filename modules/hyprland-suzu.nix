  # Declarative config files for the desktop environment
  { pkgs, ... }:
  {

    # Hyprland config (~/.config/hypr/hyprland.conf)
    xdg.configFile."hypr/hyprland.conf".source = ./hyprland/hyprland.conf;

    # Waybar config (~/.config/waybar/config.jsonc)
    xdg.configFile."waybar/config.jsonc".source = ./hyprland/waybar.jsonc;

    # Config of waybar style sheet (~/.config/waybar/style.css)
    xdg.configFile."waybar/style.css".source = ./hyprland/waybar.style;

    # Hyprpaper config (~/.config/hypr/hyprpaper.conf)
    xdg.configFile."hypr/hyprpaper.conf".source = ./hyprland/hyprpaper.conf;

    # Mako config (~/.config/mako/config)
    xdg.configFile."mako/config".source = ./hyprland/mako.conf;

    # Wofi config (~/.config/wofi/style.css)
    xdg.configFile."wofi/style.css".source = ./hyprland/wofi.style;

  }
