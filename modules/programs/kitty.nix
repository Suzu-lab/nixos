{ config, pkgs, ... }:
{
  hm.programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;

    font.name = "Noto Mono";
  };
}
