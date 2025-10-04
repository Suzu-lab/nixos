  #configure Thunar and it's plugins
	{ pkgs, ... }: {
  	programs.xfce.thunar = {
   		enable = true;
   		plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
  	};
  }
