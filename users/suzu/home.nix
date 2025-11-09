	# Home-manager user suzu
	{ inputs, pkgs, mypkgs, catppuccin, ... }:
  {
		home-manager = {
			users.suzu = {
				imports = [
					catppuccin.homeModules.catppuccin
			  	../../modules/home-manager/cli/fish.nix     # import module for fish cli shell
				  ../../modules/home-manager/cli/git.nix
				  ../../modules/home-manager/cli/micro.nix
				  ../../modules/home-manager/desktop/hyprland.nix # module for configuring Hyprland
				  ../../modules/home-manager/desktop/fonts.nix
			  	../../modules/home-manager/desktop/desktop-entries.nix # module for custom desktop entries

					# Modules for specific programs and configurations
					../../modules/home-manager/apps/firefox.nix
				  ../../modules/home-manager/apps/floorp.nix 	# floorp (browser)
					../../modules/home-manager/apps/mpv.nix	# mpv (video player)
					../../modules/home-manager/apps/thunar.nix 		# Thunar
					../../modules/home-manager/apps/vscodium.nix 	# VS Codium
				  ../../modules/home-manager/apps/zen.nix 				# Zen browser (flake)
				];

				home.username = "suzu";
				home.homeDirectory = "/home/suzu";
    		home.stateVersion = "25.05";

	 	    programs.home-manager.enable = true;

	#			programs.onlyoffice.enable = true;

	 	    # User packages
 		    home.packages = with pkgs; [
					#################################################################
					# User programs
					#################################################################
 	    		imv


					# Customized derivation for OnlyOffice 9.0.4
					mypkgs.onlyoffice-904
					# Customized derivation for Ferdium 7.1.1 (newer Electron)
					mypkgs.ferdium-711

					#################################################################
					# Utilities and backends
					#################################################################
					unzip
					p7zip
					unrar
					yt-dlp
 	  	  ];
  	  };
	  };
	}
