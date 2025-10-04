{
  description = "NixOS + Home Manager base setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager flake
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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

  outputs = { self, nixpkgs, home-manager, zen-browser, ... }@inputs:
    let
			system = "x86_64-linux";
			# pkgs = nixpkgs.legacyPackages.${system};

      mkHost = { hostPath, userConfig }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };	# Export all inputs
        modules = [
        	hostPath 	# path to machine config


					# Home Manager Modules
					# Home-Manager config
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;

						home-manager.backupFileExtension = "backup";

						# Inheritance for Home Manager modules
						home-manager.extraSpecialArgs = { inherit inputs; };

						# User config
						home-manager.users.suzu = import userConfig;
					}
        ];
      };
  in {
    nixosConfigurations = {
      vm = mkHost {
      	hostPath = ./hosts/vm/default.nix;
      	userConfig = ./modules/users/suzu.nix;
    	};
  	};
  };
}
