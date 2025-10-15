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

  outputs = { self, nixpkgs, home-manager, nurpkgs, stylix, zen-browser, ... }@inputs:
    let
			system = "x86_64-linux";
			# pkgs = nixpkgs.legacyPackages.${system};

      mkHost = { hostPath }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };	# Export all inputs
        modules = [
        	hostPath 	# path to machine config
					{
						nixpkgs.config = {
							allowUnfree = true;
						};
					}
					# Home Manager Modules
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;

						home-manager.backupFileExtension = "backup";

						# Inheritance for Home Manager modules
						home-manager.extraSpecialArgs = { inherit inputs; };
					}
					# NUR module
					nurpkgs.modules.nixos.default
					# Stylix module
					stylix.nixosModules.stylix
        ];
      };
  in {
    nixosConfigurations = {
      vm = mkHost {
      	hostPath = ./hosts/vm/default.nix;
    	};
  	};
  };
}
