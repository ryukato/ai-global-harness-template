#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

PROFILE_FILE="docs/codex/harness-profile.env"
HARNESS_PROFILE="auto"

if [ -f "$PROFILE_FILE" ]; then
  # shellcheck disable=SC1090
  source "$PROFILE_FILE"
fi

HARNESS_PROFILE="${HARNESS_PROFILE:-auto}"

APPLY=false
INSTALL=false

print_usage() {
  cat <<'USAGE'
Usage:
  ./scripts/codex/language-server.sh --check
  ./scripts/codex/language-server.sh --apply
  ./scripts/codex/language-server.sh --install
  ./scripts/codex/language-server.sh --apply --install

Options:
  --check    Check language server / linter / formatter availability.
  --apply    Create non-destructive editor/config files when missing.
  --install  Install missing language server dependencies/tools when possible.
  -h, --help Show this help.

Environment:
  HARNESS_PROFILE is read from docs/codex/harness-profile.env.

Notes:
  Existing files are not overwritten. Incoming files are written as *.harness-new.
USAGE
}

log() {
  printf '%s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

safe_write_file() {
  local target="$1"
  local content="$2"

  mkdir -p "$(dirname "$target")"

  if [ -f "$target" ]; then
    local tmp
    tmp="$(mktemp)"
    printf "%s" "$content" > "$tmp"

    if cmp -s "$tmp" "$target"; then
      log "Unchanged: $target"
      rm -f "$tmp"
      return 0
    fi

    cp "$tmp" "${target}.harness-new"
    rm -f "$tmp"
    warn "Existing file kept: $target"
    warn "Incoming file written to: ${target}.harness-new"
    return 0
  fi

  printf "%s" "$content" > "$target"
  log "Created: $target"
}

detect_node_runner() {
  if [ -f "pnpm-lock.yaml" ] || [ -f "pnpm-workspace.yaml" ]; then
    if has_cmd pnpm; then
      echo "pnpm"
      return 0
    fi
  fi

  if [ -f "yarn.lock" ]; then
    if has_cmd yarn; then
      echo "yarn"
      return 0
    fi
  fi

  if [ -f "package-lock.json" ] || [ -f "package.json" ]; then
    if has_cmd npm; then
      echo "npm"
      return 0
    fi
  fi

  echo ""
}

node_bin_exists() {
  local bin="$1"
  [ -x "node_modules/.bin/$bin" ] || [ -f "node_modules/.bin/$bin" ]
}

node_package_has_dev_dep() {
  local package_name="$1"

  [ -f "package.json" ] || return 1

  node -e "
    const p=require('./package.json');
    const deps={...(p.dependencies||{}), ...(p.devDependencies||{})};
    process.exit(deps['${package_name}'] ? 0 : 1);
  " >/dev/null 2>&1
}

install_node_dev_deps() {
  local runner="$1"
  shift
  local deps=("$@")

  if [ "${#deps[@]}" -eq 0 ]; then
    return 0
  fi

  log "Installing Node dev dependencies: ${deps[*]}"

  case "$runner" in
    pnpm)
      if [ -f "pnpm-workspace.yaml" ]; then
        pnpm add -Dw "${deps[@]}"
      else
        pnpm add -D "${deps[@]}"
      fi
      ;;
    npm)
      npm install -D "${deps[@]}"
      ;;
    yarn)
      yarn add -D "${deps[@]}"
      ;;
    *)
      warn "Unsupported Node runner: $runner"
      return 1
      ;;
  esac
}

check_typescript_language_server() {
  log ""
  log "== TypeScript language tooling =="

  local runner
  runner="$(detect_node_runner)"

  if [ -z "$runner" ]; then
    warn "No Node package manager detected."
    return 0
  fi

  log "Detected Node runner: $runner"

  if node_bin_exists tsc; then
    log "OK: local tsc found"
  else
    warn "local tsc not found"
  fi

  if node_bin_exists eslint; then
    log "OK: local eslint found"
  else
    warn "local eslint not found"
  fi

  if node_bin_exists typescript-language-server; then
    log "OK: local typescript-language-server found"
  else
    warn "local typescript-language-server not found"
  fi

  if node_bin_exists prettier; then
    log "OK: local prettier found"
  else
    warn "local prettier not found"
  fi

  if [ "$INSTALL" = true ]; then
    local missing=()

    node_package_has_dev_dep typescript || missing+=("typescript")
    node_package_has_dev_dep typescript-language-server || missing+=("typescript-language-server")
    node_package_has_dev_dep prettier || missing+=("prettier")

    # eslint may already exist in many projects. Install only if neither package nor binary exists.
    if ! node_package_has_dev_dep eslint && ! node_bin_exists eslint; then
      missing+=("eslint")
    fi

    install_node_dev_deps "$runner" "${missing[@]}"
  fi
}

apply_typescript_language_server_config() {
  [ "$APPLY" = true ] || return 0

  safe_write_file ".editorconfig" 'root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2
'

  safe_write_file ".vscode/settings.json" '{
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.preferences.importModuleSpecifier": "non-relative",
  "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "files.exclude": {
    "**/dist": true,
    "**/node_modules": true,
    "**/*.tsbuildinfo": true
  }
}
'
}

poetry_has_package() {
  local module="$1"

  # Avoid creating an empty Poetry environment during --check.
  [ -d ".venv" ] || return 1
  poetry run python -c "import ${module}" >/dev/null 2>&1
}

uv_has_package() {
  local module="$1"

  # Avoid syncing/creating .venv during --check.
  [ -d ".venv" ] || return 1
  uv run --no-sync python -c "import ${module}" >/dev/null 2>&1
}

check_python_poetry_language_server() {
  log ""
  log "== Python Poetry language tooling =="

  if ! has_cmd poetry; then
    warn "poetry command not found"
    return 0
  fi

  if poetry_has_package ruff; then
    log "OK: ruff available in Poetry environment"
  else
    warn "ruff not available in Poetry environment"
  fi

  if poetry_has_package pyright; then
    log "OK: pyright available in Poetry environment"
  else
    warn "pyright not available in Poetry environment"
  fi

  if poetry_has_package mypy; then
    log "OK: mypy available in Poetry environment"
  else
    warn "mypy not available in Poetry environment"
  fi

  if [ "$INSTALL" = true ]; then
    local deps=()

    poetry_has_package ruff || deps+=("ruff")
    poetry_has_package pyright || deps+=("pyright")
    poetry_has_package mypy || deps+=("mypy")

    if [ "${#deps[@]}" -gt 0 ]; then
      log "Installing Poetry dev dependencies: ${deps[*]}"
      poetry add --group dev "${deps[@]}"
    fi
  fi
}

check_python_uv_language_server() {
  log ""
  log "== Python uv language tooling =="

  if ! has_cmd uv; then
    warn "uv command not found"
    return 0
  fi

  if uv_has_package ruff; then
    log "OK: ruff available in uv environment"
  else
    warn "ruff not available in uv environment"
  fi

  if uv_has_package pyright; then
    log "OK: pyright available in uv environment"
  else
    warn "pyright not available in uv environment"
  fi

  if uv_has_package mypy; then
    log "OK: mypy available in uv environment"
  else
    warn "mypy not available in uv environment"
  fi

  if [ "$INSTALL" = true ]; then
    local deps=()

    uv_has_package ruff || deps+=("ruff")
    uv_has_package pyright || deps+=("pyright")
    uv_has_package mypy || deps+=("mypy")

    if [ "${#deps[@]}" -gt 0 ]; then
      log "Installing uv dev dependencies: ${deps[*]}"
      uv add --dev "${deps[@]}"
    fi
  fi
}

apply_python_language_server_config() {
  [ "$APPLY" = true ] || return 0

  safe_write_file ".editorconfig" 'root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.{yml,yaml,json,toml,md}]
indent_size = 2
'

  safe_write_file "pyrightconfig.json" '{
  "venvPath": ".",
  "venv": ".venv",
  "include": [
    "apps",
    "libs",
    "src",
    "tests"
  ],
  "exclude": [
    ".venv",
    "**/__pycache__",
    "**/.pytest_cache",
    "**/.mypy_cache",
    "**/.ruff_cache"
  ],
  "typeCheckingMode": "basic"
}
'

  safe_write_file ".vscode/settings.json" '{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.analysis.typeCheckingMode": "basic",
  "python.analysis.extraPaths": [
    "${workspaceFolder}/apps/api/src",
    "${workspaceFolder}/libs/common/src"
  ],
  "ruff.enable": true,
  "ruff.organizeImports": true,
  "editor.formatOnSave": true,
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "files.exclude": {
    "**/__pycache__": true,
    "**/.pytest_cache": true,
    "**/.mypy_cache": true,
    "**/.ruff_cache": true
  }
}
'
}

install_with_brew_if_possible() {
  local package_name="$1"

  if ! has_cmd brew; then
    warn "Homebrew not found. Cannot best-effort install $package_name."
    return 1
  fi

  log "Installing with Homebrew: $package_name"
  brew install "$package_name"
}

check_java_language_server() {
  log ""
  log "== JVM Java language tooling =="

  if has_cmd jdtls; then
    log "OK: jdtls found: $(command -v jdtls)"
  else
    warn "jdtls not found"
    if [ "$INSTALL" = true ]; then
      install_with_brew_if_possible jdtls || true
    fi
  fi
}

check_kotlin_language_server() {
  log ""
  log "== JVM Kotlin language tooling =="

  if has_cmd kotlin-language-server; then
    log "OK: kotlin-language-server found: $(command -v kotlin-language-server)"
  else
    warn "kotlin-language-server not found"
    if [ "$INSTALL" = true ]; then
      install_with_brew_if_possible kotlin-language-server || true
    fi
  fi

  if has_cmd ktlint; then
    log "OK: ktlint found: $(command -v ktlint)"
  else
    warn "ktlint not found"
    if [ "$INSTALL" = true ]; then
      install_with_brew_if_possible ktlint || true
    fi
  fi
}

apply_jvm_language_server_config() {
  [ "$APPLY" = true ] || return 0

  safe_write_file ".editorconfig" 'root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.{yml,yaml,json,md}]
indent_size = 2

[*.kt]
ij_kotlin_code_style_defaults = KOTLIN_OFFICIAL
'

  safe_write_file ".vscode/settings.json" '{
  "java.configuration.updateBuildConfiguration": "interactive",
  "java.compile.nullAnalysis.mode": "automatic",
  "files.exclude": {
    "**/build": true,
    "**/target": true,
    "**/.gradle": true
  }
}
'
}

run_profile() {
  case "$HARNESS_PROFILE" in
    typescript)
      check_typescript_language_server
      apply_typescript_language_server_config
      ;;
    python-poetry)
      check_python_poetry_language_server
      apply_python_language_server_config
      ;;
    python-uv)
      check_python_uv_language_server
      apply_python_language_server_config
      ;;
    jvm-gradle-java|jvm-maven-java)
      check_java_language_server
      apply_jvm_language_server_config
      ;;
    jvm-gradle-kotlin|jvm-maven-kotlin)
      check_kotlin_language_server
      apply_jvm_language_server_config
      ;;
    mixed|auto|"")
      if [ -f "package.json" ]; then
        check_typescript_language_server
        apply_typescript_language_server_config
      fi
      if [ -f "pyproject.toml" ]; then
        if grep -q "tool.poetry" pyproject.toml 2>/dev/null; then
          check_python_poetry_language_server
        else
          check_python_uv_language_server
        fi
        apply_python_language_server_config
      fi
      if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] || [ -f "settings.gradle" ] || [ -f "settings.gradle.kts" ] || [ -f "pom.xml" ]; then
        check_java_language_server
        apply_jvm_language_server_config
      fi
      ;;
    docs-only)
      log "Docs-only profile: no language server setup."
      ;;
    *)
      warn "Unknown HARNESS_PROFILE '$HARNESS_PROFILE'. No language server setup applied."
      ;;
  esac
}

if [ "$#" -eq 0 ]; then
  print_usage
  exit 0
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      APPLY=false
      INSTALL=false
      shift
      ;;
    --apply)
      APPLY=true
      shift
      ;;
    --install)
      INSTALL=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      print_usage
      exit 1
      ;;
  esac
done

log "Language server setup"
log "Profile: $HARNESS_PROFILE"
log "Apply config: $APPLY"
log "Install missing tools/deps: $INSTALL"

run_profile

log ""
log "Language server setup completed."
