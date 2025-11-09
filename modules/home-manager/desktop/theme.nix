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
}
