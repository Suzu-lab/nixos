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
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia-shell (Quickshell based shell to turn Hyprland/Niri/etc into full desktops - replaces stuff like waybar/mako/wofi
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri window compositor - a scrolling Wayland compositor to use instead of Hyprland
    niri = {
#      url = "github:sodiboo/niri-flake"; # Original flake repository, doesn't have newer features
      url = "github:epireyn/niri-flake";  # Fork with support for the blur options from the newest Niri
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

    # Flake for the Deepcool cooler digital display
    ddl.url = "github:mzonski/deepcool-digital-linux";

    # Copyparty — web file server for phone access to my files (replaced Filebrowser).
    # ONLY the NixOS module comes from here: nixpkgs ships the `copyparty` package but NOT
    # `services.copyparty`, which upstream keeps in its own repo (contrib/nixos/modules).
    # Deliberately NOT applying `copyparty.overlays.default` — it overrides the global `python3`
    # package set, a much wider blast radius than this needs, and nixpkgs' own copyparty already
    # builds with thumbnails + ffmpeg, so the stock package is what the module picks up.
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative secret management — encrypted secrets committed to the repo, decrypted at
    # activation into /run/secrets using an age key kept only on the machine.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      niri,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ 
          nur.overlays.default
          niri.overlays.niri
        ] ++ (import ./overlays/default.nix);
        config.allowUnfree = true;
        config.rocmSupport = false;
      };
      
      username = "suzu";
    in
    {
      nixosConfigurations = {
        yosai = nixpkgs.lib.nixosSystem {
          inherit system;

          pkgs = pkgs;

          specialArgs = {
            inherit
              inputs
              system
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