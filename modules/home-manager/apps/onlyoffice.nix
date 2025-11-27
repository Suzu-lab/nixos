# Declaratively setting OnlyOffice
{ pkgs, mypkgs, ... }:
{
  programs.onlyoffice = {
    enable = true;
    # Customized derivation for newest version of OnlyOffice
    package = mypkgs.onlyoffice-update;
  };
}

