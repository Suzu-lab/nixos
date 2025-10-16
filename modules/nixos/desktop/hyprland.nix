	{ lib, pkgs, config, ... }:
	{
		# Enables graphic server without X
		services.xserver.enable = false;

		# Enables Hyprland
		programs.hyprland = {
			enable = true;
			xwayland.enable = true;
		};
	}
