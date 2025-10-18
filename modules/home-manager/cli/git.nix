	# Git config (ssh keys must be manually created and set in github)
	{ pkgs, ... }:
	{
		programs.git = {
			enable = true;
			userName = "Suzu-lab";
			userEmail = "sou.suzumi@gmail.com";
			extraConfig = {
				# QoL
				init.defaultBranch = "main";
				pull.rebase = false;
				github.user = "Suzu-lab";
			};
		};
		# Configure SSH
		programs.ssh = {
			enable = true;
			enableDefaultConfig = false;
			matchBlocks = {
				"sou.suzumi@gmail.com" = {
					addKeysToAgent = "yes";
				};
			};
		};
	}
