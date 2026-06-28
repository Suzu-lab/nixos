{
  inputs,
  pkgs,
  ...
}:
{
  fileSystems."/home/suzu/hdd" = {
      device = "/dev/disk/by-uuid/29fba074-c6b0-4265-bd6f-d3076b5d67d7";
      fsType = "btrfs";
      # Use zstd to speed up read/write times and save space
      options = [ "defaults" "nofail" "compress=zstd" ]; 
    };
}