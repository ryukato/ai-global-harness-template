#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_NAMESPACE="$(basename "$SCRIPT_DIR")"
DOCS_DIR="${HARNESS_DOCS_DIR:-docs/$AGENT_NAMESPACE}"
RUNS_DIR="${HARNESS_RUNS_DIR:-.$AGENT_NAMESPACE-runs}"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

SINCE="${1:-7 days ago}"
OUT_DIR="$DOCS_DIR/reports"
mkdir -p "$OUT_DIR"

OUT_FILE="$OUT_DIR/weekly-report-$(date +%Y%m%d).md"

{
  echo "# Weekly AI Harness Report"
  echo
  echo "Since: $SINCE"
  echo
  echo "## Git Summary"
  echo
  echo '```text'
  git log --since="$SINCE" --oneline || true
  echo '```'
  echo
  echo "## Diffstat"
  echo
  echo '```text'
  git diff --stat "HEAD@{7.days.ago}"..HEAD 2>/dev/null || git diff --stat || true
  echo '```'
  echo
  echo "## Recent AI Run Logs"
  echo
  if [ -d "$RUNS_DIR" ]; then
    find "$RUNS_DIR" -maxdepth 1 -type d | sort | tail -n 20
  else
    echo "No $RUNS_DIR directory."
  fi
  echo
  echo "## Notes"
  echo
  echo "- TODO: summarize repeated failures, verification issues, and follow-up items."
} > "$OUT_FILE"

echo "Created report:"
echo "$OUT_FILE"
