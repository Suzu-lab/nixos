  # GUI fonts
  { pkgs, ... }: {
    home.packages = with pkgs; [
    	noto-fonts
    	noto-fonts-cjk-sans
    	noto-fonts-emoji
    	font-awesome
    	nerd-fonts.jetbrains-mono
		];
  }
