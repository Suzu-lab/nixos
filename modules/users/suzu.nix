  # Home-manager user suzu

  { pkgs, ... }: {
    home.username = "suzu";
    home.homeDirectory = "/home/suzu";
    home.stateVersion = "25.05";

    imports = [
      ../cli-fish.nix     # import module for fish cli shell
      ../hyprland-suzu.nix
    ];

    home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";
    programs.home-manager.enable = true;

    # Config to create backup of previous config files with home-manager
    home-manager.backupFileExtension = "backup";
  }
