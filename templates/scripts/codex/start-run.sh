#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_NAMESPACE="$(basename "$SCRIPT_DIR")"
RUNS_DIR="${HARNESS_RUNS_DIR:-.$AGENT_NAMESPACE-runs}"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

SLUG="${1:-task}"
STAMP="$(date +%Y%m%d-%H%M)"
RUN_DIR="$RUNS_DIR/${STAMP}-${SLUG}"

mkdir -p "$RUN_DIR"

cat > "$RUN_DIR/task.md" <<'TASK'
# Task

TODO: Paste the task here.
TASK

git status --short > "$RUN_DIR/changed-files.before.txt"

echo "Created run directory:"
echo "$RUN_DIR"
