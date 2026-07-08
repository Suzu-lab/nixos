# Home-manager user suzu
{
  lib,
  pkgs,
  username,
  ...
}:
{

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "render"
      "video"
      "i2c" # DDC/CI monitor brightness via ddcutil (hardware.i2c.enable adds the group + udev)
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

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # If an unmanaged file (e.g. a runtime-written settings.json) collides with a
  # Home Manager-managed one, rename it to <file>.hm-bak instead of aborting the
  # activation. Keeps rebuilds from failing on first-time takeovers.
  home-manager.backupFileExtension = "hm-bak";
  
}
