  # Home-manager user suzu

  { inputs, pkgs, ... }: {
    home.username = "suzu";
    home.homeDirectory = "/home/suzu";
    home.stateVersion = "25.05";

    imports = [
      ../../modules/home-manager/cli/fish.nix     # import module for fish cli shell
      ../../modules/home-manager/desktop/hyprland/default.nix # module for configuring Hyprland
      ../../modules/home-manager/desktop/fonts.nix
      ../../modules/home-manager/apps/zen.nix # specific Zen browser config
    ];

    home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";
    programs.home-manager.enable = true;

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
