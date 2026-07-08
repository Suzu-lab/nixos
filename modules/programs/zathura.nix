{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.programs.zathura;
in
{
  options.suzu.programs.zathura.enable = lib.mkEnableOption "Zathura document viewer";

  config = lib.mkIf cfg.enable {
    hm.programs.zathura = {
      enable = true;

      package = (pkgs.zathura.override { plugins = with pkgs.zathuraPkgs; [ zathura_pdf_mupdf ]; });

    };
  };
}
