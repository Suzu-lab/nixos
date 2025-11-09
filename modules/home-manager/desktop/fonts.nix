  # GUI fonts
  { pkgs, ... }: {
    home.packages = with pkgs; [
    	noto-fonts
    	noto-fonts-cjk-sans
    	noto-fonts-color-emoji
    	noto-fonts-monochrome-emoji
    	font-awesome
    	nerd-fonts.jetbrains-mono
		];

		fonts.fontconfig = {
			enable = true;
			antialiasing = true;
			defaultFonts = {
				emoji = [ "Noto Color Emoji" ];
				monospace = [ "Noto Mono" ];
				sansSerif = [ "Noto Sans" ];
				serif = [ "Noto Serif" ];
			};
		};
  }
