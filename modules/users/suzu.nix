# Home-manager usuário suzu

  { pkgs, ... }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.suzu = {
      home.stateVersion = "25.05";
    };
  }
