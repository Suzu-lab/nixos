	# Set up catppuccin theme for the system
	{ pkgs, cattpuccin, ... }:
	{
		catppuccin = {
			enable = true;
			flavor = "mocha";
			accent = "pink";
		};

	}
