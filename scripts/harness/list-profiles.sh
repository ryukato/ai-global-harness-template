#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

cat <<'PROFILES'
docs-only
jvm-gradle-java
jvm-gradle-kotlin
jvm-maven-java
jvm-maven-kotlin
mixed
planning-design
python-poetry
python-uv
typescript
PROFILES
