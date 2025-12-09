# Home-manager user suzu
{
  lib,
  pkgs,
  username,
  ...
}:
{

  users.users.suzu = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    ignoreShellProgramCheck = true;
    shell = pkgs.fish; # Defines fish as default user shell
  };
  security.sudo.wheelNeedsPassword = true;

  imports = [
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])
  ];

  hm = {
    home.username = "${username}";
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "25.05";
    programs.home-manager.enable = true;
  };
}
