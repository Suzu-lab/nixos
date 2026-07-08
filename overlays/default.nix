[
  # Custom package: a newer OnlyOffice than nixpkgs ships. Exposed through the
  # overlay so it's available as pkgs.onlyoffice-update everywhere, like any
  # other package (no separate `mypkgs` argument needed).
  (final: prev: {
    onlyoffice-update = prev.callPackage ../pkgs/onlyoffice-update { };
  })

  # Custom multi-surface Electron client for the local AI companion (VRM avatar + prompt).
  # Exposed as pkgs.companion-client, providing the `companion` binary.
  (final: prev: {
    companion-client = prev.callPackage ../pkgs/companion-client { };
  })

  # OpenDeck (stream deck software for the Ajazz AKP03E), built natively from Azelphur's fork's
  # package (vendored into pkgs/opendeck with the Deno-deps hash re-pinned for our nixpkgs deno).
  (final: prev: {
    opendeck = prev.callPackage ../pkgs/opendeck/package.nix { };
  })


  # Flake overlay to set Chromium settings
  (final: prev: {
    ungoogled-chromium = prev.ungoogled-chromium.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations"
        "--enable-features=VaapiVideoDecoder"
        "--ignore-gpu-blocklist"
      ];
    };
  })

  # Flake overlay to temporarily fix a temporary issue in openldap on NixOS Unstable - https://github.com/NixOS/nixpkgs/issues/514113
  # REmove after the problem is solved
  (final: prev: {
    openldap = prev.openldap.overrideAttrs (_: {
      doCheck = !prev.stdenv.hostPlatform.isi686;
    });
  })
]