{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.system.netdata;
in
{
  options.suzu.system.netdata.enable =
    lib.mkEnableOption "Netdata metrics (web UI on port 19999)";

  config = lib.mkIf cfg.enable {
    services.netdata = {
      enable = true;
      config.global = {
        "memory mode" = "ram";
        "debug log" = "none";
        "access log" = "none";
        "error log" = "syslog";
      };
      package = pkgs.netdata.override {
        withCloudUi = true;
      };
    };
    networking.firewall.allowedTCPPorts = [ 19999 ];
  };
}
