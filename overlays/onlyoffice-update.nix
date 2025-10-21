	# Overlay to update onlyoffice-desktopeditors, according to PR https://github.com/NixOS/nixpkgs/pull/443429/commits/02d7e2ef973e77f1fd020e499ca71eb6cd70faae
	# May be removed after the main unstable channel merges teh PR

	final: prev: {

	  onlyoffice-desktopeditors = prev.onlyoffice-desktopeditors.overrideAttrs (previousAttrs: rec {

	    pname = "onlyoffice-desktopeditors";
	    version = "9.0.4";

	    src = prev.fetchurl { # Using the entire fetchurl function from the package
	      url = "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v${version}/onlyoffice-desktopeditors_amd64.deb";
	      hash = "sha256-wO4t9lE7gHmu41/Q2lYHVZu/oFwaBLY2BndomaFdYho=";
	    };
	  });

	}
