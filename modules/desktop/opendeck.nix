# OpenDeck (stream deck software) for the Ajazz AKP03E, built NATIVELY (pkgs.opendeck, vendored
# from Azelphur's opendeck-nix fork into pkgs/opendeck). Native webkitgtk renders on NixOS —
# the AppImage failed with EGL_BAD_PARAMETER. The AKP03E is a rebadged Mirabox N3 with no vendor
# driver; it's driven by the 4ndv/opendeck-akp03 plugin (installed in OpenDeck's GUI → Plugins).
# Keys map to companion-ctl / ask-screen / wpctl / niri commands (see companion README).
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.opendeck ];

  # OpenDeck plugins are prebuilt, dynamically-linked binaries dropped into ~/.config/opendeck/
  # at runtime — NixOS's stub ld-linux refuses them ("Could not start dynamically linked
  # executable … see stub-ld"). nix-ld provides a real /lib64/ld-linux + glibc so they run. The
  # opendeck-akp03 plugin only needs libc/libm/libgcc_s (libgcc_s via stdenv.cc.cc.lib).
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib ];

  services.udev.packages = [
    pkgs.opendeck # OpenDeck's own device rules

    # The 4ndv/opendeck-akp03 plugin's udev rules (the docs say to drop this in
    # /etc/udev/rules.d/; on NixOS we install it declaratively, priority 40 = before systemd's
    # 73-seat-late.rules so `uaccess` is seen in time). We ADD `GROUP="users"` to the upstream
    # `MODE="0660", TAG+="uaccess"`: `uaccess` (logind ACL) proved unreliable to (re)apply here
    # via `udevadm trigger`, whereas GROUP/MODE ARE applied directly by udev on trigger — and the
    # user is in `users`, so this grants access without a reboot. (uaccess kept as a bonus.)
    (pkgs.writeTextFile {
      name = "opendeck-akp03-udev-rules";
      destination = "/etc/udev/rules.d/40-opendeck-akp03.rules";
      text = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="1001", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="1002", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="1003", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="3002", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="3003", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0b00", ATTRS{idProduct}=="1001", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1500", ATTRS{idProduct}=="3001", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="6602", ATTRS{idProduct}=="1002", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="6603", ATTRS{idProduct}=="1003", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="6603", ATTRS{idProduct}=="1002", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="5548", ATTRS{idProduct}=="1001", GROUP="users", MODE="0660", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0200", ATTRS{idProduct}=="2000", GROUP="users", MODE="0660", TAG+="uaccess"

        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="1001", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="1002", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="1003", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="3002", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0300", ATTRS{idProduct}=="3003", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b00", ATTRS{idProduct}=="1001", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1500", ATTRS{idProduct}=="3001", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="6602", ATTRS{idProduct}=="1002", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="6603", ATTRS{idProduct}=="1003", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="6603", ATTRS{idProduct}=="1002", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="5548", ATTRS{idProduct}=="1001", GROUP="users", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0200", ATTRS{idProduct}=="2000", GROUP="users", MODE="0660", TAG+="uaccess"
      '';
    })
  ];
}
