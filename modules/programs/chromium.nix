# Configuration options for ungoogled-chromium (used as a messaging app instead of Ferdium or other Electron-based solutions)
{ config, lib, pkgs, ... }:
let
  cfg = config.suzu.programs.chromium;
in
{
  options.suzu.programs.chromium.enable =
    lib.mkEnableOption "ungoogled-chromium browser";

  config = lib.mkIf cfg.enable {
    hm.programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };
  };
}
