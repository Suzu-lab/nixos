  # Configuration file specific for this machine

  { config, pkgs, inputs, ... }:
  {
    networking.hostName = "vm";

    # Import machine hardware config
    imports = [
      ./hardware-configuration.nix
      ../../modules/nixos/base.nix		# default system module
      ../../modules/nixos/hardware/audio.nix 	# pipewire module
      ../../modules/nixos/services/desktop-essentials.nix 	# essential services for GUI
      ../../modules/nixos/apps/hyprland.nix 	# activate hyprland at system level
      ../../modules/nixos/apps/thunar.nix 	# activate thunar at system level
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

