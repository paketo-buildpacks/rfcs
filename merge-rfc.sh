#!/usr/bin/env zsh

set -eu

id() {
  ID=$(find accepted -depth 1 | sed -E 's|^accepted/([[:digit:]]{4})-.*$|\1|' | sort | tail -n 1)
  ((ID++))
  printf "%04d" "${ID}"
}

if [[ $# != 1 ]]; then
  printf "Usage: %s <PR#>\n" "${0:t}"
  exit 1
fi

git pull origin --rebase

PR="${1}"
ID=$(id)

git fetch origin "pull/${PR}/head:rfc-${ID}"
git merge "rfc-${ID}" --signoff --no-edit --no-ff
git branch -d "rfc-${ID}"

SOURCE=$(find . -depth 2 -name '0000-*' | grep -v 0000-template.md)
TARGET="./accepted/$(basename ${SOURCE//0000/$(printf "%04d" "${ID}")})"

git mv "${SOURCE}" "${TARGET}"
git add "${TARGET}"
git commit --signoff --message "RFC #${ID}

[#${PR}]
"
