#configure Thunar and it's plugins
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xfce.thunar

    #plugins
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin
    xfce.thunar-volman
  ];
}
