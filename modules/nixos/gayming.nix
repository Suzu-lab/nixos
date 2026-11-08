# All the packages and configs required for some hardcore gayming
{ config, lib, pkgs, ... }:
let
  cfg = config.suzu.system.gaming;
in
{
  options.suzu.system.gaming.enable =
    lib.mkEnableOption "Steam, gamescope, gamemode and friends";

  config = lib.mkIf cfg.enable {
    programs.gamemode.enable = true;

    programs.steam = {
      enable = true;

      # Opens TCP 27036/27037 + UDP 10400/10401/27031-27036 for Steam Remote Play (streaming to
      # another device, and Remote Play Together). Kept because those are for LAN discovery and
      # direct streaming, which genuinely need to be reachable.
      remotePlay.openFirewall = true;

      # dedicatedServer.openFirewall REMOVED 2026-08-04. It opens TCP+UDP 27015, and the nixpkgs
      # option is specifically for a *Source* Dedicated Server (SRCDS — CS/TF2/Gmod), which isn't
      # run here. It has nothing to do with Steam co-op invites: Palworld & co. use Steam's
      # networking layer, which connects OUTBOUND to Valve's infrastructure, NAT-punches, and falls
      # back to Steam Datagram Relay — no inbound port on either peer. Proof it was dead weight:
      # Palworld's own dedicated server listens on UDP 8211, which this never opened anyway.


      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    # Enable protontricks to install runtimes and other required things for some Windows games.
    programs.steam.protontricks.enable = true;

    environment.systemPackages = with pkgs; [
      itch # Client for itch.io games
      lutris
      mangohud
      protonup-qt
      wine
      winetricks

      # ReShade injection into Proton games (GUI + per-game install/inject).
      # STL downloads ReShade at runtime, so give it the CLI tools it shells out to.
      steamtinkerlaunch
      curl
      wget
      p7zip
      unzip
      git
      xdotool # STL uses this to drive the in-game overlay/menus
    ];

    programs.gamescope = {
      enable = true;
      capSysNice = false;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
    # Enables 32 bit drivers for Wine
    hardware.graphics.enable32Bit = true;
  };
}
