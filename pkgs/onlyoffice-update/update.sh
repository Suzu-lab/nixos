#!/usr/bin/env bash
#
# Auto-update the pinned OnlyOffice DesktopEditors version and hash.
#
# OnlyOffice does not publish a flake, so instead of editing default.nix by
# hand this script queries the latest GitHub release, prefetches the .deb and
# rewrites `version` and `hash` in ./default.nix for you.
#
# Usage:
#   ./update.sh            # update to the latest release
#   ./update.sh 9.4.0      # pin a specific version
#
# Requires: curl, nix (with the nix-command feature, which flakes already need).

set -euo pipefail

repo="ONLYOFFICE/DesktopEditors"
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nixfile="$dir/default.nix"

current="$(grep -oP 'version = "\K[^"]+' "$nixfile" | head -1)"

if [[ $# -ge 1 ]]; then
  latest="${1#v}"
else
  echo "Querying latest release of $repo ..."
  latest="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | grep -oP '"tag_name":\s*"v?\K[^"]+')"
fi

if [[ -z "$latest" ]]; then
  echo "error: could not determine the latest version" >&2
  exit 1
fi

echo "current: $current"
echo "target:  $latest"

if [[ "$latest" == "$current" ]]; then
  echo "Already up to date."
  exit 0
fi

url="https://github.com/$repo/releases/download/v${latest}/onlyoffice-desktopeditors_amd64.deb"
echo "Prefetching $url ..."
sri="$(nix store prefetch-file --hash-type sha256 --json "$url" | grep -oP '"hash":\s*"\K[^"]+')"

if [[ -z "$sri" ]]; then
  echo "error: prefetch failed" >&2
  exit 1
fi

# Rewrite the two fields inside the `derivation` block.
sed -i -E "s|(version = \")[^\"]+(\";)|\1${latest}\2|" "$nixfile"
sed -i -E "s|(hash = \")[^\"]+(\";)|\1${sri}\2|" "$nixfile"

echo
echo "Updated onlyoffice-desktopeditors: $current -> $latest"
echo "  hash = $sri"
echo "Review the diff and rebuild with your usual nixos-rebuild command."
