# Module for enabling Niri and importing the home manager module
{ pkgs, niri, ... }:
{

  # Enables graphic server without X
  services.xserver.enable = false;

  programs.niri.enable = true;
  nixpkgs.overlays = [ niri.overlays.niri ];
  programs.niri.package = pkgs.niri-stable;

}
