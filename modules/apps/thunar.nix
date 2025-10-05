  #configure Thunar and it's plugins
	{ pkgs, ... }: {
  	programs.thunar = {
   		enable = true;
   		plugins = with pkgs.xfce; [
   			thunar-archive-plugin
				thunar-media-tags-plugin
   			thunar-volman
   		];
  	};
  }
