#!/usr/bin/env bash
set -euo pipefail
DISTRO=Centos
UPSTREAM=https://gitlab.com/redhat/centos-stream/release-engineering/kickstarts.git
DEFAULT_REF=main
discover_releases() { :; }
keep_path() {
  case "$1" in
    *container*.ks|LICENSE*|README*) return 0 ;;
    *) return 1 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
