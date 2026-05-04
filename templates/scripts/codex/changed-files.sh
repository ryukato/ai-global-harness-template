#!/usr/bin/env bash
set -euo pipefail

echo "Changed files:"
git status --short

echo
echo "Diff name-status:"
git diff --name-status

echo
echo "Staged diff name-status:"
git diff --cached --name-status
