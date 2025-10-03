  # Module for setting and configuring the basic Hyprland services
  { pkgs, ... }:
  {
    # Enables graphic server without X
    services.xserver.enable = false;

  	# Enables Hyprland WM
  	programs.hyprland = {
  		enable = true;
      withUWSM = true;				# Use Universal Wayland Session Manager to integrate hyprland with systemd
  		xwayland.enable = true; # enable compatibility layer for x11 apps
  	};

  	# Global variables for forcing wayland wherever possible
  	environment.sessionVariables = {
  		NIXOS_OZONE_WL = "1";								# Electron apps/Steam
  		GDK_BACKEND = "wayland,x11";				# GTK apps
  		QT_QPA_PLATFORM = "wayland;xcb";		# Qt apps
  		SDL_VIDEODRIVER = "wayland,x11";		#SDL
  		_JAVA_AWT_WM_NONREPARENTING = "1";	#Java/Swing
  	};

  	# Minimal display manager
  	services.greetd = {
  		enable = true;
  		settings = {
  			default_session = {
  				command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
  				user = "suzu";
  			};
  		};
  	};

  	# Desktop integration portals (required for file pickers, screenshots, etc)
  	xdg.portal = {
  		enable = true;
  		extraPortals = with pkgs; [
  			xdg-desktop-portal-hyprland
  			xdg-desktop-portal-gtk
  		];
  	};

  	# Audio setup
  	services.pipewire = {
  		enable = true;
  		alsa.enable = true;
  		pulse.enable = true;
    	wireplumber.enable = true;
  	};

		# Polkit and essential services for hot plug USB
		security.polkit.enable = true;
		services.dbus.enable = true;
		services.gvfs.enable = true;
		services.tumbler.enable = true;
		services.udisks2.enable = true;

    #configure Thunar plugins
    programs.thunar = {
     	enable = true;
     	plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };

    # Essential GUI apps
    environment.systemPackages = with pkgs; [
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

    # GUI fonts
    fonts.packages = with pkgs; [
    	noto-fonts
    	noto-fonts-cjk-sans
    	noto-fonts-emoji
    	font-awesome
    ];
  }
