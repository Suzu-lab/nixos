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

  outputs = inputs @ { self, nixpkgs, home-manager, zen-browser, ... }:
    let
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit home-manager zen-browser; };	# Passing home-manager as an argument to the host configuration files
        modules = [ hostPath ];
      };
  in {
    nixosConfigurations = {
      vm = mkHost ./hosts/vm/default.nix;
    };
  };
}
