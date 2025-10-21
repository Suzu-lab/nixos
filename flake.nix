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

		# Stylix flake
		stylix = {
			url = "github:nix-community/stylix/";
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
  };

  outputs = { self, nixpkgs, ... }@inputs:
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
      	specialArgs = { inherit inputs mypkgs; };
      	modules = [
      		./hosts/yosai/default.nix
      	];
	  	};
  	};
  };
}
