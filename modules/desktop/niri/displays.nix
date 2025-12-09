{
  config,
  lib,
  ...
}:
{
  # Monitor config
  config = lib.mkIf config.suzu.desktop.niri.enable {
    hm.programs.niri.settings.outputs = {
      # Main display
      "DP-1" = {
        enable = true;
        #        scale = 1;
        #        focus-at-startup = true;
        mode = {
          width = 3840;
          height = 2160;
          refresh = 143.856;
        };
        position = {
          x = 0;
          y = 0;
        };
        transform.rotation = 0;
        variable-refresh-rate = "on-demand";
      };
      # Hyte display (right)
      "DP-2" = {
        enable = true;
        mode = {
          width = 2560;
          height = 682;
          refresh = 73.778;
        };
        position = {
          x = 3072;
          y = 600;
        };
        transform.rotation = 270;
      };
      # LG Ultrawide display 1 (top)
      "DP-3" = {
        enable = true;
        mode = {
          width = 2560;
          height = 1080;
          refresh = 74.991;
        };
        position = {
          x = 256;
          y = -1080;
        };
        transform.rotation = 180;
      };
      # LG Ultrawide display 2 (left)
      "HDMI-A-1" = {
        enable = true;
        mode = {
          width = 2560;
          height = 1080;
          refresh = 74.991;
        };
        position = {
          x = -1080;
          y = -516;
        };
        transform.rotation = 90;
      };
    };
  };
}