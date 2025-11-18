# mpv - TUI video player
{ pkgs, ... }:
{
  programs.mpv = {
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
}
