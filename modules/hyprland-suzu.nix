  # Declarative config files for the desktop environment
  { pkgs, ... }:
  {

    # Useful packages for Hyprland
    home.packages = with pkgs; [
    	waybar
    	wl-clipboard
    ];

    # Hyprland config (~/.config/hypr/hyprland.conf)
    xdg.configFile."hypr/hyprland.conf".text = ''
    ############################################################
    # Monitors
    ############################################################
    monitor=,preferred,auto,auto

    ############################################################
    # Default apps
    ############################################################
    $terminal = kitty
    $fileManager = thunar
    $menu = wofi --show drun

    ############################################################
    # Autostart
    ############################################################
    exec-once = waybar

    ############################################################
    # Environment variables
    ############################################################
    env = XCURSOR_SIZE,24
    env = HYPRCURSOR_SIZE,24

    # Input
    input {
    	kb_layout = us
    	kb_variant = intl

    	follow_mouse = 1
    }

    ############################################################
    # Keybindings
    ############################################################
    $mainMod = SUPER # Sets "Windows" key as main modifier

    # Binds
    bind = $mainMod, Q, exec, $terminal
    bind = $mainMod, C, killactive
    bind = $mainMod, M, exit
    bind = $mainMod, E, exec, $fileManager
    bind = $mainMod, V, togglefloating
    bind = $mainMod, R, exec, $menu
    bind = $mainMod, P, pseudo,
    bind = $mainMod, J, togglesplit,
    bind = $mainMod, SHIFT, R, exec, hyprctl reload

    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

    # Switch workspaces with mainMod + [0-9]
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    ############################################################
    # Workspace rules
    ############################################################

    # Ignore maximize requests from apps
    windowrule = suppressevent maximize, class:.*

    # Fix some dragging issues with XWayland
    windowrule = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

    ############################################################
    # Look and Fell
    ############################################################

    # Smart gaps config for later
    # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
    # "Smart gaps" / "No gaps when only"
    # uncomment all if you wish to use that.
    # workspace = w[tv1], gapsout:0, gapsin:0
    # workspace = f[1], gapsout:0, gapsin:0
    # windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
    # windowrule = rounding 0, floating:0, onworkspace:w[tv1]
    # windowrule = bordersize 0, floating:0, onworkspace:f[1]
    # windowrule = rounding 0, floating:0, onworkspace:f[1]

    general {
      # Gaps between windows, and window border
      gaps_in = 5
      gaps_out = 10
      border_size = 2

      # Colors
      col.active_border=0xff89b4fa
      col.inactive_border=0xff44475a
    }

    decoration {
    	# Rounded corners
  	  rounding = 6
    	rounding_power = 2

    	# Change transparency of focused and unfocused windows
    	active_opacity = 1.0
  	  inactive_opacity = 1.0

    	shadow {
    		enabled = true
  	  	range = 4
  		  render_power = 3
  		  color = 0x1a1a1aed
  	  }

    	blur {
    		enabled = true
  	  	size = 3
  		  passes = 1

  		  vibrancy = 0.1696
	    }
	  }


    animations {
      enabled = yes, please :)

      # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = easeOutQuint,0.23,1,0.32,1
      bezier = easeInOutCubic,0.65,0.05,0.36,1
      bezier = linear,0,0,1,1
      bezier = almostLinear,0.5,0.5,0.75,1.0
      bezier = quick,0.15,0,0.1,1

  	  animation = global, 1, 10, default
      animation = border, 1, 5.39, easeOutQuint
      animation = windows, 1, 4.79, easeOutQuint
      animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
      animation = windowsOut, 1, 1.49, linear, popin 87%
      animation = fadeIn, 1, 1.73, almostLinear
      animation = fadeOut, 1, 1.46, almostLinear
      animation = fade, 1, 3.03, quick
      animation = layers, 1, 3.81, easeOutQuint
      animation = layersIn, 1, 4, easeOutQuint, fade
      animation = layersOut, 1, 1.5, linear, fade
      animation = fadeLayersIn, 1, 1.79, almostLinear
      animation = fadeLayersOut, 1, 1.39, almostLinear
      animation = workspaces, 1, 1.94, almostLinear, fade
      animation = workspacesIn, 1, 1.21, almostLinear, fade
      animation = workspacesOut, 1, 1.94, almostLinear, fade
    }

    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    dwindle {
  	  pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
  	  preserve_split = true # You probably want this
    }

    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    master {
  	  new_status = master
    }
    '';

    # Waybar config (~/.config/waybar/config.jsonc)
    xdg.configFile."waybar/config.jsonc".text = ''
    {
      "style": "~/.config/waybar/style.css",

    	"layer": "top",
    	"position": "top",

  	  "modules-left": [
  		  "hyprland/workspaces"
  	  ],

    	"modules-center": [
    		"clock"
  	  ],

    	"modules-right": [
    		"cpu", "memory"
  	  ],

    }
    '';

    # Config of waybar style sheet (~/.config/waybar/style.css)
    xdg.configFile."waybar/style.css".text = ''
    ############################################################
    ## Base styles
    ############################################################

    * {
    	font-family: "Noto Sans", "Font Awesome 6 Free";
  	  font-size: 12px;
  	  color: #f8f8f2;
    }

    window#waybar {
    	background: #282a36;
    }

    #clock {
    	padding: 0px 10px;
    }
    '';
  }
