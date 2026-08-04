# Noctalia-shell.
#
# NOT declaratively configured, on purpose. Noctalia v5 loads its config from
# `$XDG_STATE_HOME/noctalia/settings.toml` (confirmed in its own startup log:
# "[config] loading /home/suzu/.local/state/noctalia/settings.toml"), and it REWRITES that file
# whenever anything is changed through its settings GUI. The home-manager module still writes
# `~/.config/noctalia/config.toml`, which v5 simply ignores — so `programs.noctalia.settings` was
# dead weight and silently had no effect at all.
#
# HYBRID approach instead: the repo's noctalia-settings.toml is SEEDED into the state directory
# only when it does not already exist. That gives reproducibility on a fresh install (no redoing
# the whole setup by hand) while leaving Noctalia the owner at runtime, so its GUI keeps working
# and nothing fights it on every rebuild.
#
# Using systemd-tmpfiles rather than home-manager is deliberate: it is NixOS-level and therefore
# survives the planned migration off home-manager (hjem/nix-maid).
#
# To capture GUI changes back into the repo:
#   cp ~/.local/state/noctalia/settings.toml modules/desktop/noctalia/noctalia-settings.toml
{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.suzu.desktop.noctalia;
  stateFile = "/home/${username}/.local/state/noctalia/settings.toml";
in
{
  options.suzu.desktop.noctalia = {
    enable = lib.mkEnableOption "Noctalia Shell";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      inputs.noctalia-shell.packages.${stdenv.hostPlatform.system}.default
    ];

    # `C` copies the seed only if the destination does not exist; it never overwrites, so runtime
    # edits made through Noctalia's GUI are safe. Parent dirs are created first — tmpfiles does not
    # create them implicitly for a copy rule.
    systemd.tmpfiles.rules = [
      "d /home/${username}/.local/state 0755 ${username} users -"
      "d /home/${username}/.local/state/noctalia 0755 ${username} users -"
      "C ${stateFile} 0644 ${username} users - ${./noctalia-settings.toml}"
    ];

    hm = {
      imports = [
        inputs.noctalia-shell.homeModules.default
      ];
      programs.noctalia = {
        enable = true;
        # NOTE: `settings` is intentionally NOT set — see the module header. It would write
        # ~/.config/noctalia/config.toml, which Noctalia v5 does not read.
      };
    };
  };
}
