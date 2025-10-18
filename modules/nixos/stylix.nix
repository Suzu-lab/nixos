	# Stylix enable and setup
	{ pkgs, ... }:
	{
		stylix = {
			enable = true;
			autoEnable = true;

			# Sets the theme to be used. It accepts Tinted-Schemes, from https://github.com/tinted-theming/schemes
			base16Scheme = "${pkgs.base16-schemes}/share/themes/rebecca.yaml";

			# Sets a wallpaper.
			# image = ./wallpaper.png;

			# System wide font configuration
			fonts = {
				serif = {
					package = pkgs.noto-fonts;
					name = "Noto Serif";
				};
				sansSerif = {
					package = pkgs.noto-fonts;
					name = "Noto Sans";
				};
				monospace = {
					package = pkgs.noto-fonts;
					name = "Noto Sans Mono";
				};
				emoji = {
					package = pkgs.noto-fonts-color-emoji;
					name = "Noto Color Emoji";
				};
			};

			# Force full integration with Home Manager
			homeManagerIntegration = {
				autoImport = true;
				followSystem = true;
			};
		};
	}
