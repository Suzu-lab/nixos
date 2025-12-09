# Split module for setting up Hyprland layouts
{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.suzu.desktop.hyprland.enable {
    hm.wayland.windowManager.hyprland = {
      settings = {

        ###############################################
        # Eye-candy
        ###############################################
        # Gaps between windows
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          resize_on_border = "true";
          "col.active_border" = "$accent $base 45deg";
          "col.inactive_border" = "$base $mantle 45deg";
          "col.nogroup_border_active" = "$accent $mantle 45deg";
          "col.nogroup_border" = "$mantle $base 45deg";
        };

        # Decorations
        decoration = {
          # Rounded corners
          rounding = 6;
          rounding_power = 2;
          # Shadows on windows
          shadow = {
            enabled = "true";
            range = 4;
            render_power = 3;
            color = "rgba($maroonAlphaee)";
          };
          # Window blur
          blur = {
            enabled = "true";
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        group = {
          "col.border_active" = "$accent $crust 45deg";
          "col.border_inactive" = "$crust $mantle 45deg";
          "col.border_locked_active" = "$accent $surface0 45deg";
          "col.border_locked_inactive" = "$surface0 $base 45deg";
          groupbar = {
            text_color = "$text";
            text_color_inactive = "$subtext1";
          };
        };

        # Animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
        animations = {
          enabled = 1;
          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
          animation = [
            "global,1,10,default"
            "border,1,5.39,easeOutQuint"
            "windows,1,4.79,easeOutQuint"
            "windowsIn,1,4.1,easeOutQuint,popin 87%"
            "windowsOut,1,1.49,linear,popin 87%"
            "fadeIn,1,1.73,almostLinear"
            "fadeOut,1,1.46,almostLinear"
            "fade,1,3.03,quick"
            "layers,1,3.81,easeOutQuint"
            "layersIn,1,4,easeOutQuint,fade"
            "layersOut,1,1.5,linear,fade"
            "fadeLayersIn,1,1.79,almostLinear"
            "fadeLayersOut,1,1.39,almostLinear"
            "workspaces,1,1.94,almostLinear,fade"
            "workspacesIn,1,1.21,almostLinear,fade"
            "workspacesOut,1,1.94,almostLinear,fade"
          ];
        };
      };
    };
  };
}
