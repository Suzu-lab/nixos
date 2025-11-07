{ config, lib, inputs, pkgs, ... }:
let
	colors = config.lib.stylix.colors;
in
{
  programs.zathura = {
    enable = true;

		package = (pkgs.zathura.override { plugins = with pkgs.zathuraPkgs; [ zathura_pdf_mupdf ]; });

    options =
    with colors.withHashtag; {
      recolor = true;
      selection-clipboard = "wl-clipboard";

      # Define theming
      notification-error-bg = "${base02}";
      notification-error-fg = "${base08}";
      notification-warning-bg = "${base02}";
      notification-warning-fg = "${base08}";
      notification-bg = "${base02}";
      notification-fg = "${base0A}";

      completion-group-bg = "${base00}";
      completion-group-fg = "${base04}";
      completion-bg = "${base01}";
      completion-fg = "${base06}";
      completion-highlight-bg = "${base02}";
      completion-highlight-fg = "${base07}";

      index-bg = "${base01}";
      index-fg = "${base06}";
      index-active-bg = "${base02}";
      index-active-fg = "${base07}";

      inputbar-bg = "${base02}";
      inputbar-fg = "${base07}";

      statusbar-bg = "${base01}";
      statusbar-fg = "${base06}";

      highlight-color = "${base03}";
      highlight-active-color = "${base0D}";

      default-bg = "${base01}";
      default-fg = "${base06}";

      recolor-lightcolor = "${base01}";
      recolor-darkcolor = "${base05}";
    };
  };
}
