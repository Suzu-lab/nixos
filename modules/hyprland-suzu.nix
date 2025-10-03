  # Declarative config files for the desktop environment
  { pkgs, ... }:
  {
    #configure Thunar plugins
    programs.thunar = {
    	enable = true;
    	plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };

  	# Essential GUI apps
  	environment.systemPackages = with pkgs; [
      cliphist
      grim
      hyprlock
      hyprpaper
      kitty
  		mako
  		slurp
  		waybar
  		wl-clipboard
  		xarchiver
  	];

  	# GUI fonts
  	fonts.packages = with pkgs; [
  		noto-fonts
  		noto-fonts-cjk-sans
  		noto-fonts-emoji
  		font-awesome
  	];
    # Hyprland config (~/.config/hypr/hyprland.conf)
    xdg.configFile."hypr/hyprland.conf".source = ./hyprland/hyprland.conf;

    # Waybar config (~/.config/waybar/config.jsonc)
    xdg.configFile."waybar/config.jsonc".source = ./hyprland/waybar.jsonc;

    # Config of waybar style sheet (~/.config/waybar/style.css)
    xdg.configFile."waybar/style.css".source = ./hyprland/waybar.style;
  }
