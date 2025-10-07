# Module for activating and configuring Waybar in Home Manager
{ pkgs, input, ...}:{
	home-manager.users.suzu = {
		programs.waybar = {
			enable = true;
			# Declarative configuration
			settings = {
				mainBar = {
					layer = "top";
					position = "top";
					modules-left = [
						"hyprland/workspaces"
						"hyprland/window"
						"hyprland/windowcount"
					];
					modules-center = [
						"clock"
					];
					modules-right = [
						"pulseaudio" "cpu" "memory"
					];
					# options for the modules
					"hyprland/window" = {
						format = "[{}]";
					};
				};
			};
		};
	};
}
