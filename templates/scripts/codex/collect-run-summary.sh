#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_NAMESPACE="$(basename "$SCRIPT_DIR")"
RUNS_DIR="${HARNESS_RUNS_DIR:-.$AGENT_NAMESPACE-runs}"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

RUN_DIR="${1:-}"

if [ -z "$RUN_DIR" ]; then
  RUN_DIR="$(find "$RUNS_DIR" -maxdepth 1 -type d | sort | tail -n 1)"
fi

if [ ! -d "$RUN_DIR" ]; then
  echo "Run directory not found: $RUN_DIR" >&2
  exit 1
fi

git status --short > "$RUN_DIR/changed-files.txt"
git diff --name-status > "$RUN_DIR/diff-name-status.txt"
git diff --stat > "$RUN_DIR/diffstat.txt"

cat > "$RUN_DIR/summary.md" <<'SUMMARY'
# Run Summary

## Summary

TODO

## Files changed

See `changed-files.txt`.

## Diffstat

See `diffstat.txt`.

## Verification result

TODO

## Risks / follow-up

TODO
SUMMARY

echo "Collected run summary:"
echo "$RUN_DIR"
