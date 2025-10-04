  # Configuration file specific for this machine

  { config, pkgs, inputs, ... }:
  {
    networking.hostName = "vm";

    # Import machine hardware config
    imports = [
      ./hardware-configuration.nix
      ../../modules/base.nix		# default system module
      ../../modules/hyprland.nix # set desktop environment
    ];

    # VM guest services
    services.qemuGuest.enable = true;
		services.spice-vdagentd.enable = true;

		# Video drivers for virtio
		environment.systemPackages = [
			pkgs.xorg.xf86videoqxl
		];

    # Keyboard configuration (Console will use the same config according to modules/base.nix)
    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "intl"; # enables US keyboard with dead keys
    };

    # User configuration
    users.users.suzu = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      ignoreShellProgramCheck = true;
      shell = pkgs.fish;	# Defines fish as default user shell
    };
    security.sudo.wheelNeedsPassword = true;

  }

