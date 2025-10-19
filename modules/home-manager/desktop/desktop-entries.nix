# Module for setting up special .desktop entries
{ pkgs, ... }:
{
	xdg.desktopEntries = {
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
		"nixos-manual"= {
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

		# Fixing electron apps rendering in Wayland
		"codium" = {
			name = "VSCodium";
			exec = "codium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3 %F";
		};
		"ferdium" = {
			name = "Ferdium";
			exec = "ferdium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3 %F";
		};
	};
}
