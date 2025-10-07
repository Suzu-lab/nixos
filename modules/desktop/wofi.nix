# Config file for setting up Wofi as a Home manager module
{ pkgs, inputs, ... }:{
	home-manager.users.suzu = {
		programs.wofi = {
			enable = true;
			settings = {
				allow_markup = true;
				sort_order = "alphabetical";
			};
		};
	};
}
