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
			xdg.configFile = {
				"gtk-4.0/assets".source = "${config.gtk.theme.package}/share/theme/${config.gtk.theme.name}/gtk-4.0/assets";
				"gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/theme/${config.gtk.theme.name}/gtk-4.0/gtk.css";
				"gtk-4.0/gtk-dark".source = "${config.gtk.theme.package}/share/theme/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
			};

			}
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
