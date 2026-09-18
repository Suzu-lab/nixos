# udev rules for configuring and flashing Keychron peripherals with launcher.keychron.com
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
    lib.mkEnableOption "udev rules for the Keychron launcher";

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      # Rules for every keychron device (keyboard, mouse, dongle) (launcher.keychron.com)
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # STM32 DFU bootloader - enables firmware update through the web tool (launcher.keychron.com)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}
