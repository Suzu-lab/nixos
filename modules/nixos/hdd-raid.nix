{
  inputs,
  pkgs,
  ...
}:
{
  fileSystems."/mnt/hdd" = {
      device = "/dev/disk/29fba074-c6b0-4265-bd6f-d3076b5d67d7";
      fsType = "btrfs";
      # compress=zstd é opcional, mas altamente recomendado para acelerar leitura/escrita e poupar espaço
      options = [ "defaults" "nofail" "compress=zstd" ]; 
    };
}