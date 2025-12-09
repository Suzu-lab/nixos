This is a derivation to install a more recent version of OnlyOffice than what is available in nixpkgs

OnlyOffice doesn't provide a flake, so the update is done manually through this derivation.

Just check the newest release available in https://github.com/ONLYOFFICE/DesktopEditors/releases/
and then change the required fields in the "derivation" funcion in default.nix

  derivation = stdenv.mkDerivation rec {
    pname = "onlyoffice-desktopeditors";
    version = "<newest version number>";
    minor = null;
    src = fetchurl {
      url = "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v${version}/onlyoffice-desktopeditors_amd64.deb";
      hash = "<hash of the file according to the github page>";
    };