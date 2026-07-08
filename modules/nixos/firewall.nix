# Service to open firewall ports
{ config, lib, ... }:
let
  cfg = config.suzu.system.firewall;
in
{
  options.suzu.system.firewall.enable =
    lib.mkEnableOption "Firewall with Discord RTC port ranges opened";

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = true;

      # Open ports needed for Discord RTC
      allowedUDPPortRanges = [
        {
          from = 10000;
          to = 60000;
        }
      ];
    };
  };
}
