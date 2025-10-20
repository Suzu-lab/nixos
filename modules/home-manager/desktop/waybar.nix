# Module for activating and configuring Waybar in Home Manager
{ pkgs, input, config, ...}:
let
	colors = config.lib.stylix.colors;
in
{
	programs.waybar = {
		enable = true;
		# Style config will use a template because Stylix sucks at theming Waybar
		style =
		with colors.withHashtag;
		''
		@define-color base00 ${base00}; @define-color base01 ${base01};
		@define-color base02 ${base02}; @define-color base03 ${base03};
		@define-color base04 ${base04}; @define-color base05 ${base05};
		@define-color base06 ${base06}; @define-color base07 ${base07};
		@define-color base08 ${base08}; @define-color base09 ${base09};
		@define-color base0A ${base0A}; @define-color base0B ${base0B};
		@define-color base0C ${base0C}; @define-color base0D ${base0D};
		@define-color base0E ${base0E}; @define-color base0F ${base0F};
		'' + builtins.readFile ./dotfiles/waybar.css;
		# Declarative configuration
		settings =
			let
				inherit (pkgs)
					pavucontrol
					pamixer
					;
			in
			{
				mainBar = {
					layer = "top";
					position = "top";
					output = "DP-1";
					height = 30;
					modules-left = [
						"hyprland/window"
						"pulseaudio"
						"cpu"
						"memory"
#						"hyprland/windowcount"
					];
					modules-center = [
						"hyprland/workspaces"
					];
					modules-right = [
						"tray" "network" "clock"
					];
					# options for the modules
					"hyprland/workspaces" = {
						format = "{name}";
						format-icons = {
#							"1" = "";
#							"2" = "";
#							"3" = "";
#							"4" = "";
#							"5" = "";
#							"urgent" = "";
#							"focused" = "";
#							"default" = "";
							"default" = " ";
							"active" = " ";
							"urgent" = " ";
						};
						on-scroll-up = "hyprctl dispatch workspace e+1";
						on-scroll-down = "hyprctl dispatch workspace e-1";
					};
					"hyprland/window" = {
						max-length = 22;
						format = "[{}]";
					};
					clock = {
						format = " {:%H:%M}";
						format-alt = " {:%d/%m/%Y}";
						tooltip-format = "<tt><small>{calendar}</small></tt>";
						calendar = {
							mode = "month";
							mode-mon-col = 3;
							weeks-pos = "right";
							on-scroll = 1;
							on-click-right = "mode";
							format = {
								months = "<span color='#${colors.base0E}'><b>{}</b></span>";
								days = "<span color='#${colors.base06}'><b>{}</b></span>";
								weeks = "<span color='#${colors.base0B}'><b>{}</b></span>";
								weekdays = "<span color='#${colors.base0B}'><b>{}</b></span>";
								today = "<span color='#${colors.base08}'><b>{}</b></span>";
							};
						};
					};
					tray = {
						icon-size = 18;
						spacing = 10;
					};
					pulseaudio = {
						format = "{icon}  {volume:2}%";
						format-muted = "  {volume:2}%";
						format-icons = {
							default = ["" "" ""];
						};
						on-click = "${pkgs.pamixer}/bin/pamixer --toggle-mute";
						on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
					};
					network = {
						format-wifi = "  {essid}";
						format-ethernet = "󰈀  Eth";
						format-disconnected = "󰖪  Disc";
						tooltip-format-wifi = "SSID: {essid}\Signal: {signalStrength}%";
						on-click = "kitty -e nmtui";
					};
					cpu = {
						format = "  {usage}%";
						tooltip = true;
					};
					memory = {
						format = "  {}%";
					};
				};
			};
	};
}
