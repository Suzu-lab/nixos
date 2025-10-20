	# Settings for wallpaper on Hyprland
	{ pkgs, config, ... }
	{
		services.hyprpaper = {
			enable = true;
			settings = {
				preload = "../../../wallpapers/wall1-DP-1.png";
				preload = "../../../wallpapers/wall1-DP-2.png";
				preload = "../../../wallpapers/wall1-DP-3.png";
				preload = "../../../wallpapers/wall1-HDMI-A-1.png";
				wallpaper = "DP-1, ../../../wallpapers/wall1-DP-1.png";
				wallpaper = "DP-2, ../../../wallpapers/wall1-DP-2.png";
				wallpaper = "DP-3, ../../../wallpapers/wall1-DP-3.png";
				wallpaper = "HDMI-A-1, ../../../wallpapers/wall1-HDMI-A-1.png";
			};
		};
	}
