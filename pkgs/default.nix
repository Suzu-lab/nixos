# Definition of customized packages
{ pkgs }:
{
  onlyoffice-904 = pkgs.callPackage ./onlyoffice-904 {

  };
  ferdium-711 = pkgs.callPackage ./ferdium-711 {
    mkFranzDerivation =
      pkgs.callPackage "${pkgs.path}/pkgs/applications/networking/instant-messengers/franz/generic.nix"
        { };
  };
}
