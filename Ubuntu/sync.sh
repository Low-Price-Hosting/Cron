#!/usr/bin/env bash
set -euo pipefail
DISTRO=Ubuntu
UPSTREAM=https://git.launchpad.net/livecd-rootfs
DEFAULT_REF=ubuntu/master

discover_releases() {
  sudo apt-get update -qq
  sudo apt-get install -y -qq distro-info-data
  # Public support dates, rather than the upgrade service's ESM flags.
  awk -F, -v today="$today" 'NR==1 {for(i=1;i<=NF;i++) col[$i]=i; next}
    $(col["release"]) != "" && $(col["release"]) <= today {
      end=$(col["eol-server"]); if(end == "") end=$(col["eol"]);
      if(end >= today) print $(col["series"]);
    }' /usr/share/distro-info/ubuntu.csv > public-suites
  curl -fsSL --retry 3 https://changelogs.ubuntu.com/meta-release -o release-data
  awk 'BEGIN {RS=""; FS="\n"} {dist=""; version=""; supported=0;
    for(i=1;i<=NF;i++) {
      if($i ~ /^Dist: /) dist=substr($i,7);
      if($i ~ /^Version: /) {version=substr($i,10); sub(/ .*/,"",version)}
      if($i == "Supported: 1") supported=1;
    } if(supported && dist != "" && version != "") print dist,version;
  }' release-data > supported
  while read -r suite version; do
    grep -qx "$suite" public-suites || continue
    version=$(cut -d. -f1,2 <<< "$version")
    ref="ubuntu/$suite"
    grep -q "refs/heads/$ref$" upstream-refs || ref="$DEFAULT_REF"
    entry "$version" "$ref" "docker.io/library/ubuntu:$version" "[\"$suite\"]"
  done < supported
  add_latest_alias
}

keep_path() {
  case "$1" in
    live-build/auto/*|debian/*|COPYING|README*|minimize-manual|auto-markable-pkgs|sync-mtime) return 0 ;;
    live-build/*) [[ "${1#live-build/}" != */* ]] ;;
    *) return 1 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
