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
      config = {
        global = {
          "memory mode" = "ram";
          "debug log" = "none";
          "access log" = "none";
          "error log" = "syslog";
        };
        # Bind to localhost only. Desktop access is http://localhost:19999; the phone reaches it over
        # Tailscale serve (modules/nixos/tailscale.nix) — so it's no longer exposed on the LAN.
        web."bind to" = "127.0.0.1";
      };
      package = pkgs.netdata.override {
        withCloudUi = true;
      };
    };
  };
}
