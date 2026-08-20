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
require_env "CI_HEAD_BRANCH"
require_env "BRANCH_NAME_REGEX"
require_env "MAIN_SOURCE_POLICY_MESSAGE"

allow_hotfix_to_main="${ALLOW_HOTFIX_TO_MAIN:-false}"
allow_release_to_main="${ALLOW_RELEASE_TO_MAIN:-false}"

if [ "$CI_BASE_BRANCH" = "main" ]; then
  main_source_allowed=false

  if [ "$CI_HEAD_BRANCH" = "develop" ]; then
    main_source_allowed=true
  fi

  if [ "$allow_release_to_main" = "true" ] && printf '%s' "$CI_HEAD_BRANCH" | grep -Eq '^release/[a-z0-9._-]+$'; then
    main_source_allowed=true
  fi

  if [ "$allow_hotfix_to_main" = "true" ] && printf '%s' "$CI_HEAD_BRANCH" | grep -Eq '^hotfix/[a-z0-9._-]+$'; then
    main_source_allowed=true
  fi

  if [ "$main_source_allowed" != "true" ]; then
    printf '%s\n' "$MAIN_SOURCE_POLICY_MESSAGE" >&2
    exit 1
  fi
fi

if [ "$CI_BASE_BRANCH" = "develop" ]; then
  if ! printf '%s' "$CI_HEAD_BRANCH" | grep -Eq "$BRANCH_NAME_REGEX"; then
    printf 'Source branch does not follow the allowed naming convention\n' >&2
    exit 1
  fi
fi
