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
      ../../modulse/nixos/services/gayming.nix #module for setting up Steam and other gaming options
      # User config
      ../../users/suzu/suzu.nix
    ];

    # VM guest services
    services.qemuGuest.enable = true;
		services.spice-vdagentd.enable = true;

		# Video drivers for virtio
		environment.systemPackages = [
			pkgs.xorg.xf86videoqxl
		];

    # Keyboard configuration (Console will use the same config according to modules/nixos/base.nix)
    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "intl"; # enables US keyboard with dead keys
    };

  }
