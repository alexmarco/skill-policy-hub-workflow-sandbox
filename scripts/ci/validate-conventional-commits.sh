#!/usr/bin/env bash

set -euo pipefail

require_env() {
  local variable_name="$1"

  if [ -z "${!variable_name:-}" ]; then
    printf 'Missing required environment variable: %s\n' "$variable_name" >&2
    exit 1
  fi
}

require_env "CI_BASE_BRANCH"

config_file="${COMMITLINT_CONFIG:-.commitlintrc.json}"
commitlint_package="${COMMITLINT_PACKAGE:-@commitlint/cli@20.1.0}"
fetch_ref="${CI_FETCH_REF:-refs/heads/$CI_BASE_BRANCH:refs/remotes/origin/$CI_BASE_BRANCH}"
commit_range="${CI_COMMIT_RANGE:-origin/$CI_BASE_BRANCH..HEAD}"

if [ ! -f "$config_file" ]; then
  printf 'Missing commitlint config file: %s\n' "$config_file" >&2
  exit 1
fi

git fetch origin "$fetch_ref" --depth=1

case "$commit_range" in
  *..*)
    range_start="${commit_range%%..*}"
    range_end="${commit_range#*..}"
    ;;
  *)
    printf 'CI_COMMIT_RANGE must use <from>..<to> syntax: %s\n' "$commit_range" >&2
    exit 1
    ;;
esac

if [ -z "$(git rev-list --reverse "$range_start..$range_end")" ]; then
  exit 0
fi

npx --yes --package "$commitlint_package" commitlint --config "$config_file" --from "$range_start" --to "$range_end" --verbose
