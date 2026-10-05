#!/usr/bin/env bash
set -euo pipefail
DISTRO=Alpine
UPSTREAM=https://github.com/alpinelinux/aports.git
DEFAULT_REF=master

discover_releases() {
  curl -fsSL --retry 3 https://alpinelinux.org/releases.json -o release-data
  jq -r --arg today "$today" '.release_branches[] |
    select(.rel_branch != "edge" and .eol_date >= $today) |
    [.rel_branch,.git_branch] | @tsv' release-data > supported
  while read -r version ref; do
    entry "${version#v}" "$ref" "docker.io/library/alpine:${version#v}" '[]'
  done < supported
  add_latest_alias
}

keep_path() {
  case "$1" in
    scripts/genrootfs.sh|scripts/mkimg.minirootfs.sh|COPYING|LICENSE*) return 0 ;;
    *) return 1 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
