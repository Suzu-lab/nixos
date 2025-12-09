# GUI fonts
{ 
  inputs,
  lib,
  pkgs,
  ... 
}:
let
  hmLib = inputs.home-manager.lib.hm;
in
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    enable = true;
    antialias = true;
    useEmbeddedBitmaps = true;
    defaultFonts = {
      emoji = [ "Noto Emoji" ];
      monospace = [ "Noto Mono" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  # Home-manager font config
  hm = {
    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig = {
      enable = true;
      antialiasing = true;
      defaultFonts = {
        emoji = [ "Noto Emoji" ];
        monospace = [ "Noto Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };

    # Script for fixing fonts in OnlyOffice
    home.activation = {
      copy-fonts-local-share = hmLib.dag.entryAfter ["writeBoundary"]
      ''
        rm -rf ~/.local/share/fonts
        mkdir -p ~/.local/share/fonts
        cp ${pkgs.noto-fonts}/share/fonts/noto/* ~/.local/share/fonts/
        chmod 777 ~/.local/share/fonts
        chmod 777 ~/.local/share/fonts/*
      '';
    };
  };
}
