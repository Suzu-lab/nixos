  # Configuration file specific for this machine
  { config, pkgs, inputs, ... }:
  {
    imports = [
      # Import machine hardware config
      ./hardware-configuration.nix

			# Import system modules
      ../../modules/nixos/base.nix		# default system module
      ../../modules/nixos/hardware/audio.nix 	# pipewire module
      ../../modules/nixos/services/desktop-essentials.nix 	# essential services for GUI
      ../../modules/nixos/services/gayming.nix #module for setting up Steam and other gaming options
      ../../modules/nixos/desktop/hyprland.nix
      ../../modules/nixos/stylix.nix

			# Importing system flakes modules
			inputs.stylix.nixosModules.stylix
			inputs.nurpkgs.modules.nixos.default

			# Importing Home Manager module
			inputs.home-manager.nixosModules.home-manager

      # User config
      ../../users/suzu/user.nix
      ../../users/suzu/home.nix
    ];

		networking.hostName = "vm";

    # VM guest services
    services.qemuGuest.enable = true;
		services.spice-vdagentd.enable = true;

		# Video drivers for virtio
		services.xserver.videoDrivers = [ "qxl" ];

  }
