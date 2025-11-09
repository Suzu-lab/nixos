{ config, pkgs, ... }:
#let
#	colors = config.lib.stylix.colors;
#in
{
	programs.kitty = {
		enable = true;
		shellIntegration.enableFishIntegration = true;

		font.name = "Noto Mono";

/*		extraConfig =
		with colors.withHashtag; ''
			# Terminal base colors
			background ${base00}
			foreground ${base05}
			cursor ${base06}
			selection_foreground none
			selection_background none
			url_color ${base04}
			active_border_color ${base03}
			inactive_border_color ${base01}
			active_tab_background ${base00}
			active_tab_foreground ${base05}
			inactive_tab_background ${base01}
			inactive_tab_foreground ${base04}
			tab_bar_background ${base01}

			# ANSI colors
			color0 ${base00}
			color1 ${base08}
			color2 ${base0B}
			color3 ${base0A}
			color4 ${base0D}
			color5 ${base0E}
			color6 ${base0C}
			color7 ${base05}

			# ANSI bright colors
			color8  ${base03}
	    color9  ${base09}
    	color10 ${base01}
   	 	color11 ${base02}
   	 	color12 ${base04}
   	 	color13 ${base06}
    	color14 ${base0F}
    	color15 ${base07}
		'';
		*/
	};
}

