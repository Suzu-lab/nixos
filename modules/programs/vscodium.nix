# Config for VS Codium
{ pkgs, ... }:
{
  # Config done in home-manager. Using programs.vscodium (instead of
  # programs.vscode with a vscodium package) so config is written to VSCodium's
  # own paths (~/.vscode-oss, "VSCodium/User") rather than VS Code's.
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

      # Specific language configuration
      "[nix]" = {
        "editor/tabSize" = 2;
      };
    };
  };
}
