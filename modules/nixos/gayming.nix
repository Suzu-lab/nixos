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

    # Install Steam and open firewall rules for it
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    environment.systemPackages = with pkgs; [
      itch # Client for itch.io games
      lutris
      mangohud
      protonup-qt
      wine
      winetricks
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
