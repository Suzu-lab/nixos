# Config for the Celluloid video viewer
{ pkgs, ... }:
{
  # Installation through Home-Manager
  home.packages = with pkgs; [
    celluloid
  ];

  # Declarative config through dconf
  dconf.settings = {
    "io/github/celluloid-player/celluloid" = {
      # Toggle for keeping window always on top
      always-on-top = false;
      # Show playlist by default
      playlist-visible = true;
      # Use dark theme by default
      dark-theme = true;

      # Extra mpv options - Can pass command line options for mpv
      extra-mpv-options = "--hwdec=auto --vo-gpu";
    };
  };
}
