	# Set up theme for the system
	{ pkgs, cattpuccin, nixowos, ... }:
	{
	# Enables catppuccin theme globally
		catppuccin = {
			enable = true;
			flavor = "mocha";
			accent = "pink";
		};
	
	# Enables NixOwOS globally
		nixowos.enable = true;
	}
