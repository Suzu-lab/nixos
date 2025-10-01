{
 description = "NixOS + Home Manager base setup";

 inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  home-manager.url = "github:nix-community/home-manager/release-25.05";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
 };

 outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
   forSystem = system: pkgs: {
   };
  in {
   nixosConfigurations = { 
    vm = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     modules = [
      ./configuration.nix
      home-manager.nixosModules.home-manager
      {
       programs.home-manager.enable = true;
       home-manager.useGlobalPkgs = true;
       home-manager.useUserPackages = true;
       home-manager.users.suzu = {
        home.stateVersion = "25.05";
       };
      }
     ];
    };
   };
  };
}
