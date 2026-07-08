{ config, lib, ... }:
let
  cfg = config.suzu.programs.kitty;
in
{
  options.suzu.programs.kitty.enable = lib.mkEnableOption "Kitty terminal";

  config = lib.mkIf cfg.enable {
    hm.programs.kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;

      font.name = "Noto Mono";
    };
  };
}
