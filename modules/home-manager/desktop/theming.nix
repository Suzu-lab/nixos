# Using Catppuccin since it works better than Stylix, and I like the Catpuccin theme
{ catppuccin, config, pkgs, inputs, lib,  ...}:

{
	# Documentation at https://nix.catppuccin.com/
	imports = [
		./fonts.nix
	];

	catppuccin = {
		# Enable it for all programs
		enable = true;
		# Base color scheme. From lightest to darkest: "latte", "frappe", "macchiato", "mocha"
		flavor = "mocha";
		# Accent color for the theme. "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
		accent = "pink";
	};


	# Module for adjusting GTK and QT theming for desktop
#	{ pkgs, config, inputs, lib,  ... }:
		# Stylix configuration
/*		stylix = {
			# Enable Stylix
			enable = true;

			# Make it so Stylix doesn't automatically apply to the apps
			autoEnable = false;


			targets = {
				# Enable for Zen Browser
				zen-browser = {
					enable = true;
					profileNames = [ "default" ];
				};

				# Enable for yazi
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
			
		};*/
	}
