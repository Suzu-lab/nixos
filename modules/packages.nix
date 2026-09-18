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
    # qt6ct removed 2026-08-03: Qt now uses the qgtk3 platform theme and follows the GTK theme,
    # so there is no separate Qt theme left to configure.
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
      calibre # convert ebooks for the Kindle
      octave # math plotting program for uni work
      qbittorrent # torrent client
      # Simple image editor (crops, paste, annotate). Briefly swapped for `drawing` on the grounds
      # that Pinta is GTK4+libadwaita and so ignores the GTK theme — reverted 2026-08-04, because
      # that trade was wrong: theming only matters where colour carries information, and an image
      # editor's canvas is filled by the image's own colours. Pinta is simply the better tool.
      pinta
      pkgsRocm.blender

      # Shell for running python
      conda

      #################################################################
      # Utilities and backends
      #################################################################
      # Archive manager. Swapped to engrampa (the pre-libadwaita MATE fork) for theming reasons and
      # reverted 2026-08-04 for the same reason as pinta above — file-roller is the better-maintained
      # original and an archive dialog is not somewhere theme colours convey anything.
      file-roller
      unzip
      p7zip
      pavucontrol
      unrar
      yt-dlp
    ];
  };
}