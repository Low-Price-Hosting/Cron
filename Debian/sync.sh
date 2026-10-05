#!/usr/bin/env bash
set -euo pipefail
DISTRO=Debian
UPSTREAM=https://github.com/debuerreotype/debuerreotype.git
DEFAULT_REF=master

discover_releases() {
  sudo apt-get update -qq
  sudo apt-get install -y -qq distro-info-data
  awk -F, -v today="$today" 'NR==1 {for(i=1;i<=NF;i++) col[$i]=i; next}
    $(col["release"]) != "" && $(col["release"]) <= today {
      end=$(col["eol"]);
      if(col["eol-lts"] && $(col["eol-lts"]) > end) end=$(col["eol-lts"]);
      if(end >= today) print $(col["series"]),$(col["version"]);
    }' /usr/share/distro-info/debian.csv > supported
  stable=$(curl -fsSL --retry 3 https://deb.debian.org/debian/dists/stable/Release | sed -n 's/^Codename: //p')
  while read -r suite version; do
    aliases="[\"$version\"]"
    [[ "$suite" != "$stable" ]] || aliases="[\"$version\",\"stable\",\"latest\"]"
    entry "$suite" main "docker.io/library/debian:$suite" "$aliases"
  done < supported
  jq -e 'length > 0' releases.json >/dev/null
}

keep_path() {
  case "$1" in
    scripts/*|examples/debian.sh|examples/oci-image.sh|VERSION|LICENSE|README*) return 0 ;;
    *) return 1 ;;
  esac
}
source "$(dirname -- "$0")/../scripts/sync-common.sh"
