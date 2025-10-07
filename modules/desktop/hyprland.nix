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

		# Imports GTK3 theming
		imports = [
			./theming.nix
			../apps/kitty.nix
			./mako.nix
			./waybar.nix
			./wofi.nix
		];

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

			# Enables Polkit GNOME authentication agent at system level
			systemd.user.services.polkit-gnome-authentication-agent-1 = {
				Unit = {
					Description = "Polkit GNOME Authentication Agent";
				};
				Service = {
					ExecStart = "{pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
					Restart = "on-failure";
					RestartSec = 1;
					TimeoutStopSec = 10;
				};
				Install = {
					Wantedby = [ "graphical-session.target"];
				};
			};

			# Base apps required for Hyprland
			home.packages = with pkgs; [
 	    	######################################################
 	    	# Tools for Hyprland
 	    	######################################################
 	    	grim
 	    	hyprlock
 	    	hyprpicker
 	    	polkit_gnome
 	    	slurp
 	    	wl-clipboard
 	    	xarchiver
 	    ];

  		# Declarative config files for the desktop environment
  		# Hyprland config (~/.config/hypr/hyprland.conf)
  		xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hyprland.conf;


			# Activate cliphist as a Home Manager module
			services.cliphist.enable = true;
			# Activate swappy as a Home Manager module
			programs.swappy.enable = true;
			# Activate wlogout as a Home Manager module
			programs.wlogout.enable = true;
		};
  }
