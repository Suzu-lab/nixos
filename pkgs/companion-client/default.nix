# The custom multi-surface Electron client for the local AI companion (renders the OLV
# backend as a VRM avatar + summonable text prompt). No bundler — the app is static files
# served as-is; buildNpmPackage only fetches the JS deps (three, @pixiv/three-vrm, ws).
# Provides a `companion` binary (electron wrapped with the Wayland ozone flags).
{
  lib,
  buildNpmPackage,
  electron,
  makeWrapper,
}:
buildNpmPackage {
  pname = "companion-client";
  version = "0.1.0";

  # node_modules is populated by npm ci during the build; keep it out of the source copy.
  src = lib.cleanSourceWith {
    src = ../../modules/ai/companion/client;
    filter = name: _type: baseNameOf name != "node_modules";
  };

  npmDepsHash = "sha256-M6Tvg5PARVO86kmwg5CBQAUZIlmbc/LnK4I4Tqq6vdA=";

  dontNpmBuild = true; # nothing to build; renderers are loaded as static files
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/companion-client
    cp -r . $out/share/companion-client/
    makeWrapper ${lib.getExe electron} $out/bin/companion \
      --add-flags $out/share/companion-client \
      --add-flags "--ozone-platform-hint=auto --enable-features=UseOzonePlatform --ozone-platform=wayland" \
      --unset ELECTRON_RUN_AS_NODE
    runHook postInstall
  '';

  meta = {
    description = "Custom multi-surface Electron client for the local AI companion";
    mainProgram = "companion";
  };
}
