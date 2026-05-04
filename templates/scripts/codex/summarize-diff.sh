#!/usr/bin/env bash
set -euo pipefail

echo "Repository status"
echo "-----------------"
git status --short

echo
echo "Changed files"
echo "-------------"
git diff --name-status

echo
echo "Diffstat"
echo "--------"
git diff --stat

echo
echo "Staged diffstat"
echo "---------------"
git diff --cached --stat
