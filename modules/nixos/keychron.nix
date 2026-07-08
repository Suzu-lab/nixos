# udev rules for configuring and flashing the Keychron K6 HE keyboard with launcher.keychron.com
{
  config,
  lib,
  ...
}:
let
  cfg = config.suzu.system.keychron;
in
{
  options.suzu.system.keychron.enable =
    lib.mkEnableOption "udev rules for the Keychron K6 HE keyboard/launcher";

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      # Keychron K6 HE - hidraw access to WebUSB (Keychron Launcher, VIA/VIAL etc.)
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e60", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # STM32 DFU bootloader - enables firmware update through the web tool (launcher.keychron.com)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # Keychron Link receiver (2.4 GHz)
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}
