#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_NAMESPACE="$(basename "$SCRIPT_DIR")"
DOCS_DIR="${HARNESS_DOCS_DIR:-docs/$AGENT_NAMESPACE}"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

FAILED=0

PROFILE_FILE="$DOCS_DIR/harness-profile.env"
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

package_manager_from_package_json() {
  [ -f "package.json" ] || return 1
  command -v node >/dev/null 2>&1 || return 1

  node -e "
    try {
      const p = require('./package.json');
      process.stdout.write(p.packageManager || '');
    } catch (_) {}
  " 2>/dev/null
}

corepack_has_runner() {
  local runner="$1"

  command -v corepack >/dev/null 2>&1 || return 1
  corepack "$runner" --version >/dev/null 2>&1
}

detect_node_runner() {
  local declared_pm
  declared_pm="$(package_manager_from_package_json || true)"

  case "$declared_pm" in
    pnpm|pnpm@*)
      if corepack_has_runner "$declared_pm"; then
        echo "corepack:$declared_pm"
        return 0
      fi
      if command -v pnpm >/dev/null 2>&1; then
        echo "pnpm"
        return 0
      fi
      ;;
    yarn|yarn@*)
      if corepack_has_runner "$declared_pm"; then
        echo "corepack:$declared_pm"
        return 0
      fi
      if command -v yarn >/dev/null 2>&1; then
        echo "yarn"
        return 0
      fi
      ;;
    npm)
      if command -v npm >/dev/null 2>&1; then
        echo "npm"
        return 0
      fi
      ;;
  esac

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

describe_node_runner() {
  case "$1" in
    corepack:*)
      echo "corepack ${1#corepack:}"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

warn_global_package_manager_fallback() {
  local runner="$1"
  local declared_pm
  local declared_name
  declared_pm="$(package_manager_from_package_json || true)"
  declared_name="${declared_pm%%@*}"

  if [ -n "$declared_name" ] && [ "$declared_name" = "$runner" ] && ! command -v corepack >/dev/null 2>&1; then
    echo "WARN: package.json declares packageManager=$declared_pm, but corepack is unavailable. Falling back to global $runner." >&2
  fi
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
    corepack:pnpm|corepack:pnpm@*)
      local corepack_pm="${runner#corepack:}"
      if [ -f "pnpm-lock.yaml" ]; then
        if ! run_cmd_or_return "corepack $corepack_pm install --frozen-lockfile" corepack "$corepack_pm" install --frozen-lockfile; then
          echo "Frozen pnpm install failed. Trying normal corepack $corepack_pm install as fallback."
          run_cmd "corepack $corepack_pm install" corepack "$corepack_pm" install
        fi
      else
        run_cmd "corepack $corepack_pm install" corepack "$corepack_pm" install
      fi
      ;;
    pnpm)
      warn_global_package_manager_fallback "$runner"
      if [ -f "pnpm-lock.yaml" ]; then
        if ! run_cmd_or_return "pnpm install --frozen-lockfile" pnpm install --frozen-lockfile; then
          echo "Frozen pnpm install failed. Trying normal pnpm install as fallback."
          echo "If global pnpm is incompatible with the active Node version, try: corepack pnpm install --frozen-lockfile"
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
    corepack:yarn|corepack:yarn@*)
      local corepack_pm="${runner#corepack:}"
      if [ -f "yarn.lock" ]; then
        if ! run_cmd_or_return "corepack $corepack_pm install --frozen-lockfile" corepack "$corepack_pm" install --frozen-lockfile; then
          echo "yarn frozen install failed. Trying corepack $corepack_pm install as fallback."
          run_cmd "corepack $corepack_pm install" corepack "$corepack_pm" install
        fi
      else
        run_cmd "corepack $corepack_pm install" corepack "$corepack_pm" install
      fi
      ;;
    yarn)
      warn_global_package_manager_fallback "$runner"
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

  if [[ "$runner" == corepack:pnpm* ]]; then
    local corepack_pm="${runner#corepack:}"
    run_cmd "$package_dir: $script" corepack "$corepack_pm" --dir "$package_dir" run "$script"
  elif [ "$runner" = "pnpm" ]; then
    run_cmd "$package_dir: $script" pnpm --dir "$package_dir" run "$script"
  elif [ "$runner" = "npm" ]; then
    run_cmd "$package_dir: $script" npm --prefix "$package_dir" run "$script"
  elif [[ "$runner" == corepack:yarn* ]]; then
    local corepack_pm="${runner#corepack:}"
    if [ "$package_dir" = "." ]; then
      run_cmd "$package_dir: $script" corepack "$corepack_pm" run "$script"
    else
      run_cmd "$package_dir: $script" corepack "$corepack_pm" --cwd "$package_dir" run "$script"
    fi
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

warn_placeholder_test_script() {
  local package_dir="$1"

  [ -f "$package_dir/package.json" ] || return 0
  command -v node >/dev/null 2>&1 || return 0

  node -e "
    const fs = require('fs');
    const path = process.argv[1];
    try {
      const p = JSON.parse(fs.readFileSync(path, 'utf8'));
      const test = p.scripts && p.scripts.test;
      process.exit(test && test.includes('No tests configured') ? 0 : 1);
    } catch (_) {
      process.exit(1);
    }
  " "$package_dir/package.json" >/dev/null 2>&1 || return 0

  echo "WARN: $package_dir test script is a scaffold placeholder: No tests configured." >&2
  echo "WARN: Placeholder tests are acceptable for bootstrapping, but they do not provide release confidence." >&2
}

warn_placeholder_test_scripts() {
  local package_dir

  warn_placeholder_test_script "."
  while IFS= read -r package_dir; do
    warn_placeholder_test_script "$package_dir"
  done < <(iter_node_package_dirs)
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
  echo "Node command: $(describe_node_runner "$runner")"

  if ! ensure_node_deps "$runner"; then
    echo "Skipping Node checks because dependencies are unavailable."
    return 0
  fi

  warn_placeholder_test_scripts

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

validate_frontmatter_file() {
  local file="$1"
  local first_line

  [ -f "$file" ] || return 0

  first_line="$(sed -n '1p' "$file")"
  if [ "$first_line" != "---" ]; then
    echo "FAIL: $file missing YAML frontmatter opening line." >&2
    mark_fail
    return 0
  fi

  local frontmatter_status
  set +e
  awk '
    NR == 1 { next }
    /^---$/ { exit }
    /^name:[[:space:]]*[^[:space:]]/ { name = 1 }
    /^description:[[:space:]]*./ { description = 1 }
    END {
      if (!name) exit 2
      if (!description) exit 3
    }
  ' "$file"
  frontmatter_status="$?"
  set -e

  case "$frontmatter_status" in
    0)
      ;;
    2)
      echo "FAIL: $file frontmatter missing name." >&2
      mark_fail
      ;;
    3)
      echo "FAIL: $file frontmatter missing description." >&2
      mark_fail
      ;;
  esac
}

run_frontmatter_checks() {
  local found=false
  local file

  section "Agent and skill frontmatter checks"

  for file in .claude/agents/*.md .claude/skills/*/SKILL.md .agents/skills/*/SKILL.md; do
    [ -e "$file" ] || continue
    found=true
    validate_frontmatter_file "$file"
  done

  if [ "$found" = false ]; then
    echo "No Claude/agent skill files found for frontmatter checks."
  fi
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

run_frontmatter_checks

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
