# Git config (ssh keys must be manually created and set in github)
{ config, lib, ... }:
let
  cfg = config.suzu.cli.git;
in
{
  options.suzu.cli.git.enable =
    lib.mkEnableOption "Git and SSH client configuration";

  config = lib.mkIf cfg.enable {
    hm = {
      programs.git = {
        enable = true;
        settings = {
          user.name = "Suzu-lab";
          user.email = "sou.suzumi@gmail.com";
          extraConfig = {
            # QoL
            init.defaultBranch = "main";
            pull.rebase = false;
            github.user = "Suzu-lab";
          };
        };
      };
      # Configure SSH
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        # `settings` replaces the deprecated `matchBlocks`. Attribute names are
        # `Host` patterns and values use ssh_config directive casing (AddKeysToAgent).
        settings = {
          "sou.suzumi@gmail.com" = {
            AddKeysToAgent = "yes";
          };
        };
      };
    };
  };
}
