  # Module for setting and configuring the basic Hyprland desktop
  { lib, pkgs, ... }:
  {
  	# Enables graphic server without X
  	services.xserver.enable = false;

		# Enables Hyprland
		programs.hyprland = {
			enable = true;
			xwayland.enable = true;
		};

		# Home-Manager configuration (variables and dotfiles)
		home-manager.users.suzu = {
  		# Global variables for forcing wayland wherever possible
  		home.sessionVariables = {
  			NIXOS_OZONE_WL = "1";								# Electron apps/Steam
  			GDK_BACKEND = "wayland,x11";				# GTK apps
  			QT_QPA_PLATFORM = "wayland;xcb";		# Qt apps
  			SDL_VIDEODRIVER = "wayland,x11";		#SDL
  			_JAVA_AWT_WM_NONREPARENTING = "1";	#Java/Swing
  		};

			# Base apps required for Hyprland
			home.packages = with pkgs; [
 	    	######################################################
 	    	# Tools for Hyprland
 	    	######################################################
 	    	cliphist
 	    	grim
 	    	hyprlock
 	    	hyprpaper
 	    	kitty
 	    	mako
 	    	polkit_gnome
 	    	slurp
 	    	waybar
 	    	wl-clipboard
 	    	wofi
 	    	xarchiver
 	    ];

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
		};
  }
