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
			enable = true;
			targets = {
				waybar = {
					enable = false;
				};
				zen-browser = {
					enable = true;
					profileNames = [ "default" ];
				};

/*				gtk = {
					enable = true;
					# Solve Thunar font color on selected items
					extraCss = ''
						* :selected {
							color: #${colors.base00};
						}
						# Override accent color in gtk apps
						:root {
							--accent-bg-color: #${colors.base0D};
						}
					'';
				};
*/
				yazi = {
					enable = true;
					boldDirectory = true;
				};
			};

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
