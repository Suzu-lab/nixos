  # Configuration file specific for this machine

  { config, pkgs, ... }:
  {
    networking.hostName = "vm";

    # Import machine hardware config
    imports = [ 
      ./hardware-configuration.nix
      ../../modules/base.nix		# default system module 
    ];

    # VM guest services
    services.qemuGuest.enable = true;

    # Keyboard configuration (Console will use the same config according to modules/base.nix)
    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "intl"; # enables US keyboard with dead keys
    };

    # User configuration
    users.users.suzu = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
    };
    security.sudo.wheelNeedsPassword = true;

    # Home-Manager config
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.suzu = import ../../users/suzu.nix;

  }

