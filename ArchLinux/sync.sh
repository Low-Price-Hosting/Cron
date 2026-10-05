#!/usr/bin/env bash
set -euo pipefail
DISTRO=ArchLinux
UPSTREAM=https://gitlab.archlinux.org/archlinux/archlinux-docker.git
DEFAULT_REF=master
discover_releases() { :; }
keep_path() {
  case "$1" in
    .git*|.forgejo/*) return 1 ;;
    *) return 0 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
