# Declaratively setting OnlyOffice
{ config, lib, ... }:
let
  cfg = config.suzu.programs.onlyoffice;
in
{
  options.suzu.programs.onlyoffice.enable =
    lib.mkEnableOption "OnlyOffice desktop editors";

  config = lib.mkIf cfg.enable {
    hm.programs.onlyoffice.enable = true;
  };
};
