#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s <commit-message-file>\n' "$0" >&2
  exit 1
fi

commit_message_file="$1"
config_file="${COMMITLINT_CONFIG:-.commitlintrc.json}"
commitlint_package="${COMMITLINT_PACKAGE:-@commitlint/cli@20.1.0}"

if [ ! -f "$commit_message_file" ]; then
  printf 'Missing commit message file: %s\n' "$commit_message_file" >&2
  exit 1
fi

if [ ! -f "$config_file" ]; then
  printf 'Missing commitlint config file: %s\n' "$config_file" >&2
  exit 1
fi

npx --yes --package "$commitlint_package" commitlint --config "$config_file" --edit "$commit_message_file" --verbose
