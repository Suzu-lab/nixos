# All the packages and configs required for some hardcore gayming
{ config, pkgs, modulesPath, ... }:
{
  
  config = {
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
      lutris
      protonup-qt
      wine
      winetricks
    ];

    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
    # Enables 32 bit drivers for Wine
    hardware.graphics.enable32Bit = true;
  };
}
