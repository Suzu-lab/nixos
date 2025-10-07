	# Module for adjusting GTK and QT theming for desktop
	{ pkgs, inputs, ... }:
	{
		# Stylix configuration - it needs apps to be called as modules within home-manager for them to get the themes applied to them
		stylix = {
			# Enable Stylix
			enable = true;

			# Autoenable Stylix for every module it can be used on
			autoEnable = true;

			# Sets the theme to be used. It accepts Tinted-Schemes, from https://github.com/tinted-theming/schemes
			base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

			# Sets the theme to be picked from the wallpaper colors. base16scheme must be deactivated for this option to work
			# polarity = "dark"; # Also accepts "light"

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




		home-manager.users.suzu = {
			home.packages = with pkgs; [
				# Add package to set QT theme to fit GTK
				libsForQt5.qt5ct
			];

			# Central GTK themes configuration
			gtk = {
				enable = true;
				# Configure icons theme
				iconTheme.name = "Papirus-Dark";
				iconTheme.package = pkgs.papirus-icon-theme;
			};

			# Cursor theme
			home.pointerCursor = {
				name = "Catppuccin-Macchiato-Cursors";
				package = pkgs.catppuccin-cursors.macchiatoDark;
				size = 24;
				gtk.enable = true;
			};

			# Makes QT apps use qt5ct to use GTK themes
			home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
			# Test for Waybar Stylix
			stylix.targets.waybar.enable = true;
			stylix.targets.zen-browser = {
				enable = true;
				profileNames = [ "default" ];
			};
		};
	}
