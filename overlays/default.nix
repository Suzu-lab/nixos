[
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

  # Flake overlay to fix a problem with jedi-language-server
  (final: prev: {
    python313Packages = prev.python313Packages.override {
      overrides = pfinal: pprev: {
        jedi-language-server = pprev.jedi-language-server.overridePythonAttrs (oldAttrs: {
          postPatch = (oldAttrs.postPatch or "") + ''
            sed -i 's/jedi<0.20,>=0.19.2/jedi>=0.19.2/g' pyproject.toml || true
          '';
        });
      };
    };
  })
]