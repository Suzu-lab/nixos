# gThumb config
{ config, lib, pkgs, ... }:
let
  cfg = config.suzu.programs.gthumb;
in
{
  options.suzu.programs.gthumb.enable = lib.mkEnableOption "gThumb image viewer";

  config = lib.mkIf cfg.enable {
    hm = {
      # Install through Home-Manager
      home.packages = with pkgs; [
        # Installed with plugins
        gthumb
      ];

      # Declarative config through dconf.
      # NOTE: the real schema path is lowercase `gthumb` (not `gThumb`), and the
      # keys below are the actual gsettings keys — the previous config used a
      # wrong path/keys and silently did nothing.
      dconf.settings = {
        "org/gnome/gthumb/browser" = {
          # Ignore hidden files by default
          show-hidden-files = false;
          # Navigate images in file-name order (ascending), so browsing an
          # image folder follows the same order the file manager shows.
          sort-type = "file::name";
          sort-inverse = false;
        };
      };
    };
  };
}
