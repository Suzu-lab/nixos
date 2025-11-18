# Home-manager config for Niri
{
  config,
  lib,
  niri,
  pkgs,
  ...
}:
{
  # Imports needed modules
  imports = [
    ./theme.nix
    ../apps/kitty.nix
    ../apps/yazi.nix
    ../apps/zathura.nix
    ../cli/fcitx5.nix
    #		niri.homeModules.niri
  ];

  # Global variables for forcing wayland wherever possible
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron apps/Steam
    OZONE_PLATFORM = "wayland";
    #  	GDK_BACKEND = "wayland,x11";				# GTK apps
    QT_QPA_PLATFORM = "wayland;xcb"; # Qt apps
    SDL_VIDEODRIVER = "wayland,x11"; # SDL
    _JAVA_AWT_WM_NONREPARENTING = "1"; # Java/Swing
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
  };

  # Required services
  services.cliphist.enable = true;
  programs.swappy.enable = true;
  programs.wlogout.enable = true;

  systemd.user.services = {
    # Enables Polkit GNOME authentication agent at system level
    polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "Polkit GNOME Authentication Agent";
      };
      Service = {
        ExecStart = "{pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
      Install = {
        Wantedby = [ "graphical-session.target" ];
      };
    };
  };

  home.packages = with pkgs; [
    wl-clipboard
    wayland-utils
    libsecret
    cage
    xwayland-satellite-unstable
  ];

  # Set up niriswitcher (fancy alt+tab for Niri)
  programs.niriswitcher = {
    enable = true;
  };

  # Declarative settings for Niri
  programs.niri = {
    settings = {
      prefer-no-csd = true; # asks programs to not show client side decorations
      input = {
        keyboard = {
          repeat-delay = 200; # solves keyboard auto repeat
          repeat-rate = 35;
        };
        warp-mouse-to-focus.enable = true; # makes cursor move to the newly focused window
        focus-follows-mouse.enable = true; # makes so the window focus automatically follows the mouse cursor;
      };

      # Monitor config
      outputs = {
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

      # Sets keybindings for Niri
      binds = with config.lib.niri.actions; {
        "Mod+T".action.spawn = "kitty";
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ]; # Shows the hotkey overlay when pressing Super+?
        "Mod+R".action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "launcher"
          "toggle"
        ]; # Uses the Noctalia-shell launcher
        "Mod+Q" = {
          repeat = false;
          action.close-window = [ ];
        };
        "Print".action.screenshot = [ ];
        "Mod+Space" = {
          repeat = false;
          action.toggle-overview = [ ];
        };
        "Mod+E".action.spawn = "thunar";

        # Binds for Niriswitcher
        "Alt+Tab" = {
          repeat = false;
          action.spawn = [
            "niriswitcherctl"
            "show"
            "--window"
          ];
        };
        "Mod+Tab" = {
          repeat = false;
          action.spawn = [
            "niriswitcherctl"
            "show"
            "--workspace"
          ];
        };

        /*
          The shortcuts below refer to workspaces by index. However, Niri has dynamic workspaces
          so the commands are a "best effort" to index them. Trying to refer to an index bigger than
          the current number of workspaces will instead refer to the bottommost empty one
        */
        # Shortcuts to change focus to other workspaces
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        # Shortcut to move windows to other workspaces
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;

        # Shortcuts for navigating across windows with the keyboard
        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+Up".action.focus-window-or-workspace-up = [ ]; # If it's the top window on a column, jump to the workspace above
        "Mod+Down".action.focus-window-or-workspace-down = [ ]; # If it's the bottom window on a column, jump to the workspace below

        # Shortcuts for moving around windows with the keyboard
        "Mod+Shift+Left".action.move-column-left = [ ];
        "Mod+Shift+Right".action.move-column-right = [ ];
        "Mod+Shift+Up".action.move-window-up-or-to-workspace-up = [ ]; # If it's the top window on a column, move it to the workspace above
        "Mod+Shift+Down".action.move-window-down-or-to-workspace-down = [ ]; # If it's the bottom window on a column, move it to the workspace below

        # Shortcuts for navigating and moving between workspaces
        "Mod+Page_Up".action.focus-workspace-up = [ ];
        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Shift+Page_Up".action.move-column-to-workspace-up = [ ]; # These two commands differ from the commands above because they move the entire column instead of just a window
        "Mod+Shift+Page_Down".action.move-column-to-workspace-down = [ ];

        # Binds for helping navigate with the mouse
        "Mod+WheelScrollUp".action.focus-workspace-up = [ ];
        "Mod+WheelScrollDown".action.focus-workspace-down = [ ];
        "Mod+Shift+WheelScrollUp".action.move-column-to-workspace-up = [ ];
        "Mod+Shift+WheelScrollDown".action.move-column-to-workspace-down = [ ];

        "Mod+WheelScrollLeft".action.focus-column-left = [ ];
        "Mod+WheelScrollRight".action.focus-column-right = [ ];
        "Mod+Shift+WheelScrollLeft".action.move-column-left = [ ];
        "Mod+Shift+WheelScrollRight".action.move-column-right = [ ];

        # Consume and expel binds. Consuming is taking an alone window and inserting it into a column. Expeling is taking a window out of a column into a new one
        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

        # Binds to change the column width
        "Mod+S".action.switch-preset-column-width-back = [ ];
        "Mod+D".action.switch-preset-column-width = [ ];
        "Mod+F".action.maximize-column = [ ];

        # Bind to toggle window into floating mode
        "Mod+V".action.toggle-window-floating = [ ];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

        # Toggle tabbed column display mode. Displays the windows in a column as tabs instead of stacked
        "Mod+W".action.toggle-column-tabbed-display = [ ];

        # Enables you to escape from applications that may force Niri to stop processing shortcuts (like remote desktop and KVM)
        "Mod+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = [ ];
        };
      };

      # Configuring layout
      layout = {
        empty-workspace-above-first = true; # Makes it so workspaces can be created up and down
        always-center-single-column = true; # Makes it so if there's only one column it will be in the centro of the screen
        gaps = 10; # gapes between windows in pixels

        focus-ring = {
          width = 3;
          active.color = "#ffc87f";
          inactive.color = "#505050";
          urgent.color = "#9b0000";
        };

        border.enable = false; # The border is set inside the windows, what is set outside is the focus-ring. Setting the border to inactive.

      };

      # Window rules recommended by Noctalia-shell
      window-rules = [
        {
          matches = [ ];
          # Rounded corners for windows
          geometry-corner-radius = {
            top-left = 20.0;
            top-right = 20.0;
            bottom-left = 20.0;
            bottom-right = 20.0;
          };
          # Clips windows contents to the rounded corner
          clip-to-geometry = true;
        }
        {
          matches = [ { app-id = "kitty"; } ];
          opacity = 0.9;
        }
      ];

      debug = {
        # Allows notification actions and window activation from Noctalia
        honor-xdg-activation-with-invalid-serial = [ ];
      };

      # Sets up blurred wallpapers in Overview
      layer-rules = [
        {
          matches = [ { namespace = "^noctalia-overview*"; } ];
          place-within-backdrop = true;
        }
      ];
    };
  };
}
