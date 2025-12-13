# Using Catppuccin since it works better than Stylix, and I like the Catpuccin theme
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.themes.catppuccin;
  themeName = "catppuccin-${cfg.flavor}-${cfg.accent}-standard+black";
  themePackage = pkgs.catppuccin-gtk.override {
    accents = [ cfg.accent ];
    size = "standard";
    variant = cfg.flavor;
    tweaks = [ "black" ];
  };
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  # Documentation at https://nix.catppuccin.com/
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  options.suzu.themes.catppuccin = {
    enable = mkEnableOption "Catppuccin Theme";
    flavor = mkOption {
      type = types.enum ["latte" "frappe" "macchiato" "mocha"];
      default = "mocha";
      description = "Base color of the theme";
    };
    accent = mkOption {
      type = types.enum ["blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach" "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow"];
      default = "flamingo";
      description = "Accent color of the theme";
    };
    icons = mkOption {
      type = types.enum ["blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach" "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow"];
      default = "flamingo";
      description = "Icon color of the theme";
    };
  };

  config = mkIf cfg.enable {
    # Enables catppuccin theme globally
    catppuccin = {
      enable = true;
      flavor = cfg.flavor;
      accent = cfg.accent;
    };

    hm = {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];
      catppuccin = {
        # Enable it for all programs
        enable = true;
        flavor = cfg.flavor;
        accent = cfg.accent;
        # Set icon theme
        gtk.icon.accent = cfg.icons;
        # Set cursors through catppuccin
        cursors = {
          enable = true;
          flavor = cfg.flavor;
          accent = cfg.accent;
        };
      };

      # Configure cursor size.
      home.pointerCursor = {
        enable = true;
        x11.enable = true;
        gtk.enable = true;
        size = 24;
      };

      # Telling apps that the system theme is actually dark
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
      home.sessionVariables = {
        GTK_THEME = themeName;
      };
      # Setting gtk theme
      gtk = {
        enable = true;
        theme = {
          package = themePackage;
          name = themeName;
        };
      };

      # Tweak to apply theme to gtk4
      xdg.configFile = {
        "gtk-4.0/assets".source =
          "${themePackage}/share/themes/${themeName}/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source =
          "${themePackage}/share/themes/${themeName}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source =
          "${themePackage}/share/themes/${themeName}/gtk-4.0/gtk-dark.css";
      };

      # Setting qt to use the same theme as gtk
      qt = {
        enable = true;
        style.name = "kvantum";
        platformTheme.name = "gtk";
      };
    };
  };
}
