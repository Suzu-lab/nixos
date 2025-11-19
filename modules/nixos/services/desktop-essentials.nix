# Enables essential services for a desktop environment
{ pkgs, ... }:
{
  # Enables graphic server without X
  services.xserver.enable = false;

  # Enables real time priority
  security.rtkit.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
#    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
#      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal
      #  			kdePackages.xdg-desktop-portal-kde
    ];
    
      config = {
      			common = {
              		default = [
      					"gtk"
      #					"hyprland"
      					"gnome"
      				];
      #				"org.freedesktop.impl.portal.ScreenCast" = "hyprland";
      #				"org.freedesktop.impl.portal.Screenshot" = "hyprland";
      #				"org.freedesktop.impl.portal.RemoteDesktop" = "hyprland";
      				"org.freedesktop.impl.portal.ScreenCast" = "gnome";
      				"org.freedesktop.impl.portal.Screenshot" = "gnome";
      				"org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
            };
      			niri ={
      				default = [
      					"gtk"
      #					"hyprland"
      					"gnome"
      					"wlr"
      				];
      			};
      		};
    
  };

  # Trying to add GNOME required shit for the xdg portal do work
  	environment.systemPackages = with pkgs; [
    		nautilus
  	];

  	systemd.user.services.xdg-desktop-portal.after = ["niri.service"];
  	systemd.user.services.xdg-desktop-portal-gnome.after = ["niri.service"];

  # Polkit and essential services for hot plug USB
  security.polkit.enable = true;
  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;
}
