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
    };

    imports = [
      ../../modules/cli/fish.nix     # import module for fish cli shell
      ../../modules/desktop/hyprland.nix # module for configuring Hyprland
      ../../modules/desktop/fonts.nix
			../../modules/apps/thunar.nix # Thunar config
      ../../modules/apps/zen.nix # specific Zen browser config
    ];

		# User packages
		home.packages = with pkgs; [
			######################################################
			# Tools for Hyprland
			######################################################
			cliphist
			grim
			hyprlock
			hyprpaper
			kitty
			mako
			polkit_gnome
			slurp
			waybar
			wl-clipboard
			wofi
			xarchiver

			#######################################################
			evince
		];


  }
