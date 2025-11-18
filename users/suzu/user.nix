{ pkgs, ... }:
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
}
