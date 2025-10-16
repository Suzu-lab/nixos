# Enables essential services for a desktop environment
  { pkgs, ... }:
  {
    # Enables graphic server without X
    services.xserver.enable = false;

		# Allow unfree packages
		nixpkgs.config.allowUnfree = true;

  	# Minimal display manager
  	services.greetd = {
  		enable = true;
  		settings = {
  			default_session = {
  				command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
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

  	# Polkit and essential services for hot plug USB
  	security.polkit.enable = true;
  	services.dbus.enable = true;
  	services.gvfs.enable = true;
  	services.tumbler.enable = true;
  	services.udisks2.enable = true;
  }
