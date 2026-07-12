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
  inherit (lib) mkEnableOption mkIf mkOption types;
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
    enable = mkEnableOption "Niri Desktop";
  };

  config = mkIf cfg.enable {

    # Enables graphic server without X
    services.xserver.enable = false;

    programs.niri.enable = true;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;

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
#      programs.niriswitcher = {
#        enable = true;
#      };

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
            {
              # Noctalia 5.0.0 renamed the binary from "noctalia-shell" to "noctalia".
              command = ["noctalia"];
            }
          ] ++ lib.optionals config.suzu.ai.companionHost.enable [
            # Autostart the AI companion. The window rule below pins her avatar fullscreen on
            # the Hyte Y70 (DP-2); the app retries the backend WS until the docker stack is up.
            { command = [ "companion" ]; }
          ] ++ lib.optionals config.suzu.system.remoteAccess.enable [
            # Phone control panel (ai-cockpit): HTTP server on 127.0.0.1:8090, published to the
            # tailnet by Tailscale serve (:443). Spawned here so it inherits the graphical session —
            # docker + niri/noctalia — for its gpu/display actions. See modules/nixos/tailscale.nix.
            { command = [ "ai-cockpit" ]; }
          ];
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
              background-effect = {
                blur = true;
                xray = false;
              };
            }
            {
              matches = [ { app-id = "kitty"; } ];
              opacity = 0.9;
            }
            {
              # Float Nemo's Properties dialog (glance-and-close) instead of
              # letting Niri tile it as a new column. The dialog shares Nemo's
              # app-id, so we also match its title, which contains "Properties"
              # (the main window's title is the folder name).
              matches = [ { app-id = "^nemo$"; title = "Properties"; } ];
              open-floating = true;
            }
            {
              # Privacy for the AI companion's screen vision (Phase 7): render these
              # windows as black rectangles in screen-captures/screenshots only, so the
              # vision model structurally cannot see secrets even mid screen-share.
              matches = [ { app-id = "(?i)keepassxc|bitwarden|1password|proton.?pass|signal"; } ];
              block-out-from = "screen-capture";
            }
            {
              # AI companion avatar: pin it fullscreen on the Hyte Y70 touchscreen (DP-2).
              matches = [ { app-id = "^companion-client$"; title = "Avatar$"; } ];
              open-on-output = "DP-2";
              open-fullscreen = true;
            }
            {
              # AI companion text prompt: floating panel on the main screen (summon: Mod+G).
              matches = [ { app-id = "^companion-client$"; title = "Prompt$"; } ];
              open-floating = true;
            }
            {
              # Steam/Proton games (XWayland via xwayland-satellite) present as
              # borderless-windowed and otherwise tile *below* the Noctalia bar.
              # Force real fullscreen so they cover the whole output, bar included.
              # This makes the old gamescope launch-option workaround unnecessary
              # (nested gamescope caused ~25min frame-pacing stalls). Window app-id
              # is "steam_app_<id>", e.g. steam_app_2070270 (Cloudheim).
              matches = [ { app-id = "^steam_app_[0-9]+$"; } ];
              # Exclude idle/utility games that should stay a normal, resizable
              # column (Mod+S/D/F) instead of being forced fullscreen.
              #   steam_app_2763740 = Revolution Idle
              excludes = [ { app-id = "^steam_app_2763740$"; } ];
              open-fullscreen = true;
            }
          ];

          # Adds correct xwayland satellite path
          xwayland-satellite.path = "${lib.getExe pkgs.xwayland-satellite-unstable}";

          debug = {
            # Allows notification actions and window activation from Noctalia
            honor-xdg-activation-with-invalid-serial = [ ];
          };

          # Sets up blurred wallpapers in Overview
          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-backdrop*"; } ];
              place-within-backdrop = true;
            }
            {
              matches = [ { namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"; } ];
              background-effect = {
                xray = false;
                # blur = false;
              };
            }
          ];
        };
      };
    };
  };
}
