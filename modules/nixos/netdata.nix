{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  services.netdata = {
    enable = true;
    config.global = {
      "memory mode" = "ram";
      "debug log" = "none";
      "access log" = "none";
      "error log" = "syslog";
    };
  };
    services.netdata.package = pkgs.netdata.override {
    withCloudUi = true;
  };
  networking.firewall.allowedTCPPorts = [ 19999 ];
}