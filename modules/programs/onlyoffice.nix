# Declaratively setting OnlyOffice
{ config, lib, pkgs, ... }:
let
  cfg = config.suzu.programs.onlyoffice;
in
{
  options.suzu.programs.onlyoffice.enable =
    lib.mkEnableOption "OnlyOffice desktop editors (custom newer build)";

  config = lib.mkIf cfg.enable {
    hm.programs.onlyoffice = {
      enable = true;
      # Customized derivation for newest version of OnlyOffice (from the overlay)
      package = pkgs.onlyoffice-update;
    };
  };
}
