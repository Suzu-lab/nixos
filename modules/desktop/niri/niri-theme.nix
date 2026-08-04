# Niri layout + focus-ring colours.
#
# Colours come from the shared Catppuccin palette (`suzu.themes.colors`, resolved in
# modules/desktop/themes/default.nix from the flavour/accent set on the host), so changing
# `suzu.themes.accent` recolours the focus ring along with GTK, icons, cursor and VSCodium.
#
# WHY NOT NOCTALIA HERE: Noctalia has a `niri` template and writes ~/.config/niri/noctalia.kdl, and
# niri itself DOES support `include` (verified with `niri validate`). The blocker is home-manager:
# the niri HM module generates config.kdl wholesale from `programs.niri.settings`, with no way to
# inject a raw `include` line alongside it. When niri's config leaves home-manager's hands (the
# planned hjem/nix-maid migration) this becomes a one-liner and the colours below can go.
{
  config,
  lib,
  ...
}:
let
  cfg = config.suzu.themes;
  c = cfg.colors;
in
{
  config = lib.mkIf cfg.enable {
    hm.programs.niri.settings = {
      layout = {
        empty-workspace-above-first = true; # Makes it so workspaces can be created up and down
        always-center-single-column = true; # Makes it so if there's only one column it will be in the center of the screen
        gaps = 10; # gaps between windows in pixels
        struts = {
          top = -7;
        };

        border.enable = false; # The border is set inside the windows, what is set outside is the focus-ring. Setting the border to inactive.

        focus-ring = {
          width = 3;

          active.color = c.${cfg.accent};
          inactive.color = c.surface0;
          urgent.color = c.red;
        };
      };
    };
  };
}
