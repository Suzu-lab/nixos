# Configuration file specific for this machine
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Import machine hardware config
    ./hardware-configuration.nix
    ../../modules/modules.nix
    ../../modules/packages.nix
  ];

  networking.hostName = "yosai";

  # Increase timeout of home-manager-suzu service to 15 minutes so it can actually finish the download of the pytorch and other thing for comfyui.
  systemd.services."home-manager-suzu".serviceConfig = {
    TimeoutStartSec = lib.mkForce "20min";
  };

  suzu.desktop = {
    # Window managers
    niri.enable = true;

    # Shells/bars
    noctalia.enable = true;

    # Desktop integration
    desktopEntries.enable = true;
    fcitx5.enable = true;
    xdg.enable = true;
  };

  # System-level modules (hardware, services, essentials)
  suzu.system = {
    audio.enable = true;
    deepcool.enable = true;
    disks.enable = true;
    firewall.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    guiEssentials.enable = true;
    keychron.enable = true;
    netdata.enable = true;
    openrgb.enable = true;
  };

  # Terminal applications
  suzu.cli = {
    fish.enable = true;
    git.enable = true;
    micro.enable = true;
    mpv.enable = true;
    yazi.enable = true;
  };

  # GUI programs
  suzu.programs = {
    celluloid.enable = true;
    chromium.enable = true;
    gthumb.enable = true;
    kitty.enable = true;
    nemo.enable = true;
    obsidian.enable = true;
    onlyoffice.enable = true;
    vscodium.enable = true;
    zathura.enable = true;
    zen.enable = true;
  };

  # Network options
  suzu.networking = {
    enable = true;
    doh.enable = true;  # Enables DNS over HTTPS (using cloudflared)
  };

  # Catppuccin for everything graphical — GTK (incl. libadwaita), icons, cursor, VSCodium and
  # niri's focus ring all derive from these two lines. Qt follows GTK automatically via qgtk3.
  # Noctalia themes only what lives in the terminal (kitty, btop, bat, zathura); yazi follows
  # kitty's ANSI colours through its base16 flavor.
  suzu.themes = {
    enable = true;
    # "latte" | "frappe" | "macchiato" | "mocha"  (lightest to darkest)
    flavor = "mocha";
    # rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender
    accent = "mauve";
  };

  # Options for AI stuff
  # Phase 0 host prep for the containerized AI companion (Docker + GPU firmware
  # + NVMe data dirs). The container stack itself lives on the NVMe and is run
  # imperatively via `docker compose`.
  suzu.ai.companionHost.enable = true;

  # Data dirs + stream-deck control for the containerized image-generation stack
  # (ComfyUI engine + SwarmUI frontend). The stack lives in modules/ai/imagegen/ and
  # is run imperatively via `docker compose`, like the companion.
  suzu.ai.imagegenHost.enable = true;

  # Data dirs + rp-on/rp-off handoff scripts for the containerized SillyTavern roleplay stack
  # (dedicated llama-swap on :8081). Lives in modules/ai/roleplay/, run imperatively via
  # `docker compose`. Independent of the companion — see its README.
  suzu.ai.roleplayHost.enable = true;

  # Tailscale mesh VPN + phone access (serve) to SillyTavern, SwarmUI, the llama-swap dashboard and
  # netdata stats — tailnet-only, never LAN/public. Needs a one-time `sudo tailscale up`; see the
  # module header. This is what lets the phone drive/monitor the stacks from anywhere.
  suzu.system.remoteAccess.enable = true;

  # Shared model-download CLIs (hf/huggingface-cli + hf-transfer + aria2c) used by all three AI
  # stacks. hf for Hugging Face weights; aria2c for CivitAI and other direct-URL downloads.
  suzu.ai.modelTools.enable = true;
}
