{
  inputs,
  system,
  ...
}:
{
  services.hardware.deepcool-digital-linux = {
    enable = true;
    # The upstream package lacks meta.mainProgram, which makes lib.getExe (used
    # by the service module) emit a deprecation warning. Add it via overrideAttrs.
    package = inputs.ddl.packages.${system}.default.overrideAttrs (old: {
      meta = (old.meta or { }) // { mainProgram = "deepcool-digital-linux"; };
    });
  };
}