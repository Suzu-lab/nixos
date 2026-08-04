# Module for setting up special .desktop entries
{ config, lib, ... }:
let
  cfg = config.suzu.desktop.desktopEntries;
in
{
  options.suzu.desktop.desktopEntries.enable =
    lib.mkEnableOption "Custom and hidden .desktop entries";

  config = lib.mkIf cfg.enable {
    hm.xdg.desktopEntries = {
      # Hiding desktop entries
      # (kvantummanager / qt5ct / qt6ct entries lived here until 2026-08-03 — all three came in via
      # the old catppuccin + qt5ct theming path and went away with it, so there is nothing to hide)
      "htop" = {
        name = "Htop";
        exec = "htop";
        noDisplay = true;
      };
      "btop" = {
        name = "Btop++";
        exec = "btop";
        noDisplay = true;
      };
      "micro" = {
        name = "Micro";
        exec = "micro";
        noDisplay = true;
      };
      "nixos-manual" = {
        name = "NixOS Manual";
        exec = "nixos-manual";
        noDisplay = true;
      };

      # NOTE: do NOT add a "yazi" entry here. The yazi package already ships
      # share/applications/yazi.desktop (Terminal=true, MimeType=inode/directory) plus its own
      # share/pixmaps/yazi.png, so it appears in the launcher on its own. An entry with the same
      # attribute name silently SHADOWS the package's file inside home-path's buildEnv — no
      # warning, the winner decided by priority. If yazi ever needs an explicit terminal wrapper
      # (i.e. if Terminal=true is not honoured by the launcher), name it something else, e.g.
      # "yazi-kitty", so both coexist instead of one clobbering the other.

      # Custom .desktop entry for OnlyOffice
      "onlyoffice-desktopeditors" = {
        name = "OnlyOffice";
        exec = "onlyoffice-desktopeditors --system-title-bar %U";
        categories = [ "Office" "WordProcessor" "Spreadsheet" "Presentation" ];
        icon = "onlyoffice-desktopeditors";
      };

      # Fixing electron apps rendering in Wayland
      "chromium-browser" = {
        name = "Chromium";
        exec = "chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3 --enable-features=WebRTCPipeWireCapturer %F";
        icon = "chromium";
      };
      "codium" = {
        name = "VSCodium";
        exec = "codium --enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3 %F";
        icon = "vscodium";
      };
    };
  };
}
