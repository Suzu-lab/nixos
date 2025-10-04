  #configure Thunar and it's plugins
  programs.thunar = {
   	enable = true;
   	plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
  };
