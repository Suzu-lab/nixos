# Enables essential services for a desktop environment
  { pkgs, ... }:
  {
    # Enables graphic server without X
    services.xserver.enable = false;

    # Enables real time priority
    security.rtkit.enable = true;

		# Allow unfree packages
		nixpkgs.config.allowUnfree = true;

  	# Minimal display manager
  	services.greetd = {
  		enable = true;
  		settings = {
				initial_session = {
					command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
					user = "suzu";
				};
  			default_session = {
  				command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
  				user = "suzu";
  			};
  		};
  	};

		# Auto-login because fuck typing passwords
#		services.getty.autologinUser = "suzu";

  	# Desktop integration portals (required for file pickers, screenshots, etc)
  	xdg.portal = {
  		enable = true;
  		xdgOpenUsePortal = true;
  		extraPortals = with pkgs; [
  			xdg-desktop-portal-gnome	# Needed for Niri to work and get screencasting/screensharing
  			xdg-desktop-portal-gtk
#  			kdePackages.xdg-desktop-portal-kde
  		];
  	};

  	# Polkit and essential services for hot plug USB
  	security.polkit.enable = true;
  	services.dbus.enable = true;
  	services.gvfs.enable = true;
  	services.tumbler.enable = true;
  	services.udisks2.enable = true;
  }
