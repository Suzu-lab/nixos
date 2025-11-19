# Using Catppuccin since it works better than Stylix, and I like the Catpuccin theme
{
  catppuccin,
  config,
  pkgs,
  inputs,
  lib,
  nixowos,
  ...
}:

{
  # Documentation at https://nix.catppuccin.com/
  imports = [
    ./fonts.nix
  ];

  catppuccin = {
    # Enable it for all programs
    enable = true;
    # Base color scheme. From lightest to darkest: "latte", "frappe", "macchiato", "mocha"
    flavor = "mocha";
    # Accent color for the theme. "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    accent = "pink";
    # Set icon theme to something other than "bright pink"
    gtk.icon.accent = "flamingo";
    # Set cursors through catppuccin
    cursors = {
      enable = true;
      flavor = "mocha";
      accent = "pink";
    };
  };

  # Enables NixOwOS
  nixowos.enable = true;

  # Configure cursor style. Using catppuccin cursor right now, so no use for it.
  home.pointerCursor = {
  	enable = true;
  	x11.enable = true;
  	gtk.enable = true;
    size = 24;
#  	package = pkgs.bibata-cursors;
#  	name = "Bibata-Modern-Amber";
  };

  # Setting gtk theme
  gtk = {
    enable = true;
    theme = {
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "standard";
        variant = "mocha";
        tweaks = [ "black" ];
      };
      name = "catppuccin-mocha-pink-standard+black";
    };
  };

  # Tweak to apply theme to gtk4
  xdg.configFile = {
    "gtk-4.0/assets".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  # Setting qt to use te same theme as gtk
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "gtk";
  };
}
