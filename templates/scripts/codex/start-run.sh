#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

SLUG="${1:-task}"
STAMP="$(date +%Y%m%d-%H%M)"
RUN_DIR=".codex-runs/${STAMP}-${SLUG}"

mkdir -p "$RUN_DIR"

cat > "$RUN_DIR/task.md" <<'TASK'
# Task

TODO: Paste the task here.
TASK

git status --short > "$RUN_DIR/changed-files.before.txt"

echo "Created run directory:"
echo "$RUN_DIR"
