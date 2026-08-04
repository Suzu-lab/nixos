# Enables essential services for a desktop environment
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.suzu.system.guiEssentials;

  # Single source of truth for the box-wide Wayland environment. Applied twice below because the
  # two scopes reach different processes and neither subsumes the other:
  #   environment.sessionVariables    -> PAM/login env, inherited by the greetd-launched session
  #   hm.systemd.user.sessionVariables -> the systemd --user manager, for user services that are
  #                                       started outside the login-shell env
  # Per-compositor tweaks layer on top of this (see modules/desktop/niri/niri.nix).
  waylandEnv = {
    NIXOS_OZONE_WL = "1"; # Electron apps/Steam
    QT_QPA_PLATFORM = "wayland"; # Qt apps
    # Qt reads the GTK theme/colours/fonts via its built-in qgtk3 platform theme plugin, so Qt apps
    # inherit whatever Noctalia painted into GTK — one theme to configure instead of two. Replaced
    # "qt5ct" (which needs a separate, manually-maintained Qt theme) on 2026-08-03. Noctalia does
    # have a `qt` template, but it writes qt5ct colour files, which nothing reads in this setup.
    QT_QPA_PLATFORMTHEME = "gtk3";
    SDL_VIDEODRIVER = "wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    OZONE_PLATFORM = "wayland";
  };
in
{
  options.suzu.system.guiEssentials.enable =
    lib.mkEnableOption "Core desktop services (portals, greetd, polkit, dbus, keyring)";

  config = lib.mkIf cfg.enable {
    # Enables graphic server without X
    services.xserver.enable = false;

    # Enables real time priority
    security.rtkit.enable = true;

    # Qt follows GTK — see QT_QPA_PLATFORMTHEME = "gtk3" in waylandEnv above.
    #
    # The NixOS `qt` module is deliberately NOT used here: its platformTheme option only accepts
    # gnome/gtk2/kde/lxqt/qt5ct, and none of those is what we want. `gtk3` selects Qt's own qgtk3
    # platform theme plugin, which makes Qt read the GTK theme, colours and fonts directly — so the
    # two Qt apps left (qbittorrent, OnlyOffice) follow Noctalia's theme for free, with no second
    # theme to configure. Verified libqgtk3.so ships in BOTH qtbase 6.11.1 and qtbase 5.15.19,
    # which is what those two apps are built against respectively.
    #
    # Setting the env var directly is the whole mechanism; enabling the module as well would only
    # fight it by writing a different QT_QPA_PLATFORMTHEME (that collision is why the line below
    # used to need mkForce — with the module gone, it no longer does).
    qt.enable = false;

    environment.sessionVariables = waylandEnv;
    hm.systemd.user.sessionVariables = waylandEnv;

    # Minimal display manager
    services.greetd = {
      enable = true;
      settings = {
        # initial_session = greetd's autologin: runs ONCE on boot, no password, no greeter.
        # Launch the session directly (NOT tuigreet, which would still prompt). This is what lets
        # the box come back into niri unattended after a reset / power loss — the niri session then
        # autostarts the ai-cockpit + serve mappings, so the phone control panel returns on its own.
        initial_session = {
          command = "niri-session";
          user = "suzu";
        };
        # Shown only on later logouts / manual login — here tuigreet still asks for the password.
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
          #        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd hyprland";
          user = "suzu";
        };
      };
    };

    # Desktop integration portals (required for file pickers, screenshots, etc)
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xdg-desktop-portal
      ];

      config = {
        common = {
          default = [
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
          "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        };
        niri = {
          default = [
            "gtk"
            "gnome"
          ];
        };
      };
    };

    # Default value of gtk theme for the builder to stop annoying me
    # gtk.gtk4.theme = null;

    # Enable dconf configuration system
    programs.dconf.enable = true;

    # Disables the default KDE polkit agent that the niri flake try to use
  #  systemd.user.services.niri-flake-polkit.enable = false;

    # Delays the xdg desktop portals until after the niri services start to avoid conflicts
    systemd.user.services.xdg-desktop-portal.after = [ "niri.service" ];
    systemd.user.services.xdg-desktop-portal-gtk.after = [ "niri.service" ];
    systemd.user.services.xdg-desktop-portal-gnome.after = [ "niri.service" ];

    # Polkit and essential services for hot plug USB
    security.polkit.enable = true;

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    services = {
      dbus.enable = true;
      gvfs.enable = true;
      tumbler.enable = true;
      udisks2.enable = true;
      udev.packages = with pkgs; [
        gnome-settings-daemon
      ];
      gnome.gnome-keyring.enable = true;   # GNOME-keyring for storing passwords
    };
  };
}
