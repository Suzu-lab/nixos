# Configuration file specific for this machine

{ config, pkgs, ... }:
{
  networking.hostName = "vm";

  # Import machine hardware config
  imports = [ ./hardware-configuration.nix ];

  # VM guest services
  services.qemuGuest.enable = true;

  # Keyboard configuration (Console will use the same config according to modules/base.nix)
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "intl"; # enables US keyboard with dead keys
  };
}
