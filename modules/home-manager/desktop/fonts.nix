# GUI fonts
{ pkgs, ... }:
{
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
    copy-fonts-local-share = lib.hm.dag.entryAfter ["writeBoundary"]
    ''
      rm -rf ~/.local/share/fonts
      mkdir -p ~/.local/share/fonts
      cp ${pkgs.noto-fonts}/share/fonts/noto/* ~/.local/share/fonts/
      chmod 544 ~/.local/share/fonts
      chmod 444 ~/.local/share/fonts/*
    '';
  };
  } 
}
