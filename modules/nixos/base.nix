# Base configuration file common to any system I use

{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  # Set zram - swap file inside the ram. - https://www.kernel.org/doc/Documentation/blockdev/zram.txt
  zramSwap = {
    enable = true;
    # alorithm for memory compression - "lzo", "lz4", "zstd"
    algorithm = "zstd";
    # Priority of the zram swap devices. - should be higher than any disk swap devices
    priority = 5;
    # Maximum total amount of memory that can be stored in the zram swap devices (as a percentage of your total memory).
    memoryPercent = 50;
  };

  # Use EFI systemd boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network options
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Keyboard configuration (Console will use the same config according to modules/nixos/base.nix)
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "intl"; # enables US keyboard with dead keys
  };

  # Home Manager config
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  # Inheritance for Home Manager modules
    extraSpecialArgs = { inherit inputs; };
  };

  # Nix flakes
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
    auto-optimise-store = true;
  };

  programs.nix-index = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = true;
  };

  # Base packages used at system level
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    git
    htop
    btop
    fastfetch
    tree
    wget
    zip
    nixfmt-rfc-style
  ];

  # Include fish in the environment shells
  environment.shells = with pkgs; [ fish ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
