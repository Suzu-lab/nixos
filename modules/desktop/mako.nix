# Config file for setting up mako as a Home Manager module
{ pkgs, inputs, ... } : {
	home-manager.users.suzu = {
		services.mako = {
			enable = true;
			# Configuration settings for mako
			settings = {
				"actionable=true" = {
					anchor = "top-left";
				};
				actions = true;
				anchor = "top-right";
				default-timeout = 5000;
				layer = "top";
			};
		};
	};
}
