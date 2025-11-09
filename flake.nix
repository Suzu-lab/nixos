{
  description = "NixOS + Home Manager base setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager flake
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		# Textfox flake - cool theme for Firefox based browsers (except Zen)
		textfox.url = "github:adriankarlen/textfox";

    # Nix user repo (NUR) - has extensions for Firefox/Zen Browser already packaged
    nurpkgs = {
    	url = "github:/nix-community/NUR";
    	inputs.nixpkgs.follows = "nixpkgs";
    };

		# Stylix flake - theming for NixOS
		stylix = {
			url = "github:nix-community/stylix/";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Catpuccin flake - even better theming
		catppuccin = {
		  url = "github:catppuccin/nix";
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

  outputs = { self, nixpkgs, catppuccin, ... }@inputs:
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
      	specialArgs = { inherit inputs mypkgs catppuccin; };
      	modules = [
      		./hosts/yosai/default.nix
      	];
	  	};
  	};
  };
}
