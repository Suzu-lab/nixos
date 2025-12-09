{ config, lib, ... }:

let
  cfg = config.suzu.themes.catppuccin;

  # Import catppuccin palette JSON
  paletteJson =
    lib.importJSON "${config.catppuccin.sources.palette}/palette.json";

  # Picks the current flavor palette
  flavorColors = paletteJson.${cfg.flavor}.colors;

  # Chooses Niri colors. Accent for active, surface for inactive and red for urgent
  accentColor   = flavorColors.${cfg.accent}.hex;
  inactiveColor = flavorColors.surface0.hex;
  urgentColor   = flavorColors.red.hex;
in
{
  # Looks for Catppuccin to be enabled before applying
  config = lib.mkIf cfg.enable {
    hm.programs.niri.settings = {
      layout = {
        focus-ring = {
          width = 3;

          active.color   = accentColor;
          inactive.color = inactiveColor;
          urgent.color   = urgentColor;
        };
      };
    };
  };
}