#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

FAILED=0

PROFILE_FILE="docs/codex/harness-profile.env"
HARNESS_PROFILE="auto"

if [ -f "$PROFILE_FILE" ]; then
  # shellcheck disable=SC1090
  source "$PROFILE_FILE"
fi

HARNESS_PROFILE="${HARNESS_PROFILE:-auto}"

# Dependency fallback behavior.
# Default: install/sync dependencies when the profile requires them and dependency directories are missing.
VERIFY_AUTO_INSTALL_DEPS="${VERIFY_AUTO_INSTALL_DEPS:-true}"

# Set VERIFY_DIRECT_PACKAGES=true to force direct app/lib/package checks even when root scripts exist.
VERIFY_DIRECT_PACKAGES="${VERIFY_DIRECT_PACKAGES:-auto}"

section() {
  echo
  echo "== $1 =="
}

mark_fail() {
  FAILED=1
}

run_cmd() {
  local description="$1"
  shift

  echo
  echo "Running: $description"
  if "$@"; then
    echo "OK: $description"
  else
    echo "FAIL: $description" >&2
    FAILED=1
  fi
}

run_cmd_or_return() {
  local description="$1"
  shift

  echo
  echo "Running: $description"
  if "$@"; then
    echo "OK: $description"
    return 0
  fi

  echo "FAIL: $description" >&2
  return 1
}

has_package_script() {
  local package_dir="$1"
  local script_name="$2"

  [ -f "$package_dir/package.json" ] || return 1

  node -e "const p=require('./${package_dir}/package.json'); process.exit(p.scripts && p.scripts['${script_name}'] ? 0 : 1)" >/dev/null 2>&1
}

node_script_requires_bin() {
  local package_dir="$1"
  local script_name="$2"
  local bin_name="$3"

  [ -f "$package_dir/package.json" ] || return 1

  node -e "
    const p=require('./${package_dir}/package.json');
    const s=p.scripts && p.scripts['${script_name}'];
    process.exit(s && s.includes('${bin_name}') ? 0 : 1);
  " >/dev/null 2>&1
}

detect_node_runner() {
  if [ -f "pnpm-lock.yaml" ] || [ -f "pnpm-workspace.yaml" ]; then
    if command -v pnpm >/dev/null 2>&1; then
      echo "pnpm"
      return 0
    fi
  fi

  if [ -f "yarn.lock" ]; then
    if command -v yarn >/dev/null 2>&1; then
      echo "yarn"
      return 0
    fi
  fi

  if [ -f "package-lock.json" ] || [ -f "package.json" ]; then
    if command -v npm >/dev/null 2>&1; then
      echo "npm"
      return 0
    fi
  fi

  echo ""
}

iter_node_package_dirs() {
  for package_dir in apps/* libs/* packages/* services/*; do
    [ -d "$package_dir" ] || continue
    [ -f "$package_dir/package.json" ] || continue
    echo "$package_dir"
  done
}

node_deps_missing() {
  [ -f "package.json" ] || return 1

  if [ ! -d "node_modules" ]; then
    return 0
  fi

  # Detect common script binaries used by the scaffold and many TS repos.
  if has_package_script "." "lint" || node_script_requires_bin "." "lint" "eslint"; then
    if [ ! -x "node_modules/.bin/eslint" ] && [ ! -f "node_modules/.bin/eslint" ]; then
      return 0
    fi
  fi

  if has_package_script "." "typecheck" || has_package_script "." "build"; then
    if [ ! -x "node_modules/.bin/tsc" ] && [ ! -f "node_modules/.bin/tsc" ]; then
      return 0
    fi
  fi

  return 1
}

ensure_node_deps() {
  local runner="$1"

  [ -f "package.json" ] || return 0

  if ! node_deps_missing; then
    echo "Node dependencies appear to be installed."
    return 0
  fi

  if [ "$VERIFY_AUTO_INSTALL_DEPS" != "true" ]; then
    echo "Node dependencies appear to be missing, but VERIFY_AUTO_INSTALL_DEPS=false." >&2
    mark_fail
    return 1
  fi

  section "Installing Node dependencies"

  case "$runner" in
    pnpm)
      if [ -f "pnpm-lock.yaml" ]; then
        if ! run_cmd_or_return "pnpm install --frozen-lockfile" pnpm install --frozen-lockfile; then
          echo "Frozen pnpm install failed. Trying normal pnpm install as fallback."
          run_cmd "pnpm install" pnpm install
        fi
      else
        run_cmd "pnpm install" pnpm install
      fi
      ;;
    npm)
      if [ -f "package-lock.json" ]; then
        if ! run_cmd_or_return "npm ci" npm ci; then
          echo "npm ci failed. Trying npm install as fallback."
          run_cmd "npm install" npm install
        fi
      else
        run_cmd "npm install" npm install
      fi
      ;;
    yarn)
      if [ -f "yarn.lock" ]; then
        if ! run_cmd_or_return "yarn install --frozen-lockfile" yarn install --frozen-lockfile; then
          echo "yarn frozen install failed. Trying yarn install as fallback."
          run_cmd "yarn install" yarn install
        fi
      else
        run_cmd "yarn install" yarn install
      fi
      ;;
    *)
      echo "Unsupported Node runner: $runner" >&2
      mark_fail
      return 1
      ;;
  esac

  if node_deps_missing; then
    echo "Node dependencies still appear to be missing after install." >&2
    mark_fail
    return 1
  fi
}

run_node_script() {
  local package_dir="$1"
  local runner="$2"
  local script="$3"

  if [ "$runner" = "pnpm" ]; then
    run_cmd "$package_dir: $script" pnpm --dir "$package_dir" run "$script"
  elif [ "$runner" = "npm" ]; then
    run_cmd "$package_dir: $script" npm --prefix "$package_dir" run "$script"
  elif [ "$runner" = "yarn" ]; then
    if [ "$package_dir" = "." ]; then
      run_cmd "$package_dir: $script" yarn run "$script"
    else
      run_cmd "$package_dir: $script" yarn --cwd "$package_dir" run "$script"
    fi
  else
    echo "Unsupported Node runner: $runner" >&2
    mark_fail
  fi
}

run_node_package_script_if_exists() {
  local package_dir="$1"
  local runner="$2"
  local script="$3"

  if has_package_script "$package_dir" "$script"; then
    run_node_script "$package_dir" "$runner" "$script"
    return 0
  fi

  return 1
}

run_node_checks() {
  local runner
  local script
  local ran_any_root=false
  local package_dir

  section "Node / TypeScript checks"

  runner="$(detect_node_runner)"
  if [ -z "$runner" ]; then
    echo "No Node package runner detected."
    mark_fail
    return 0
  fi

  echo "Detected Node runner: $runner"

  if ! ensure_node_deps "$runner"; then
    echo "Skipping Node checks because dependencies are unavailable."
    return 0
  fi

  for script in lint typecheck test build; do
    if has_package_script "." "$script"; then
      run_node_script "." "$runner" "$script"
      ran_any_root=true
    fi
  done

  # Existing projects often define root scripts that already run recursive workspace checks.
  # Avoid duplicate package-level runs unless no root scripts exist or direct checks are explicitly requested.
  if [ "$VERIFY_DIRECT_PACKAGES" != "true" ] && [ "$ran_any_root" = true ]; then
    echo
    echo "Skipping direct package-level checks because root scripts were found."
    echo "Set VERIFY_DIRECT_PACKAGES=true to force app/lib/package checks."
    return 0
  fi

  for script in lint typecheck test build; do
    while IFS= read -r package_dir; do
      run_node_package_script_if_exists "$package_dir" "$runner" "$script" || true
    done < <(iter_node_package_dirs)
  done
}

poetry_env_missing() {
  [ -f "pyproject.toml" ] || return 1

  if [ ! -d ".venv" ]; then
    return 0
  fi

  if ! poetry run python -c "import sys" >/dev/null 2>&1; then
    return 0
  fi

  local module
  for module in pytest ruff mypy pyright; do
    if grep -Eq "^[[:space:]]*${module}[[:space:]]*=" pyproject.toml && ! poetry run python -c "import ${module}" >/dev/null 2>&1; then
      return 0
    fi
  done

  return 1
}

ensure_poetry_deps() {
  if [ ! -f "pyproject.toml" ]; then
    return 0
  fi

  if ! command -v poetry >/dev/null 2>&1; then
    echo "poetry command is unavailable." >&2
    mark_fail
    return 1
  fi

  if ! poetry_env_missing; then
    echo "Poetry environment appears to be installed."
    return 0
  fi

  if [ "$VERIFY_AUTO_INSTALL_DEPS" != "true" ]; then
    echo "Poetry dependencies appear to be missing, but VERIFY_AUTO_INSTALL_DEPS=false." >&2
    mark_fail
    return 1
  fi

  section "Installing Python dependencies with Poetry"

  # Prefer project-local .venv for reproducible local harness behavior.
  if [ -f "poetry.lock" ]; then
    if ! run_cmd_or_return "POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction --sync" env POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction --sync; then
      echo "Poetry sync install failed. Trying poetry install without --sync."
      run_cmd "POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction" env POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction
    fi
  else
    run_cmd "POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction" env POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction
  fi

  if poetry_env_missing; then
    echo "Poetry dependencies still appear to be missing after install." >&2
    mark_fail
    return 1
  fi
}

uv_env_missing() {
  [ -f "pyproject.toml" ] || return 1

  if [ ! -d ".venv" ]; then
    return 0
  fi

  if ! uv run python -c "import sys" >/dev/null 2>&1; then
    return 0
  fi

  local module
  for module in pytest ruff mypy pyright; do
    if grep -Eq "(^|[\"'[:space:]])${module}([\"'[:space:]=<>~!,])" pyproject.toml && ! uv run --no-sync python -c "import ${module}" >/dev/null 2>&1; then
      return 0
    fi
  done

  return 1
}

ensure_uv_deps() {
  if [ ! -f "pyproject.toml" ]; then
    return 0
  fi

  if ! command -v uv >/dev/null 2>&1; then
    echo "uv command is unavailable." >&2
    mark_fail
    return 1
  fi

  if ! uv_env_missing; then
    echo "uv environment appears to be installed."
    return 0
  fi

  if [ "$VERIFY_AUTO_INSTALL_DEPS" != "true" ]; then
    echo "uv dependencies appear to be missing, but VERIFY_AUTO_INSTALL_DEPS=false." >&2
    mark_fail
    return 1
  fi

  section "Installing Python dependencies with uv"

  if [ -f "uv.lock" ]; then
    if ! run_cmd_or_return "uv sync --frozen" uv sync --frozen; then
      echo "uv frozen sync failed. Trying uv sync as fallback."
      run_cmd "uv sync" uv sync
    fi
  else
    run_cmd "uv sync" uv sync
  fi

  if uv_env_missing; then
    echo "uv dependencies still appear to be missing after sync." >&2
    mark_fail
    return 1
  fi
}

python_module_available_poetry() {
  local module="$1"
  poetry run python -c "import ${module}" >/dev/null 2>&1
}

python_module_available_uv() {
  local module="$1"
  uv run python -c "import ${module}" >/dev/null 2>&1
}

run_python_poetry_checks() {
  section "Python Poetry checks"

  if [ ! -f "pyproject.toml" ]; then
    echo "pyproject.toml not found."
    mark_fail
    return 0
  fi

  if ! command -v poetry >/dev/null 2>&1; then
    echo "poetry command is unavailable." >&2
    mark_fail
    return 0
  fi

  if ! ensure_poetry_deps; then
    echo "Skipping Poetry checks because dependencies are unavailable."
    return 0
  fi

  run_cmd "poetry check" poetry check

  if python_module_available_poetry "ruff"; then
    run_cmd "poetry run ruff check ." poetry run ruff check .
  else
    echo "Skipping ruff: not installed in Poetry environment."
  fi

  if python_module_available_poetry "pytest"; then
    run_cmd "poetry run pytest" poetry run pytest
  else
    echo "Skipping pytest: not installed in Poetry environment."
  fi

  if python_module_available_poetry "mypy"; then
    run_cmd "poetry run mypy ." poetry run mypy .
  else
    echo "Skipping mypy: not installed in Poetry environment."
  fi
}

run_python_uv_checks() {
  section "Python uv checks"

  if [ ! -f "pyproject.toml" ]; then
    echo "pyproject.toml not found."
    mark_fail
    return 0
  fi

  if ! command -v uv >/dev/null 2>&1; then
    echo "uv command is unavailable." >&2
    mark_fail
    return 0
  fi

  if ! ensure_uv_deps; then
    echo "Skipping uv checks because dependencies are unavailable."
    return 0
  fi

  if python_module_available_uv "ruff"; then
    run_cmd "uv run ruff check ." uv run ruff check .
  else
    echo "Skipping ruff: not installed in uv environment."
  fi

  if python_module_available_uv "pytest"; then
    run_cmd "uv run pytest" uv run pytest
  else
    echo "Skipping pytest: not installed in uv environment."
  fi

  if python_module_available_uv "mypy"; then
    run_cmd "uv run mypy ." uv run mypy .
  else
    echo "Skipping mypy: not installed in uv environment."
  fi
}

run_python_auto_checks() {
  section "Python checks"

  if [ ! -f "pyproject.toml" ]; then
    echo "No pyproject.toml detected."
    return 0
  fi

  if grep -q "tool.poetry" pyproject.toml 2>/dev/null; then
    run_python_poetry_checks
  elif [ -f "uv.lock" ] || command -v uv >/dev/null 2>&1; then
    run_python_uv_checks
  elif command -v python >/dev/null 2>&1; then
    run_cmd "python -m pytest" python -m pytest
  else
    echo "No Python runner detected."
    mark_fail
  fi
}

run_gradle_checks() {
  section "JVM Gradle checks"

  if [ -f "gradlew" ]; then
    chmod +x ./gradlew 2>/dev/null || true
    run_cmd "./gradlew test" ./gradlew test
  elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] || [ -f "settings.gradle" ] || [ -f "settings.gradle.kts" ]; then
    if command -v gradle >/dev/null 2>&1; then
      run_cmd "gradle test" gradle test
    else
      echo "Gradle project detected, but gradle command is unavailable and no wrapper was found." >&2
      mark_fail
    fi
  else
    echo "No Gradle project files detected."
    mark_fail
  fi
}

run_maven_checks() {
  section "JVM Maven checks"

  if [ -f "mvnw" ]; then
    chmod +x ./mvnw 2>/dev/null || true
    run_cmd "./mvnw test" ./mvnw test
  elif [ -f "pom.xml" ]; then
    if command -v mvn >/dev/null 2>&1; then
      run_cmd "mvn test" mvn test
    else
      echo "Maven project detected, but mvn command is unavailable and no wrapper was found." >&2
      mark_fail
    fi
  else
    echo "No Maven project files detected."
    mark_fail
  fi
}

run_jvm_auto_checks() {
  if [ -f "gradlew" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] || [ -f "settings.gradle" ] || [ -f "settings.gradle.kts" ]; then
    run_gradle_checks
  fi

  if [ -f "mvnw" ] || [ -f "pom.xml" ]; then
    run_maven_checks
  fi
}

run_auto_detected_checks() {
  if [ -f "package.json" ] || [ -f "pnpm-workspace.yaml" ] || [ -f "package-lock.json" ] || [ -f "yarn.lock" ]; then
    run_node_checks
  fi

  if [ -f "pyproject.toml" ]; then
    run_python_auto_checks
  fi

  run_jvm_auto_checks
}

section "Harness profile"
echo "Profile: $HARNESS_PROFILE"
echo "Auto install dependencies: $VERIFY_AUTO_INSTALL_DEPS"
if [ -f "$PROFILE_FILE" ]; then
  echo "Profile file: $PROFILE_FILE"
else
  echo "Profile file not found. Using auto mode."
fi

section "Repository status"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short
else
  echo "Not a git repository. Skipping git status."
fi

case "$HARNESS_PROFILE" in
  typescript)
    run_node_checks
    ;;
  python-poetry)
    run_python_poetry_checks
    ;;
  python-uv)
    run_python_uv_checks
    ;;
  jvm-gradle-java|jvm-gradle-kotlin)
    run_gradle_checks
    ;;
  jvm-maven-java|jvm-maven-kotlin)
    run_maven_checks
    ;;
  mixed|auto|"")
    run_auto_detected_checks
    ;;
  docs-only)
    section "Documentation-only checks"
    echo "No code verification configured for docs-only profile."
    ;;
  *)
    echo "Unknown HARNESS_PROFILE '$HARNESS_PROFILE'. Falling back to auto detection." >&2
    run_auto_detected_checks
    ;;
esac

section "Verification summary"
if [ "$FAILED" -eq 0 ]; then
  echo "Verification completed successfully."
else
  echo "Verification completed with failures." >&2
  exit 1
fi
