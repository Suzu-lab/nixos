# OpenRGB — control RGB on the Asus TUF B550m board, Kingston Fury RAM and the
# XFX RX 9070 XT. Wraps the upstream NixOS module (services.hardware.openrgb),
# which installs the GUI + udev rules, loads the needed i2c kernel modules and
# runs a background server that re-applies the saved profile at boot.
{
  config,
  lib,
  ...
}:
let
  cfg = config.suzu.system.openrgb;
in
{
  options.suzu.system.openrgb.enable =
    lib.mkEnableOption "OpenRGB RGB control (motherboard, RAM, GPU)";

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      # AMD B550 chipset -> load i2c-piix4 for SMBus access (RAM + motherboard).
      # Also pulls in i2c-dev (already on via hardware.i2c.enable). GPU RGB is
      # reached over the card's own i2c bus, no extra module needed.
      motherboard = "amd";
    };

    # The SMBus that the RAM and motherboard RGB live on is claimed by ACPI, so
    # i2c-piix4 can't touch those addresses until we relax that check. This is
    # what lets OpenRGB actually see the Fury sticks and the Aura controller.
    # Trade-off: lm-sensors/it87-style monitoring and OpenRGB now share the bus;
    # in practice fine, but remove this line if you hit sensor weirdness.
    boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  };
}
