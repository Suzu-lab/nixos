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
  # Passwordless sudo for wheel — chosen for hands-off remote admin (phone/SSH over Tailscale) while
  # away. Tradeoff: with greetd autologin on, physical access to this box = instant root. Accepted
  # for a home server. Revert to `true` when back if you want the physical-access guard back.
  security.sudo.wheelNeedsPassword = false;

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
