{ config, pkgs, ... }:
{
	home-manager.users.suzu = {
		program.kitty = {
			enable = true;
			shellIntegration.enableFishIntegration = true;
		};
	};
}
