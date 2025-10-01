{
  description = "NixOS + Home Manager base setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit home-manager; };	# Passing home-manager to as an argument to the host configuration files
        modules = [ hostPath ];
      };
  in {
    nixosConfigurations = { 
      vm = mkHost ./hosts/vm/default.nix;
    };
  };
}
