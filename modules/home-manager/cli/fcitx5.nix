	# Configuration for fcitx5 IME (for special character inputs with dead keys)
	{ pkgs, config, ... }:
	{
		home.sessionVariables = {
			GTK_IM_MODULE = "fcitx";
			QT_IM_MODULE = "fcitx";
			XMODIFIERS = "@im=fcitx";
			SDL_IM_MODULE = "fcitx";
			INPUT_METHOD = "fcitx";
		};

		home.packages = with pkgs; [
			fcitx5 # package for solving special character problems
			fcitx5-gtk
			libsForQt5.fcitx5-qt
			kdePackages.fcitx5-configtool
		];

		systemd.user.services.fcitx5-daemon = {
			Unit = {
				Description = "Fcitx 5 Daemon";
				After = [ "graphical-session.target" ];
				PartOf = [ "graphical-session.target" ];
			};
			Service = {
				ExecStart = "${pkgs.fcitx5}/bin/fcitx5";
				Restart = "on-failure";
			};
			Install = {
				WantedBy = [ "graphical-session.target" ];
			};
		};

		# Declarative config files for the fcitx5 profile
		i18n.inputMethod.fcitx5.settings.inputMethod = {
			GroupOrder."0" = "Default";
			GroupOrder."1" = "ABNT";
			"Groups/0" = {
				Name = "Default";
				"Default Layout" = "us-intl";
				"Default IM" = "keyboard-us-intl";
			};
			"Groups/0/Items/0".Name = "keyboard-us-intl";
			"Groups/1" = {
				Name = "ABNT";
				"Default Layout" = "br";
				"Default IM" = "keyboard-br";
			};
			"Groups/1/Items/0".Name = "keyboard-br";
		};
	}
