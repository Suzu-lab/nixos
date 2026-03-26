{
  pkgs,
  ...
}:
{
  # Base packages used at system level
  environment.systemPackages = with pkgs; [
    btop
    cliphist
    coreutils
    cpu-x
    curl
    fastfetch
    file
    git
    gpu-screen-recorder # For screen recording using the Noctalia-shell plugin
    htop
    logiops # Software for managing the Logitech mouse
    nixfmt
    polkit
    polkit_gnome
    qt6Packages.qt6ct
    tree
    usbutils
    wget
    zip

    # AI stuff
    #rocmPackages.amdsmi
    #rocmPackages.rocminfo
    #clinfo
  ];

  hm = {
    # User packages
    home.packages = with pkgs; [
      #################################################################
      # User programs
      #################################################################
      imv
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