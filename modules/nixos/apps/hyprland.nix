{ lib, pkgs, ... }: {

  # Enables graphic server without X
  services.xserver.enable = false;

	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
	};

	# Global variables for forcing wayland wherever possible
	home.sessionVariables = {
		NIXOS_OZONE_WL = "1";								# Electron apps/Steam
		GDK_BACKEND = "wayland,x11";				# GTK apps
		QT_QPA_PLATFORM = "wayland;xcb";		# Qt apps
		SDL_VIDEODRIVER = "wayland,x11";		#SDL
		_JAVA_AWT_WM_NONREPARENTING = "1";	#Java/Swing
	};
}
