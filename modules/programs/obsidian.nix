{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.programs.obsidian;
in
{
  options.suzu.programs.obsidian.enable = lib.mkEnableOption "Obsidian note-taking app";

  # Nix manages ONLY the Obsidian binary. The community plugins live inside the
  # vault at ~/Obsidian/.obsidian/plugins and are version-controlled in the vault's
  # own separate git repo — deliberately decoupled from home-manager so a future
  # move to hjem/nix-maid won't touch them. To (re)seed or update plugins run
  # ~/Obsidian/update-plugins.sh (idempotent; pulls each plugin's latest release).
  config = lib.mkIf cfg.enable {
    hm.home.packages = [ pkgs.obsidian ];
  };
}
