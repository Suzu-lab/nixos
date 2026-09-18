# module to install and configure solaar for use with the Logitech Master 3S mouse
{
  config,
  lib,
  ...
}:
let
  cfg = config.suzu.system.logitech;
in
{
  options.suzu.system.logitech.enable =
    lib.mkEnableOption "module for solaar for the Logitech master 3S mouse";

  config = lib.mkIf cfg.enable {
    programs.solaar = {
      enable = true;
      userService = {
        enable = true;
        window = "hide";        # only tray, no program window on startup
      };
    };
  };
}
