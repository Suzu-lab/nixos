# Home-manager config for Niri
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.desktop.niri;
in
{
  # Imports needed modules
  imports = [
    inputs.niri.nixosModules.niri
    ./displays.nix
    ./keybinds.nix
    ./niri-theme.nix
  ];
  
  options.suzu.desktop.niri = {
    enable = lib.mkEnableOption "Niri Desktop";
  };

  config = lib.mkIf cfg.enable {

    # Enables graphic server without X
    services.xserver.enable = false;

    programs.niri.enable = true;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri.package = pkgs.niri-stable;

    hm = {
      # Global variables for forcing wayland wherever possible
      home.sessionVariables = {
        NIXOS_OZONE_WL = "1"; # Electron apps/Steam
        OZONE_PLATFORM = "wayland";
        #  	GDK_BACKEND = "wayland,x11";				# GTK apps
        QT_QPA_PLATFORM = "wayland;xcb"; # Qt apps
        SDL_VIDEODRIVER = "wayland,x11"; # SDL
        _JAVA_AWT_WM_NONREPARENTING = "1"; # Java/Swing
      };

      # Required services
      services.cliphist.enable = true;
      programs.swappy.enable = true;
      programs.wlogout.enable = true;

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
          spawn-at-startup = [ 
            { argv = ["niriswitcher"]; }
          ];

          # Configuring layout
          layout = {
            empty-workspace-above-first = true; # Makes it so workspaces can be created up and down
            always-center-single-column = true; # Makes it so if there's only one column it will be in the centro of the screen
            gaps = 10; # gapes between windows in pixels

#            focus-ring = {
#              width = 3;
#              active.color = "#ffc87f";
#              inactive.color = "#505050";
#              urgent.color = "#9b0000";
#            };

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
    };
  };
}
