This is a derivation to install a more recent version of OnlyOffice than what is
available in nixpkgs.

OnlyOffice doesn't provide a flake, so the package is pinned by version + hash in
`default.nix`. Instead of editing those by hand, run the update script:

    ./update.sh          # bump to the latest GitHub release
    ./update.sh 9.4.0    # pin a specific version

It queries the latest release of ONLYOFFICE/DesktopEditors, prefetches the .deb,
and rewrites the `version` and `hash` fields in `default.nix`. Review the diff,
then rebuild with your usual `nixos-rebuild` command.

The same script is wired as `passthru.updateScript`, so it also runs via the
standard nixpkgs update tooling (e.g. `nix-shell maintainers/scripts/update.nix`).
