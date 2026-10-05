#!/usr/bin/env bash
set -euo pipefail
DISTRO=AlmaLinux
UPSTREAM=https://github.com/AlmaLinux/container-images.git
DEFAULT_REF=main
discover_releases() { :; }
keep_path() {
  case "$1" in
    Containerfiles/*|LICENSE|README*) return 0 ;;
    *) return 1 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
