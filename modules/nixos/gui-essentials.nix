# Enables essential services for a desktop environment
{ pkgs, ... }:
{
  # Enables graphic server without X
  services.xserver.enable = false;

  # Enables real time priority
  security.rtkit.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron apps/Steam
    QT_QPA_PLATFORM = "wayland"; # Qt apps
    SDL_VIDEODRIVER = "wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    OZONE_PLATFORM = "wayland";
  };

  # Minimal display manager
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        #        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd hyprland";
        user = "suzu";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        #        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd hyprland";
        user = "suzu";
      };
    };
  };

  # Auto-login because fuck typing passwords
  #		services.getty.autologinUser = "suzu";

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

  # Enable dconf configuration system
  programs.dconf.enable = true;

  # Disables the default KDE polkit agent that the niri flake try to use
  systemd.user.services.niri-flake-polkit.enable = false;

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
  };
}
