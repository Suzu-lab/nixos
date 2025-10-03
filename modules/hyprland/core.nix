  # Declarative config file for Hyprland
  { pkgs, ... }:
  {
    wayland.windowManager.hyprland = {
    	enable = true;

    	settings = {
    		# Monitor config
    		monitor = ",preferred,auto,auto";

    		# Default apps
    		"$terminal" = "kitty";
    		"$fileManager" = "thunar";
    		"$menu" = "wofi --show drun"

    		# Environment variables
    		env = [
    			"XCURSOR_SIZE,24"
    			"HYPRCURSOR_SIZE,24"
    		];

    		# Input
    		input = {
    			kb_layout = "us";
    			kb_variant = "intl";
    			follow_mouse = "1";
    		};

    		# Binds
    		"$mainMod" = "SUPER" # Sets "Windows" key as main modifier

    		# Key binds
        bind = [
        	"$mainMod,Q,exec,$terminal"
        	"$mainMod,C,killactive"
        	"$mainMod,M,exit"
        	"$mainMod,E,exec,$fileManager"
        	"$mainMod,V,togglefloating"
        	"$mainMod,R,exec,$menu"
        	"$mainMod,P,pseudo"
        	"$mainMod,J,togglesplit"
        	"$mainMod,SHIFT,R,exec,hyprctl reload"

        	# Move focus with mainMod + arrow keys
        	"$mainMod,left,movefocus,l"
        	"$mainMod,right,movefocus,r"
        	"$mainMod,up,movefocus,u"
        	"$mainMod,down,movefocus,d"

        	# Switch workspaces with mainMod + [0-9]
        	"$mainMod,1,workspace,1"
        	"$mainMod,2,workspace,2"
        	"$mainMod,3,workspace,3"
        	"$mainMod,4,workspace,4"
        	"$mainMod,5,workspace,5"
        	"$mainMod,6,workspace,6"
        	"$mainMod,7,workspace,7"
        	"$mainMod,8,workspace,8"
        	"$mainMod,9,workspace,9"
        	"$mainMod,0,workspace,10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT,1,movetoworkspace,1"
          "$mainMod SHIFT,2,movetoworkspace,2"
	    		"$mainMod SHIFT,3,movetoworkspace,3"
          "$mainMod SHIFT,4,movetoworkspace,4"
    			"$mainMod SHIFT,5,movetoworkspace,5"
    			"$mainMod SHIFT,6,movetoworkspace,6"
    			"$mainMod SHIFT,7,movetoworkspace,7"
    			"$mainMod SHIFT,8,movetoworkspace,8"
    			"$mainMod SHIFT,9,movetoworkspace,9"
    			"$mainMod SHIFT,0,movetoworkspace,10"
        ];

        #Mouse binds
        bindm = [
          # Scroll through existing workspaces with mainMod + scroll
        	"$mainMod,mouse_down,workspace,e+1"
        	"$mainMod,mouse_up,workspace,e-1"

        	# Move/resize windows with mainMod + LMB/RMB and dragging
        	"$mainMod,mouse:272,movewindow"
        	"$mainMod,mouse:273,resizewindow"
        ];

        # Workspace Rules

        windowrule = [
        	# Ignore maximize requests from apps
        	"suppressevent maximize,class:.*"
        	# Fix dragging issues with XWayland
        	"nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];

        # Look and feel

        # Smart gaps (uncoment to activate)
        # workspace = [
        	# "w[tv1],gapsout:0,gapsin:0"
        	# "f[1],gapsout:0,gapsin:0"
        # ];
        # windowrule = [
          # "bordersize 0,floating:0,onworkspace:w[tv1]"
          # "rounding 0,floating:0,onworkspace:w[tv1]"
          # "bordersize 0,floating:0,onworkspace:f[1]"
          # "rounding 0,floating:0,onworkspace:f[1]"
        # ];

        general = {
          # Gaps between windows, and window border
          gaps_in = "5";
          gaps_out = "10";
          border_size = "2";

          # Colors
          "col.active_border" = "0xff89b4fa"
          "col.inactive_border" = "0xff44475a"
        };

        decoration = {
          # Rounded corners
          rounding = "6"
          rounding_power = "2"

          # Change transparency of focused and unfocused windows
          active_opacity = "1.0"
          inactive_opacity = "1.0"

          shadow = {
          	enabled = "true"
          	range = "4"
            render_power = "3"
            color = "0x1a1a1aed"
          };

          blur = {
          	enabled = "true"
           	size = "3"
            passes = "1"

            vibrancy = "0.1696"
        	};
        };

        animations = {
          enabled = "1"

          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
        };

        # Dwindle pseudotile
        dwindle = {
        	pseudotile = "true"
        	preserve_split = "true"
        };

        # Master layout
        master = {
        	new_status = "master"
        };
    	};
    }
