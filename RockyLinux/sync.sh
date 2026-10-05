#!/usr/bin/env bash
set -euo pipefail
DISTRO=RockyLinux
UPSTREAM=https://github.com/rocky-linux/kickstarts.git
DEFAULT_REF=main
discover_releases() { :; }
extra_refs() {
  awk '$2 ~ /refs\/heads\/r[0-9]+$/ {sub(/^refs\/heads\//,"",$2); print $2 "\t" $2}' \
    upstream-refs >> selected-refs
}
keep_path() {
  case "$1" in
    *Container*.ks|container/*|LICENSE*|README*) return 0 ;;
    *) return 1 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
