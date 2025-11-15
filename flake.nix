{
  description = "NixOS + Home Manager base setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager flake
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix user repo (NUR) - has extensions for Firefox/Zen Browser already packaged
    nurpkgs = {
    	url = "github:/nix-community/NUR";
    	inputs.nixpkgs.follows = "nixpkgs";
    };

		# Catpuccin theme flake
		catppuccin = {
		  url = "github:catppuccin/nix";
		  inputs.nixpkgs.follows = "nixpkgs";
		};

		# NixOwOs mainly as a joke (changes system name and fetch logos)
		nixowos = {
      url = "github:yunfachi/nixowos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
		
		# Noctalia-shell (Quickshell based shell to turn Hyprland/Niri/etc into full desktops - replaces stuff like waybar/mako/wofi
		noctalia-shell = {
			url = "github:noctalia-dev/noctalia-shell";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Niri window compositor - a scrolling Wayland compositor to use instead of Hyprland
		niri = {
			url = "github:sodiboo/niri-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};

    # Zen browser flake
    zen-browser = {
    	url = "github:0xc000022070/zen-browser-flake";
      inputs = {
				home-manager.follows = "home-manager";
      	nixpkgs.follows = "nixpkgs";
      };
    };

    # Flake for Hyprland to use the cool plugins by Vaxrys.
    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
    	url = "github:hyprwm/hyprland-plugins";
    	inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, catppuccin, nixowos, noctalia-shell, niri, ... }@inputs:
	let
		pkgs = nixpkgs.legacyPackages.x86_64-linux;
		mypkgs = import ./pkgs { inherit pkgs; };
	in
 	{
    nixosConfigurations = {
      vm = nixpkgs.lib.nixosSystem {
      	system = "x86_64-linux";
      	specialArgs = { inherit inputs; };
      	modules = [
      		./hosts/vm/default.nix
      	];
      };
      yosai = nixpkgs.lib.nixosSystem {
      	system = "x86_64-linux";
      	specialArgs = { inherit inputs mypkgs catppuccin nixowos noctalia-shell niri; };
      	modules = [
      		./hosts/yosai/default.nix
      	];
	  	};
  	};
  };
}
