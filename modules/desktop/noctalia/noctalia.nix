# Declarative configuration for Noctalia-shell
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.desktop.noctalia;
in
{
  options.suzu.desktop.noctalia = {
    enable = lib.mkEnableOption "Noctalia Shell";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      inputs.noctalia-shell.packages.${stdenv.hostPlatform.system}.default
    ];

    hm = {
      imports = [
        inputs.noctalia-shell.homeModules.default
      ];
      # Renamed from `programs.noctalia-shell` to `programs.noctalia`. Settings
      # are TOML now (~/.config/noctalia/config.toml) and checked by
      # `noctalia config validate` at build time (validateConfig, default true).
      # We point `settings` straight at a .toml file — Noctalia's native format —
      # so it's a 1:1 copy of what the settings GUI exports, no Nix translation.
      programs.noctalia = {
        enable = true;
        #systemd.enable = true; # Autostarts the shell as a systemd service.
        settings = ./noctalia-settings.toml;
      };
    };
  };
}
