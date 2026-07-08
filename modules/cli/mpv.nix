# mpv - TUI video player
{ config, lib, pkgs, ... }:
let
  cfg = config.suzu.cli.mpv;
in
{
  options.suzu.cli.mpv.enable = lib.mkEnableOption "mpv video player";

  config = lib.mkIf cfg.enable {
    hm.programs.mpv = {
      enable = true;
      # Extra configs
      config = {
        ytdl = "yes";
        ytdl-format = "bestvideo+bestaudio/best";
        vo = "gpu-next";
        hwdec = "auto";
      };
      package = pkgs.mpv;
    };
  };
}
