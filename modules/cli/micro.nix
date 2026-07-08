{ config, lib, ... }:
let
  cfg = config.suzu.cli.micro;
in
{
  options.suzu.cli.micro.enable = lib.mkEnableOption "micro terminal editor";

  config = lib.mkIf cfg.enable {
    hm.programs.micro = {
      enable = true;
      settings = {
        #			colorscheme = "simple";
        tabsize = 2;
      };
    };
  };
}
