# Config for VS Codium
{ config, lib, pkgs, ... }:
let
  cfg = config.suzu.programs.vscodium;
in
{
  options.suzu.programs.vscodium.enable = lib.mkEnableOption "VSCodium editor";

  # Config done in home-manager. Using programs.vscodium (instead of
  # programs.vscode with a vscodium package) so config is written to VSCodium's
  # own paths (~/.vscode-oss, "VSCodium/User") rather than VS Code's.
  config = lib.mkIf cfg.enable {
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
      ];

      # Settings.json config
      profiles.default.userSettings = {
        #				"workbench.iconTheme" = "vscode-icons";

        # Wayland decorations config
        "window.titleBarStyle" = "native";

        # Claude Code extension: it looks for `claude` on FHS paths (/usr/bin/...)
        # by default, which don't exist on NixOS. Point it at the store binary via
        # the package so the path tracks claude-code updates automatically.
        "claudeCode.claudeProcessWrapper" = "${pkgs.claude-code}/bin/claude";
        "claudeCode.preferredLocation" = "panel";

        # Specific language configuration
        "[nix]" = {
          "editor.tabSize" = 2;
        };
      };
    };
  };
}
