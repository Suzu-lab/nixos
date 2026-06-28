{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "netdata"
  ];
  services.netdata.package = pkgs.netdata.override {
    withCloudUi = true;
  };
  services.netdata = {
    enable = true;
    config.global = {
      "memory mode" = "ram";
      "debug log" = "none";
      "access log" = "none";
      "error log" = "syslog";
    };
  };
  networking.firewall.allowedTCPPorts = [ 19999 ];
}