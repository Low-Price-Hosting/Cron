#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
gh api repos/Low-Price-Hosting/Container/contents/scripts/update-release-groups.sh \
  --header 'Accept: application/vnd.github.raw+json' > "$work/update-release-groups.sh"
bash "$work/update-release-groups.sh"
jq -n --arg source "${SOURCE:-all}" '{event_type:"source-mirrors-updated",client_payload:{distribution:$source}}' \
  | gh api -X POST repos/Low-Price-Hosting/Container/dispatches --input -
