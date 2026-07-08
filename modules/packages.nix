{
  pkgs,
  ...
}:
{
  # DDC/CI monitor brightness (Noctalia's brightness slider uses ddcutil): load the i2c-dev
  # kernel module and create /dev/i2c-* owned by GROUP="i2c" (suzu is added to i2c in
  # users/home.nix). Installing the ddcutil package alone does nothing without this.
  hardware.i2c.enable = true;

  # Base packages used at system level
  environment.systemPackages = with pkgs; [
    btop
    btrfs-progs
    claude-code
    cliphist
    coreutils
    cpu-x
    curl
    ddcutil # Utility for adjusting monitor settings through the system
    fastfetch
    file
    git
    gpu-screen-recorder # For screen recording using the Noctalia-shell plugin
    htop
    inetutils
    logiops # Software for managing the Logitech mouse
    nixfmt
    polkit
    polkit_gnome
    qt6Packages.qt6ct
    tree
    usbutils
    wget
    zip

    # Terminal apps for debloating android phones
    android-tools
    universal-android-debloater

    # AI stuff
    amdgpu_top # GPU/VRAM monitor (reads amdgpu driver directly; has a --gui mode). Used for --n-cpu-moe tuning and the case-screen dashboard.
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
      octave # math plotting program for uni work
      qbittorrent # torrent client
      pinta # simple image editor
      pkgsRocm.blender

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