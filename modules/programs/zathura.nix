{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  hm.programs.zathura = {
    enable = true;

    package = (pkgs.zathura.override { plugins = with pkgs.zathuraPkgs; [ zathura_pdf_mupdf ]; });

  };
}
