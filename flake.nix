{
  description = "NixOS + Home Manager base setup";

  # Enabling cachix
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mypkgs = import ./pkgs { inherit pkgs; };
      username = "suzu";
    in
    {
      nixosConfigurations = {
        yosai = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit
              inputs
              mypkgs
              username;
          };
          modules = [
            ./hosts/yosai/configuration.nix
            ./users/home.nix
            
            home-manager.nixosModules.home-manager
          ];
        };
      };
    };
}