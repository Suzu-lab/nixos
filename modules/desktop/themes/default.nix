# Graphical theming — Catppuccin.
#
# THE DIVISION OF LABOUR ON THIS MACHINE:
#   - Noctalia themes everything that lives in the terminal (kitty, btop, bat, zathura, niri) plus
#     yazi indirectly, since yazi's base16 flavor inherits kitty's ANSI slots.
#   - This module themes everything graphical: GTK (incl. libadwaita), icons, cursor. Qt follows
#     automatically through the qgtk3 platform theme (see modules/nixos/gui-essentials.nix), and
#     VSCodium gets the matching Catppuccin extension in modules/programs/vscodium.nix.
#     Web content is Catppuccin too, via Stylus userstyles in Zen/Chromium.
#
# WHY CATPPUCCIN CAME BACK for the graphical half: Noctalia's gtk3 template writes @define-color
# rules using libadwaita names, and in practice the GTK3 apps here (file-roller, gThumb, pinta)
# never followed them — not under Colloid, which ignores those variable names, and not under
# adw-gtk3 either. So switching to Catppuccin is not giving up something that worked; it replaces
# something that never did, with a theme that is simply fixed and correct.
#
# WHY NOT the catppuccin/nix flake: its `autoEnable` turns on all ~77 ports unconditionally, which
# is what caused the multi-GB downloads and ~20-minute rebuilds. The pieces used here are plain
# packages — no flake input, no module, and therefore no home-manager dependency to unwind later.
# The only home-manager surface left is `gtk`/`pointerCursor`, which just write
# ~/.config/gtk-3.0/settings.ini and ~/.icons/default/index.theme: two small files, trivial to port
# to hjem/nix-maid.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.suzu.themes;
  inherit (lib) mkEnableOption mkIf mkOption types;

  flavor = cfg.flavor;
  accent = cfg.accent;

  # The official Catppuccin palette, straight out of nixpkgs' `catppuccin` package
  # (palette/palette.json). No flake input required — which is the whole point: everything here is
  # plain packages, so there is no catppuccin/nix module to unwind when home-manager goes away.
  flavorData = (lib.importJSON "${pkgs.catppuccin}/palette/palette.json").${flavor};
  colors = lib.mapAttrs (_: v: v.hex) flavorData.colors;

  # NOTE: catppuccin-gtk has no binary substitute on cache.nixos.org, so this builds locally. That
  # is ONE small sass build, and only when flavor/accent change — not the multi-GB rebuild the
  # flake's autoEnable used to cause.
  # NOTE: no `tweaks = [ "black" ]`. That tweak was carried over from the old catppuccin/nix setup
  # and is what made libadwaita apps look like plain dark Adwaita with a stray accent colour: it
  # forces window_bg_color to #010101 and headerbar_bg_color to #000000 — pure black surfaces with
  # nothing of Catppuccin left in them except the accent. Without it the theme uses the real Mocha
  # palette (base #1e1e2e, mantle #181825), which is what actually reads as Catppuccin.
  # Put "black" back only if you specifically want black backgrounds; the theme name gains a
  # "+black" suffix when you do.
  gtkTheme = pkgs.catppuccin-gtk.override {
    accents = [ accent ];
    variant = flavor;
    size = "standard";
  };
  gtkThemeName = "catppuccin-${flavor}-${accent}-standard";

  iconTheme = pkgs.catppuccin-papirus-folders.override {
    inherit flavor accent;
  };

  # catppuccin-cursors names its outputs <flavor><Accent>, e.g. mochaMauve.
  cursorTheme = pkgs.catppuccin-cursors."${flavor}${lib.toUpper (builtins.substring 0 1 accent)}${builtins.substring 1 (-1) accent}";
in
{
  options.suzu.themes = {
    enable = mkEnableOption "Catppuccin theming for graphical apps (GTK, icons, cursor)";

    flavor = mkOption {
      type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
      default = "mocha";
      description = "Catppuccin flavour, lightest to darkest. The single source of truth — GTK, icons, cursor, VSCodium and niri all derive from it.";
    };

    accent = mkOption {
      type = types.enum [
        "rosewater" "flamingo" "pink" "mauve" "red" "maroon" "peach"
        "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender"
      ];
      default = "mauve";
      description = "Catppuccin accent colour, applied everywhere the flavour is.";
    };

    # Read-only, for other modules. Saves them re-importing the palette and guarantees they cannot
    # drift from the flavour set above. Consumed by modules/desktop/niri/niri-theme.nix.
    colors = mkOption {
      internal = true;
      readOnly = true;
      type = types.raw;
      default = colors;
      description = "Resolved palette of the active flavour, as { <name> = \"#rrggbb\"; }.";
    };

    prettyFlavor = mkOption {
      internal = true;
      readOnly = true;
      type = types.str;
      default = flavorData.name;
      description = "Display name of the active flavour (\"Mocha\"), as apps like VSCodium label it.";
    };
  };

  config = mkIf cfg.enable {
    # DELIBERATELY NOT SET: the GTK_THEME environment variable. The old catppuccin module exported
    # it, which force-pins the theme for every GTK app and makes gsettings changes no-ops.
    hm.gtk = {
      enable = true;
      theme = {
        package = gtkTheme;
        name = gtkThemeName;
      };
      iconTheme = {
        package = iconTheme;
        name = "Papirus-Dark";
      };
      gtk4.theme = null;
    };

    # GTK4 / libadwaita. Those apps ignore the GTK theme name entirely and only read
    # $XDG_CONFIG_HOME/gtk-4.0/gtk.css, so the theme's stylesheet has to be linked in by hand —
    # this is the one thing that makes libadwaita apps follow Catppuccin at all.
    hm.xdg.configFile = {
      "gtk-4.0/assets".source = "${gtkTheme}/share/themes/${gtkThemeName}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${gtkTheme}/share/themes/${gtkThemeName}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${gtkTheme}/share/themes/${gtkThemeName}/gtk-4.0/gtk-dark.css";
    };

    hm.home.pointerCursor = {
      enable = true;
      package = cursorTheme;
      name = "catppuccin-${flavor}-${accent}-cursors";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    hm.dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    # Kitty's colours stay Noctalia's — its template writes ~/.config/kitty/themes/noctalia.conf and
    # this include is what makes kitty read it. The path MUST be absolute: kitty resolves relative
    # includes against the directory of the config file, and kitty.conf is a home-manager symlink
    # into /nix/store, so a relative path silently resolves to nothing.
    hm.programs.kitty.extraConfig = ''
      include /home/${username}/.config/kitty/themes/noctalia.conf
    '';

    hm.programs.kitty.settings = {
      # Noctalia's post-hook uses `kitty @ set-colors` to repaint already-open windows.
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty-$USER";
    };
  };
}
