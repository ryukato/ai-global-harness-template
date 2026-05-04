#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

OUT="${1:-ai-global-harness.zip}"

rm -f "$OUT"
zip -r "$OUT" . \
  -x "*.DS_Store" \
  -x ".git/*" \
  -x "$OUT"

echo "Created: $OUT"
