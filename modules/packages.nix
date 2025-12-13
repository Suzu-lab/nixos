{
  pkgs,
  ...
}:
{
  # Base packages used at system level
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    file
    git
    htop
    btop
    fastfetch
    tree
    usbutils
    wget
    zip
    nixfmt-rfc-style
    # AI stuff
    rocmPackages.amdsmi
    rocmPackages.rocminfo
    clinfo
  ];

  hm = {
    # User packages
    home.packages = with pkgs; [
      #################################################################
      # User programs
      #################################################################
      imv
      nexusmods-app
#      lutris
      octave # math plotting program for uni work
      qbittorrent # torrent client

      # Shell for running python
      conda

      #################################################################
      # Utilities and backends
      #################################################################
      file-roller
      unzip
      p7zip
      pavucontrol
      unrar
      yt-dlp
    ];
  };
}