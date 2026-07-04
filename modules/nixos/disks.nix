{
  inputs,
  pkgs,
  ...
}:
{
  # WD Red 12 TB HDD mount (RAID 1)
  fileSystems."/home/suzu/hdd" = {
    device = "/dev/disk/by-uuid/29fba074-c6b0-4265-bd6f-d3076b5d67d7";
    fsType = "btrfs";
    # Use zstd to speed up read/write times and save space
    options = [ "defaults" "nofail" "compress=zstd" ]; 
  };

  # 512GB NVMe mount (dedicated to AI models)
  fileSystems."/home/suzu/ai-models" = {
    device = "/dev/disk/by-uuid/d79ece30-1c57-4635-b33f-86294b82be17";
    fsType = "ext4";
  };

  # Acivate weekly TRIM
  services.fstrim.enable = true;
}