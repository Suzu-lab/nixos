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

    # Old Nix-stable packages
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

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

  outputs =
    {
      self,
      nixpkgs,
      catppuccin,
      nixowos,
      noctalia-shell,
      niri,
      nixpkgs-stable,
      ...
    }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      pkgs-stable = nixpkgs-stable.legacyPackages.x86_64-linux;
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
          specialArgs = {
            inherit
              inputs
              mypkgs
              catppuccin
              nixowos
              noctalia-shell
              niri
              pkgs-stable
              ;
          };
          modules = [
            ./hosts/yosai/default.nix

            {
              # Allows the users below to add extra cache servers through the flake file
              nix.settings.trusted-users = [ "suzu" ];
              # Enable cache server to download binaries without needing to compile everything
              nix.settings = {
                substituters = [
                  "https://cache.nixos.org"
                ];

                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                ];
              };
            }
          ];
        };
      };
    };
}