# Module for setting up special .desktop entries
{ pkgs, ... }:
{
	home-manager.users.suzu.xdg.desktopEntries = {
		# Hiding desktop entries
		"kvantummanager"= {
			name = "Kvantum Manager";
			exec = "kvantummanager";
			NoDisplay = true;
		};
		"qt5ct"= {
			name = "Qt5 Settings";
			exec = "qt5ct";
			NoDisplay = true;
		};
		"qt6ct"= {
			name = "Qt6 Settings";
			exec = "qt6ct";
			NoDisplay = true;
		};
		"htop"= {
			name = "Htop";
			exec = "htop";
			NoDisplay = true;
		};
		"btop"= {
			name = "Btop++";
			exec = "btop";
			NoDisplay = true;
		};
		"micro"= {
			name = "Micro";
			exec = "micro";
			NoDisplay = true;
		};
		"org.nixos.nixos-manual"= {
			name = "NixOS Manual";
			exec = "nixos-manual";
			NoDisplay = true;
		};

		# Custom .desktop entry for OnlyOffice
		"onlyoffice-desktopeditors" = {
			name = "OnlyOffice";
			exec = "onlyoffice-desktopeditors --system-title-bar %U";
		};
	};
}
