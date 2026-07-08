# Nemo file manager (replaces Thunar).
# Chosen for inline rename (no separate dialog window, which Niri mis-tiled) and
# built-in per-folder view/sort memory — so Downloads can stay sorted by date
# while everything else stays alphabetical.
{ config, lib, pkgs, ... }:
let
  cfg = config.suzu.programs.nemo;
in
{
  options.suzu.programs.nemo.enable = lib.mkEnableOption "Nemo file manager";

  config = lib.mkIf cfg.enable {
    hm = {
      home.packages = with pkgs; [
        nemo-with-extensions # bundles nemo-fileroller (archives) and friends
      ];

      # A few sane defaults. Nemo already remembers sort/view per folder, so this
      # only sets the starting point for folders you haven't customized.
      dconf.settings = {
        "org/nemo/preferences" = {
          default-folder-viewer = "list-view";
          default-sort-order = "name";
          show-hidden-files = false;
          date-format = "iso";
        };
      };
    };
  };
}
