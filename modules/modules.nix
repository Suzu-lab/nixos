{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # System modules
    ./nixos/audio.nix
    ./nixos/base.nix # Basic system module
    ./nixos/deepcool-digital.nix  # Module for enabling the display of the DeepCool Digital air cooler
    ./nixos/disks.nix # Configuration for mounting the extra disks
    ./nixos/firewall.nix
    ./nixos/fonts.nix
    ./nixos/gayming.nix
    ./nixos/gui-essentials.nix
    ./nixos/keychron.nix  # Module for setting up permissions for configuring the Keychron K6 HE keyboard
    ./nixos/netdata.nix # Metrics tool with web interface accessible through port 19999
    ./nixos/networking.nix
    ./nixos/openrgb.nix # RGB control for the motherboard, RAM and GPU
    ./nixos/secrets.nix # sops-nix declarative secret management (encrypted secrets in secrets/)
    ./nixos/tailscale.nix # Tailscale VPN + phone access (serve) to the AI stacks and stats

    # Window managers
    ./desktop/hyprland/hyprland.nix
    ./desktop/niri/niri.nix

    # Shells/bars
    ./desktop/noctalia/noctalia.nix

    # Desktop configs
    ./desktop/desktop-entries.nix # Customized .desktop entries
    ./desktop/fcitx5.nix # Input method for language support
    ./desktop/opendeck.nix # OpenDeck (Ajazz AKP03E stream deck) + udev rule
    ./desktop/xdg.nix # Configuration for file associations

    # Themes
    ./desktop/catppuccin.nix

    # Terminal applications and settings
    ./cli/fish.nix
    ./cli/git.nix
    ./cli/micro.nix
    ./cli/mpv.nix # Terminal media player
    ./cli/yazi.nix  # Terminal file explorer

    # Programs
    ./programs/celluloid.nix  # GUI wrapper for mpv
    ./programs/chromium.nix # Web browser for communication webapps
    ./programs/gthumb.nix # Image viewer
    ./programs/kitty.nix  # Terminal
    ./programs/nemo.nix # File manager
    ./programs/onlyoffice.nix
    ./programs/vscodium.nix
    ./programs/zathura.nix  # Light and fast document viewer
    ./programs/zen.nix  # Backup browser

    # AI stuff (all containerized — host stays ROCm-free; see each module + its README)
    ./ai/companion-host.nix # Docker host prep for the containerized AI companion stack
    ./ai/imagegen-host.nix  # Data dirs + control for the containerized ComfyUI/SwarmUI image stack
    ./ai/roleplay-host.nix  # Data dirs + control + phone access for the containerized SillyTavern RP stack
    ./ai/model-tools.nix    # Shared model-download CLIs (hf + hf-transfer + aria2) for all AI stacks
  ];
}