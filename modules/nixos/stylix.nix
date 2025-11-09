	# Stylix enable and setup
	{ pkgs, ... }:
	{
		catppuccin = {
			enable = true;
			flavor = "mocha";
			accent = "pink";
		};

/*		stylix = {
			enable = true;
			autoEnable = false;

			# Sets the theme to be used. It accepts Tinted-Schemes, from https://github.com/tinted-theming/schemes
			base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-city-dark.yaml";

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
		};*/
	}
