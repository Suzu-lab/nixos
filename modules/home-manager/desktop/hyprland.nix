  # Module for setting and configuring the basic Hyprland desktop
  { lib, pkgs, config, ... }:
  {
		# Imports GTK3 theming
		imports = [
			./theming.nix
			../apps/kitty.nix
			../cli/fcitx5.nix
			./hyprpaper.nix
			./mako.nix
			./waybar.nix
			./wofi.nix
			./hyprland/layouts.nix
		];

  		# Global variables for forcing wayland wherever possible
  		home.sessionVariables = {
  			NIXOS_OZONE_WL = "1";								# Electron apps/Steam
  			GDK_BACKEND = "wayland,x11";				# GTK apps
  			QT_QPA_PLATFORM = "wayland;xcb";		# Qt apps
  			SDL_VIDEODRIVER = "wayland,x11";		#SDL
  			_JAVA_AWT_WM_NONREPARENTING = "1";	#Java/Swing
  			XDG_CURRENT_DESKTOP = "Hyprland";
  			XDG_SESSION_TYPE = "wayland";
  		};

			# Required services
			services.cliphist.enable = true;
			programs.swappy.enable = true;
			programs.wlogout.enable = true;

			systemd.user.services = {
				# Enables Polkit GNOME authentication agent at system level
				polkit-gnome-authentication-agent-1 = {
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
			};

			# Base apps required for Hyprland
			home.packages = with pkgs; [
 	    	######################################################
 	    	# Tools for Hyprland
 	    	######################################################
 	    	grim
 	    	hyprlock
 	    	hyprpaper
 	    	hyprpicker
 	    	polkit_gnome
 	    	slurp
 	    	wl-clipboard
 	    	xarchiver
 	    	pavucontrol
 	    	pamixer
 	    ];

  		# Declarative config files for the desktop environment
  		wayland.windowManager.hyprland = {
  			enable = true;
  			settings = {
  				# Default apps and mainmod variable
  				"$mainMod" = "SUPER";
  				"$terminal" = "kitty";
  				"$fileManager" = "thunar";
  				"$menu" = "pkill wofi ; wofi --show drun --allow-images";
  				"$cliphist" = "pkill wofi ; cliphist list | wofi --dmenu | cliphist decode | wl-copy";

  				# Autostart
  				exec-once = [
  					"waybar"
  					"hyprpaper"
  					"mako"
  					"cliphist store"
  					"${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
  					"xwaylandvideobridge"
  				];

  				# Environment variables
  				env = [
  					"XCURSOR_SIZE,24"
  					"HYPRCURSOR_SIZE,24"
  				];

  				# Keyboard
  				input = {
  					kb_layout = "us";
  					kb_variant = "intl";
  					follow_mouse = 1;
  				};

					###############################################
					# Displays
					###############################################

					monitor = [
						# Main display
						"DP-1, highres, 0x0, 1, vrr, 1"
						# Hyte display (right)
						"DP-2, preferred, 3840x0, auto, vrr, 1, transform, 3"
						# LG Ultrawide display 1 (top)
						"DP-3, highres, 620x-1080, 1, vrr, 1, transform, 2"
						# LG Ultrawide display 2 (left)
						"HDMI-A-1, highres, -1080x-200, 1, vrr, 1, transform, 1"
					];

					###############################################
  				# Eye-candy
  				###############################################
					# Gaps between windows
  				general = {
  					gaps_in = 5;
  					gaps_out = 10;
  					border_size = 2;
  					resize_on_border = "true";
  				};

					# Decorations
					decoration = {
  					# Rounded corners
  					rounding = 6;
  					rounding_power = 2;
						# Shadows on windows
  					shadow = {
  						enabled = "true";
  						range = 4;
  						render_power = 3;
  					};
  					# Window blur
  					blur = {
  						enabled = "true";
  						size = 3;
  						passes = 1;
  						vibrancy = 0.1696;
  					};
  				};

  				# Animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
  				animations = {
  					enabled = 1;
  					bezier = [
  						"easeOutQuint,0.23,1,0.32,1"
  						"easeInOutCubic,0.65,0.05,0.36,1"
  						"linear,0,0,1,1"
  						"almostLinear,0.5,0.5,0.75,1.0"
  						"quick,0.15,0,0.1,1"
  					];
  					animation = [
  						"global,1,10,default"
  						"border,1,5.39,easeOutQuint"
  						"windows,1,4.79,easeOutQuint"
  						"windowsIn,1,4.1,easeOutQuint,popin 87%"
  						"windowsOut,1,1.49,linear,popin 87%"
  						"fadeIn,1,1.73,almostLinear"
  						"fadeOut,1,1.46,almostLinear"
  						"fade,1,3.03,quick"
  						"layers,1,3.81,easeOutQuint"
  						"layersIn,1,4,easeOutQuint,fade"
  						"layersOut,1,1.5,linear,fade"
  						"fadeLayersIn,1,1.79,almostLinear"
  						"fadeLayersOut,1,1.39,almostLinear"
  						"workspaces,1,1.94,almostLinear,fade"
  						"workspacesIn,1,1.21,almostLinear,fade"
  						"workspacesOut,1,1.94,almostLinear,fade"
  					];
  				};

					# Workspace rules (for assigning workspaces to the monitors)
					workspace = [
						"r[1], monitor:DP-1"
						"r[2], monitor:DP-1"
						"r[3], monitor:DP-1"
						"r[4], monitor:DP-1"
						"r[5], monitor:DP-1"
						"r[6], monitor:DP-1"
						"r[7], monitor:DP-1"
						"r[8], monitor:DP-1"
						"r[9], monitor:DP-1"
						"r[10], monitor:DP-1"
						"name:communication, monitor:HDMI-A-1, default:true, persistent:true"
						"name:video, monitor:DP-3, default:true, persistent:true"
						"name:panel, monitor:DP-2, default:true, persistent:true"
					];

					# Windows rules
					windowrule = [
						# Ignore maximiza requests from apps
						"suppressevent maximize,class:.*"
						# Fix dragging issues with XWayland
						"nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
						# Make pavucontrol open as a small floating window
						"float, class:^(org.pulseaudio.pavucontrol)$"
						"size 60% 70%, class:^(org.pulseaudio.pavucontrol)$"
						"center, class:^(org.pulseaudio.pavucontrol)$"

						# Window rules to hide the xwayland window
						"opacity 0.0 override, class:^(xwaylandvideobridge)$"
						"noanim, class:^(xwaylandvideobridge)$"
						"noinitialfocus, class:^(xwaylandvideobridge)$"
						"maxsize 1 1, class:^(xwaylandvideobridge)$"
						"noblur, class:^(xwaylandvideobridge)$"
						"nofocus, class:^(xwaylandvideobridge)$"
					];

					# Keybindings
					bind = [
						"$mainMod, Q, exec, $terminal"
						"$mainMod, C, killactive"
						"$mainMod, M, exit"
						"$mainMod, E, exec, $fileManager"
						"$mainMod, V, exec, $cliphist"
						"$mainMod, R, exec, $menu"
						"$mainMod, P, pseudo,"
						"$mainMod, J, togglesplit,"
						"$mainMod, X, exec, wlogout"
						"$mainMod SHIFT, R, exec, hyprctl reload"
						# Screenshot
						", Print, exec, bash -c 'grim -g \"$(slurp -w 0)\" - | swappy -f -'"

						# Move focus with mainMod + arrow keys
						"$mainMod, left, movefocus, l"
						"$mainMod, right, movefocus, r"
						"$mainMod, up, movefocus, u"
						"$mainMod, down, movefocus, d"

						# Switch workspaces with mainMod + [0-9]
						"$mainMod, 1, workspace, 1"
						"$mainMod, 2, workspace, 2"
						"$mainMod, 3, workspace, 3"
						"$mainMod, 4, workspace, 4"
						"$mainMod, 5, workspace, 5"
						"$mainMod, 6, workspace, 6"
						"$mainMod, 7, workspace, 7"
						"$mainMod, 8, workspace, 8"
						"$mainMod, 9, workspace, 9"
						"$mainMod, 0, workspace, 10"

						# Move active window to a workspace with mainMod + SHIFT + [0-9]
						"$mainMod SHIFT, 1, movetoworkspace, 1"
						"$mainMod SHIFT, 2, movetoworkspace, 2"
						"$mainMod SHIFT, 3, movetoworkspace, 3"
						"$mainMod SHIFT, 4, movetoworkspace, 4"
						"$mainMod SHIFT, 5, movetoworkspace, 5"
						"$mainMod SHIFT, 6, movetoworkspace, 6"
						"$mainMod SHIFT, 7, movetoworkspace, 7"
						"$mainMod SHIFT, 8, movetoworkspace, 8"
						"$mainMod SHIFT, 9, movetoworkspace, 9"
						"$mainMod SHIFT, 0, movetoworkspace, 10"
						# Scroll through existing workspaces with mainMod + scroll
						"$mainMod, mouse_down, workspace, e+1"
						"$mainMod, mouse_up, workspace, e-1"
					];
					bindm = [
						# Move/resize windows with mainMod + LMB/RMB and dragging
						"$mainMod, mouse:272, movewindow"
						"$mainMod, mouse:273, resizewindow"
					];
				};
			};
		}
