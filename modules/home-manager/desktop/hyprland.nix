# Module for setting and configuring the basic Hyprland desktop
{
  lib,
  pkgs,
  config,
  inputs,
  pkgs-stable,
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
    #			./hyprpaper.nix
    #			./mako.nix
    #			./waybar.nix
    #			./wofi.nix
    ./hyprland/layouts.nix
    ./hyprland/decorations.nix
  ];

  # Global variables for forcing wayland wherever possible
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron apps/Steam
    QT_QPA_PLATFORM = "wayland"; # Qt apps
    SDL_VIDEODRIVER = "wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    OZONE_PLATFORM = "wayland";
  };

  # Required services
  services.cliphist.enable = true;
  programs.swappy.enable = true;
  programs.wlogout.enable = true;
  
  # Base apps required for Hyprland
  home.packages =
    (with pkgs; [
      ######################################################
      # Tools for Hyprland
      ######################################################
      grim
      hyprlock
      hyprpaper
      hyprpicker
      polkit_gnome
      slurp
      wl-clipboard
      pavucontrol
      pamixer
    ])
    ++ (with pkgs-stable; [
      kdePackages.xwaylandvideobridge
    ]);

  # Declarative config files for the desktop environment
  wayland.windowManager.hyprland =
    let
      hyprpkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
      hyprplugins = inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      #Using Hyprlands packages from the flake (to make plugins work)
      package = hyprpkg.hyprland;
      portalPackage = hyprpkg.xdg-desktop-portal-hyprland;

      #Set up plugins (from the flake)
      plugins = [
        hyprplugins.hyprexpo # Workspace overview
        #					hyprplugins.hyprtrails #Window trails - purely aesthetics
        #					hyprplugins.hyprscrolling #Scrolling layout
      ];

      settings = {
        # Default apps and mainmod variable
        "$mainMod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "kitty -e yazi";
        #  				"$menu" = "pkill wofi ; wofi --show drun --allow-images";
        #  				"$cliphist" = "pkill wofi ; cliphist list | wofi --dmenu | cliphist decode | wl-copy";
        #				"$printscreen" = "bash -c 'grim -g \"$(slurp -w 0)\" - | swappy -f -'";
        "$menu" = "noctalia-shell ipc call launcher toggle";
        "$cliphist" = "noctalia-shell ipc call launcher wl-clipboard";

        # Autostart
        exec-once = [
          "waybar"
          "hyprpaper"
          "mako"
          "cliphist store"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "xwaylandvideobridge"
        ];

        # Environment variables
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        # Options for the plugins
        plugin = {
          hyprexpo = {
            columns = 2;
            gap_size = 5;
            workspace_method = "first 1";
            gesture_distance = 300;
          };
        };

        # Keyboard
        input = {
          kb_layout = "us";
          kb_variant = "intl";
          follow_mouse = 1;
        };

        ###############################################
        # Displays
        ###############################################

        monitor = [
          # Main display
          "DP-1, highres, 0x0, 1, vrr, 1"
          # Hyte display (right)
          "DP-2, preferred, 3840x0, auto, vrr, 1, transform, 3"
          # LG Ultrawide display 1 (top)
          "DP-3, preferred, 620x-1080, 1, vrr, 1, transform, 2"
          # LG Ultrawide display 2 (left)
          "HDMI-A-1, highres, -1080x-200, 1, vrr, 1, transform, 1"
        ];

        # Workspace rules (for assigning workspaces to the monitors)
        workspace = [
          "r[1], monitor:DP-1"
          "r[2], monitor:DP-1"
          "r[3], monitor:DP-1"
          "r[4], monitor:DP-1"
          "r[5], monitor:DP-1"
          "r[6], monitor:DP-1"
          "r[7], monitor:DP-1"
          "r[8], monitor:DP-1"
          "r[9], monitor:DP-1"
          "r[10], monitor:DP-1"
          "name:communication, monitor:HDMI-A-1, default:true, persistent:true"
          "name:video, monitor:DP-3, default:true, persistent:true"
          "name:panel, monitor:DP-2, default:true, persistent:true"
        ];

        # Windows rules
        windowrule = [
          # Ignore maximiza requests from apps
          #						"suppressevent maximize,class:.*"
          # Fix dragging issues with XWayland
          #						"nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
          # Make pavucontrol open as a small floating window
          #						"float, class:^(org.pulseaudio.pavucontrol)$"
          #						"size 60% 70%, class:^(org.pulseaudio.pavucontrol)$"
          #						"center, class:^(org.pulseaudio.pavucontrol)$"

          # Window rules to hide the xwayland window
          #						"opacity 0.0 override, class:^(xwaylandvideobridge)$"
          #						"noanim, class:^(xwaylandvideobridge)$"
          #						"noinitialfocus, class:^(xwaylandvideobridge)$"
          #						"maxsize 1 1, class:^(xwaylandvideobridge)$"
          #						"noblur, class:^(xwaylandvideobridge)$"
          #						"nofocus, class:^(xwaylandvideobridge)$"
        ];

        # Keybindings
        bind = [
          "$mainMod, Q, exec, $terminal"
          "$mainMod, W, exec, hyprctl getoption general:layout | grep -q 'dwindle' && hyprctl keyword general:layout master || hyprctl keyword general:layout dwindle"
          "$mainMod, C, killactive"
          "$mainMod, M, exit"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, exec, $cliphist"
          "$mainMod, R, exec, $menu"
          "$mainMod, P, togglefloating,"
          "$mainMod, J, togglesplit,"
          "$mainMod, X, exec, wlogout"
          "$mainMod SHIFT, R, exec, hyprctl reload"
          # Screenshot
          ", Print, exec, bash -c 'grim -g \"$(slurp -w 0)\" - | swappy -f -'"

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Use hyprexpo
          "$mainMod, space, hyprexpo:expo, toggle"

          # Keybinds specific to hyprscrolling
          "$mainMod, mouse_left, layoutmsg, colresize -conf"
          "$mainMod, mouse_right, layoutmsg, colresize +conf"
          "$mainMod, F, layoutmsg, fit visible"
          "$mainMod SHIFT, left, layoutmsg, movewindowto l"
          "$mainMod SHIFT, right, layoutmsg, movewindowto r"
          "$mainMod SHIFT, up, layoutmsg, movewindowto u"
          "$mainMod SHIFT, down, layoutmsg, movewindowto d"
        ];
        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
}
