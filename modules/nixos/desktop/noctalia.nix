 # Install Noctalia-shell. This is a quickshell fork with a NixOS flake that sets up a shell for Wayland compositors (Niri/Hyprland)
 { pkgs, inputs, ... }:
 {
  environment.systemPackages = with pkgs; [
    inputs.noctalia-shell.packages.${stdenv.hostPlatform.system}.default
  ];
 }