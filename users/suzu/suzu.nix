  # Home-manager user suzu

  { inputs, pkgs, ... }: {

		users.users.suzu = {
			isNormalUser = true;
		  extraGroups = [ "wheel" "networkmanager" ];
		  ignoreShellProgramCheck = true;
		  shell = pkgs.fish;	# Defines fish as default user shell
		};
		  security.sudo.wheelNeedsPassword = true;

		home-manager.users.suzu = {
			home.username = "suzu";
			home.homeDirectory = "/home/suzu";
    	home.stateVersion = "25.05";

 	    programs.home-manager.enable = true;

			programs.onlyoffice.enable = true;

 	    # User packages
 	    home.packages = with pkgs; [
				#################################################################
				# User programs
				#################################################################
 	    	evince
				ferdium

				#################################################################
				# Utilities and backends
				#################################################################
				unzip
				p7zip
				unrar
 	    ];
    };

    imports = [
      ../../modules/cli/fish.nix     # import module for fish cli shell
      ../../modules/desktop/hyprland.nix # module for configuring Hyprland
      ../../modules/desktop/fonts.nix
      ../../modules/desktop/desktop-entries.nix # module for custom desktop entries

			# Modules for specific programs and configurations
			../../modules/apps/celluloid.nix	# Celluloid (mpv wrapper)
			../../modules/apps/gthumb.nix			# gthumb (image viewer)
			../../modules/apps/thunar.nix 		# Thunar
			../../modules/apps/vscodium.nix 	# VS Codium
      ../../modules/apps/zen.nix 				# Zen browser (flake)
    ];
  }
