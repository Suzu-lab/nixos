{ config, pkgs, ... }:
{
	programs.kitty = {
		enable = true;
		shellIntegration.enableFishIntegration = true;

		font.name = "Noto Mono";
	};
}

