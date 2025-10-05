  # Module for setting and configuring the basic Hyprland desktop
  { pkgs, ... }:
  {
  	# Enables Hyprland WM
  	wayland.windowManager.hyprland = {
  		enable = true;
  		xwayland.enable = true; # enable compatibility layer for x11 apps
  	};

  	# Declarative config files for the desktop environment
  	# Hyprland config (~/.config/hypr/hyprland.conf)
  	xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hyprland.conf;

  	# Waybar config (~/.config/waybar/config.jsonc)
  	xdg.configFile."waybar/config.jsonc".source = ./dotfiles/waybar.jsonc;

  	# Config of waybar style sheet (~/.config/waybar/style.css)
  	xdg.configFile."waybar/style.css".source = ./dotfiles/waybar.css;

  	# Hyprpaper config (~/.config/hypr/hyprpaper.conf)
  	xdg.configFile."hypr/hyprpaper.conf".source = ./dotfiles/hyprpaper.conf;

  	# Mako config (~/.config/mako/config)
  	xdg.configFile."mako/config".source = ./dotfiles/mako.conf;

  	# Wofi config (~/.config/wofi/style.css)
  	xdg.configFile."wofi/style.css".source = ./dotfiles/wofi.css;
  }
