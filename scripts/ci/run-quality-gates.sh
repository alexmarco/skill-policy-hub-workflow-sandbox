#!/usr/bin/env bash

set -euo pipefail

quality_dir="${QUALITY_SCRIPTS_DIR:-scripts/quality}"

run_gate() {
  local gate_script="$1"
  local gate_name

  if [ ! -x "$gate_script" ]; then
    printf 'Quality gate script is missing or not executable: %s\n' "$gate_script" >&2
    exit 1
  fi

  gate_name="$(basename "$gate_script" .sh)"
  printf 'Running quality gate: %s\n' "$gate_name"
  "$gate_script"
}

if [ "$#" -gt 0 ]; then
  for gate_name in "$@"; do
    run_gate "$quality_dir/$gate_name.sh"
  done
  exit 0
fi

if [ ! -d "$quality_dir" ]; then
  printf 'No quality gate scripts configured.\n'
  exit 0
fi

configured_gate=false
for gate_script in "$quality_dir"/*.sh; do
  if [ ! -e "$gate_script" ]; then
    continue
  fi

  configured_gate=true
  run_gate "$gate_script"
done

if [ "$configured_gate" != "true" ]; then
  printf 'No quality gate scripts configured.\n'
fi
