	# Module for adjusting GTK and QT theming for desktop
	{ pkgs, ... }:
	{
		home-manager.users.suzu = {
			home.packages = with pkgs; [
				# Add package to set QT theme to fit GTK
				libsForQt5.qt5ct
			];

			# Central GTK themes configuration
			gtk = {
				enable = true;
				# Using Catppuccin theme for now
				theme.name = "Catppuccin-Macchiato-Dark";
				theme.package = pkgs.catppuccin-gtk.override {
					tweaks = [ "black" ];
					variant = "macchiato";
				};

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
		};
	}
