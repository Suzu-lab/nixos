{
  config,
  lib,
  ...
}:
let
  cfg = config.suzu.system.disks;
in
{
  options.suzu.system.disks.enable =
    lib.mkEnableOption "Extra data-disk mounts (HDD RAID + AI-models NVMe)";

  config = lib.mkIf cfg.enable {
    # WD Red 12 TB HDD mount (RAID 1)
    fileSystems."/home/suzu/hdd" = {
      device = "/dev/disk/by-uuid/29fba074-c6b0-4265-bd6f-d3076b5d67d7";
      fsType = "btrfs";
      # Use zstd to speed up read/write times and save space
      options = [ "defaults" "nofail" "compress=zstd" ];
    };

    # 512GB NVMe mount (dedicated to AI models)
    fileSystems."/home/suzu/ai-models" = {
      device = "/dev/disk/by-uuid/2f40d288-dedf-4a87-8558-107809100e47";
      fsType = "ext4";
      options = [ "noatime" "nofail" "x-systemd.automount" ];
    };

    # Acivate weekly TRIM
    services.fstrim.enable = true;
  };
}
