{ config, pkgs, ... }:
{
	home-manager.users.suzu = {
		programs.kitty = {
			enable = true;
			shellIntegration.enableFishIntegration = true;
		};
	};
}
