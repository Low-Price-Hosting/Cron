#!/usr/bin/env bash
set -euo pipefail
DISTRO=Fedora
UPSTREAM=https://forge.fedoraproject.org/releng/kiwi-descriptions.git
DEFAULT_REF=rawhide

discover_releases() {
  curl -fsSL --retry 3 https://fedoraproject.org/releases.json -o release-data
  latest=$(jq -r '[.[] | .version | select(test("^[0-9]+$")) | tonumber] | max' release-data)
  for version in "$((latest - 1))" "$latest"; do
    grep -q "refs/heads/f$version$" upstream-refs
    entry "$version" "f$version" "registry.fedoraproject.org/fedora:$version" '[]'
  done
  add_latest_alias
}

keep_path() {
  # Fedora.kiwi includes the profile definitions and their XML dependencies.
  # The build invokes only the Container-Base-Generic OCI profile.
  case "$1" in
    .git*|.forgejo/*|.packit*) return 1 ;;
    *) return 0 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
