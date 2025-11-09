# Module for activating and configuring Waybar in Home Manager
{ pkgs, input, config, ...}:
{
	programs.waybar = {
		enable = true;
		# Declarative style config
		style = ''		
		* {
			border: none;
			border-radius: 0;
			font-family: "JetbrainsMono Nerd Font", "Font Awesome 6 Free";
  		font-size: 16px;
		  min-height: 0;
		}

		window#waybar {
 			background: transparent;
		}

		#workspaces, #window, #clock, #pulseaudio, #network, #cpu, #memory, #tray {
  		background: transparent;
  		color: @text;
		  padding: 5px 5px;
  		margin: 2px 4px;
		}

		#workspaces button {
 			color: @text;
		 	background: linear-gradient(45deg, @surface0, @pink);
 			transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
 			opacity: 0.5;
 			padding: 0px 5px;
 			margin: 0px 3px;
 			border-radius: 16px;
 			font-weight: bold;
		}

		#workspaces button.active {
 			color: @text;
 			background: linear-gradient(45deg, @surface0, @pink);
 			transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
 			opacity: 1.0;
 			min-width: 40px;
 			padding: 0px 5px;
 			margin: 0px 3px;
 			border-radius: 16px;
 			font-weight: bold;
		}

		#workspaces button:hover {
  		color: @text;
  		background: linear-gradient(45deg, @surface0, @pink);
  		transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
  		opacity: 0.8;
  		border-radius: 4px;
  		font-weight: bold;
		}

		tooltip {
			background: @base;
			border: 1px solid @base08;
			border-radius: 12px;
		}

		tooltip label {
			color: @pink;
		}

		#window, #pulseaudio, #cpu, #memory {
  		background: @surface0;
  		color: @text;
		  border-radius: 24px 10px 24px 10px;
		  padding: 0px 18px;
		  margin: 0px 4px;
  		margin-left: 7px;
  		font-weight: bold;
		}

		#clock, #network, #tray {
  		background: @flamingo;
  		color: @base;
		  border-radius: 10px 24px 10px 24px;
		  padding: 0px 18px;
  		margin: 4px 0px;
  		margin-right: 7px;
  		font-weight: bold;
		}

		#cpu.warning,#memory.warning{
 			color: @red;
		}
		'';
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
								months = "<span color='#74c7ec'><b>{}</b></span>";
								days = "<span color='#f2cdcd'><b>{}</b></span>";
								weeks = "<span color='#f9e2af'><b>{}</b></span>";
								weekdays = "<span color='#f9e2af'><b>{}</b></span>";
								today = "<span color='#f38ba8'><b>{}</b></span>";
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
