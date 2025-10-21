  # Home-manager user suzu
	{ inputs, pkgs, mypkgs, ... }:
  {
		home-manager.users.suzu = {
			imports = [
			  ../../modules/home-manager/cli/fish.nix     # import module for fish cli shell
			  ../../modules/home-manager/cli/git.nix
			  ../../modules/home-manager/desktop/hyprland.nix # module for configuring Hyprland
			  ../../modules/home-manager/desktop/fonts.nix
			  ../../modules/home-manager/desktop/desktop-entries.nix # module for custom desktop entries


			# Modules for specific programs and configurations
				../../modules/home-manager/apps/celluloid.nix	# Celluloid (mpv wrapper)
				../../modules/home-manager/apps/gthumb.nix			# gthumb (image viewer)
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
 	    	evince
				ferdium

				# Customized derivation for OnlyOffice 9.0.4
				mypkgs.onlyoffice-904

				#################################################################
				# Utilities and backends
				#################################################################
				unzip
				p7zip
				unrar
 	    ];
    };
  }
