	# Module for adjusting GTK and QT theming for desktop
	{ pkgs, ... }:
	{
		home-manager.users.suzu = {
			home.packages = with pkgs; [
				# Add package to set QT theme to fit GTK
				qt5ct
			];

			# Central GTK themes configuration
			gtk = {
				enable = true;
				# Using Catppuccin theme for now
				theme.name = "Catppuccin-Macchiato";
				theme.package = pkgs.catppuccin-gtk;

				iconTheme.name = "Papirus-Dark";
				iconTheme.package = pkgs.papirus-icon-theme;
			};

			# Cursor theme
			home.pointerCursor = {
				name = "Catppuccin-Macchiato-Cursors";
				package = pkgs.catppuccin-cursors.macchiato;
				size = 24;
				gtk.enable = true;
			};

			# Makes QT apps use qt5ct to use GTK themes
			home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
		};
	}
