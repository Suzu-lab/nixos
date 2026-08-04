# Config for VS Codium
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.suzu.programs.vscodium;

  userDir = "/home/${username}/.config/VSCodium/User";

  # Seed settings, NOT a managed file. Home Manager's `userSettings` writes settings.json as a
  # symlink into the read-only Nix store, which makes VSCodium's own settings GUI fail with a
  # permission error — every preference change would have to go through a .nix edit and a rebuild.
  # These values are the ones worth keeping reproducible on a fresh install; VSCodium owns the file
  # from first launch onwards and anything changed in the GUI simply sticks.
  seedSettings = pkgs.writeText "vscodium-settings.json" (
    builtins.toJSON {
      # Catppuccin, from the nixpkgs extensions below. Both derive from suzu.themes.flavor, so the
      # editor follows the same single knob as GTK/icons/cursor/niri. Label and id formats were read
      # off each extension's package.json, not guessed: theme label "Catppuccin <Flavour>", icon
      # theme id "catppuccin-<flavour>".
      "workbench.colorTheme" = "Catppuccin ${config.suzu.themes.prettyFlavor}";
      "workbench.iconTheme" = "catppuccin-${config.suzu.themes.flavor}";

      # Wayland decorations config
      "window.titleBarStyle" = "native";

      # Claude Code extension: it looks for `claude` on FHS paths (/usr/bin/...) by default, which
      # don't exist on NixOS. Point it at the store binary via the package so the path tracks
      # claude-code updates automatically.
      "claudeCode.claudeProcessWrapper" = "${pkgs.claude-code}/bin/claude";
      "claudeCode.preferredLocation" = "panel";

      # Auth is handled externally by the CLI above (which we log into via `claude /login`). Since
      # 2.1.220 the extension defaults to its own in-editor OAuth flow, which fails here ("failed to
      # retrieve auth status after login"). This tells it to trust the already-authenticated CLI.
      "claudeCode.disableLoginPrompt" = true;

      # Specific language configuration
      "[nix]" = {
        "editor.tabSize" = 2;
      };
    }
  );
in
{
  options.suzu.programs.vscodium.enable = lib.mkEnableOption "VSCodium editor";

  # Config done in home-manager. Using programs.vscodium (instead of
  # programs.vscode with a vscodium package) so config is written to VSCodium's
  # own paths (~/.vscode-oss, "VSCodium/User") rather than VS Code's.
  config = lib.mkIf cfg.enable {
    # `C` copies only when the destination is absent, so the GUI stays usable and nothing is
    # clobbered on rebuild. `z` fixes the mode, because a copy out of the store inherits 0444.
    #
    # CAVEAT worth remembering: `C` also never REPAIRS an existing destination. If settings.json is
    # ever left in a broken state, the seed will silently skip it — delete the file and re-run
    # `sudo systemd-tmpfiles --create` to get a fresh one.
    systemd.tmpfiles.rules = [
      "d ${userDir} 0755 ${username} users -"
      "C ${userDir}/settings.json 0644 ${username} users - ${seedSettings}"
      "z ${userDir}/settings.json 0644 ${username} users -"
    ];

    hm.programs.vscodium = {
      enable = true;

      # Declarative extensions
      profiles.default.extensions = with pkgs.vscode-extensions; [
        # Languages and tools
        #  -9      ms-python.python
        rust-lang.rust-analyzer
        ms-azuretools.vscode-docker
        tamasfe.even-better-toml
        jnoortheen.nix-ide

        # Quality of life
        vscode-icons-team.vscode-icons
        eamodio.gitlens

        # Theme. Catppuccin owns everything graphical on this machine (see
        # modules/desktop/themes/default.nix); Noctalia only themes terminal-resident apps.
        #
        # This replaced a much more fragile arrangement: Noctalia's `vscode` template ships no
        # usable extension (just a colour JSON with no package.json), so it needed the real
        # extension seeded from Open VSX via tmpfiles, plus mode fixes so the template could keep
        # rewriting the JSON inside it. Two moving parts and a permissions dance, versus one
        # nixpkgs package. The `vscode` template is disabled in noctalia-settings.toml.
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];

      # NOTE: `profiles.default.userSettings` is intentionally NOT used — see seedSettings above.
      # It would make settings.json read-only and break VSCodium's settings GUI.
    };
  };
}
