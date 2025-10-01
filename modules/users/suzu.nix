  # Home-manager user suzu

  { pkgs, ... }: {
    home.username = "suzu";
    home.homeDirectory = "/home/suzu";
    home.stateVersion = "25.05";
    
    imports = [
      ../cli-fish.nix     # import module for fish cli shell
    ];

    shell = pkgs.fish;
    programs.home-manager.enable = true;
  }
