{
  inputs,
  pkgs,
  ...
}:
{
  services.hardware.deepcool-digital-linux = {
    enable = true;
    package = inputs.ddl.packages.${pkgs.system}.default;
  };
}