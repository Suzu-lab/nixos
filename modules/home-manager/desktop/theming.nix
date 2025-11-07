	# Module for adjusting GTK and QT theming for desktop
	{ pkgs, config, inputs, lib,  ... }:
	let
		colors = config.lib.stylix.colors;
	in
	{
		imports = [
			./fonts.nix
		];
		# Stylix configuration
		stylix = {
			# Enable Stylix
			enable = true;

			# Make it so Stylix doesn't automatically apply to the apps
			autoEnable = false;

			# Cursor theme
			cursor = {
				name = "Catppuccin-Macchiato-Cursors";
				package = pkgs.catppuccin-cursors.macchiatoDark;
				size = 24;
			};
			# Icon theme
			icons = {
				enable = true;
				dark = "Papirus-Dark";
				light = "Papirus";
				package = pkgs.papirus-icon-theme;
			};
		};
	}
