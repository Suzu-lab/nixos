{ lib, pkgs, ... }: {

  # Enables graphic server without X
  services.xserver.enable = false;

	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
	};
}
