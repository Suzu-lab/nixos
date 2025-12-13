{ 
  config,
  lib, 
  ... 
}:
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
        empty-workspace-above-first = true; # Makes it so workspaces can be created up and down
        always-center-single-column = true; # Makes it so if there's only one column it will be in the centro of the screen
        gaps = 10; # gapes between windows in pixels
        struts = {
          top = -7;
        };

        border.enable = false; # The border is set inside the windows, what is set outside is the focus-ring. Setting the border to inactive.

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