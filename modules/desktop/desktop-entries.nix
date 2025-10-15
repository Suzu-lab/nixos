# Module for setting up special .desktop entries
{ pkgs, ... }:
{
	home-manager.users.suzu.xdg.desktopEntries = {
		# Hiding desktop entries
		"kvantummanager"= {
			name = "Kvantum Manager";
			exec = "kvantummanager";
			noDisplay = true;
		};
		"qt5ct"= {
			name = "Qt5 Settings";
			exec = "qt5ct";
			noDisplay = true;
		};
		"qt6ct"= {
			name = "Qt6 Settings";
			exec = "qt6ct";
			noDisplay = true;
		};
		"htop"= {
			name = "Htop";
			exec = "htop";
			noDisplay = true;
		};
		"btop"= {
			name = "Btop++";
			exec = "btop";
			noDisplay = true;
		};
		"micro"= {
			name = "Micro";
			exec = "micro";
			noDisplay = true;
		};
		"org.nixos.nixos-manual"= {
			name = "NixOS Manual";
			exec = "nixos-manual";
			noDisplay = true;
		};

		# Custom .desktop entry for OnlyOffice
		"onlyoffice-desktopeditors" = {
			name = "OnlyOffice";
			exec = "onlyoffice-desktopeditors --custom-title-bar %U";
			categories = [ "Office" "WordProcessor" "Spreadsheet" "Presentation" ];
		};
	};
}
