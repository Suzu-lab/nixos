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
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
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
						# User config
						home-manager.users.suzu = userConfig;
					}
        ];
      };
  in {
    nixosConfigurations = {
      vm = mkHost {
      	hostPath = ./hosts/vm/default.nix;
      	userConfig = import ./modules/users/suzu.nix;
    	};
  	};
  };
}
