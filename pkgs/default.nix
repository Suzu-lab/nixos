# Definition of customized packages
{ pkgs }:
{
  onlyoffice-update = pkgs.callPackage ./onlyoffice-update {
  };
}
