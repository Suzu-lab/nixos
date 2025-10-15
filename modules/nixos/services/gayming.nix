	# All the packages and configs required for some hardcore gayming
	{ config, pkgs, ... }:
	{
		config = {
			programs.gamemode.enable = true;

			# Install Steam and open firewall rules for it
			programs.steam = {
				enable = true;
				remotePlay.openFirewall = true;
				dedicatedServer.openFirewall = true;
			};

			environmnet.systemPackages = with pkgs; [
				protonup-qt
			];
		};
	}
