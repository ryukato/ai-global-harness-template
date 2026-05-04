#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

APPLY=false
WITH_GRAPHIFY=false
REBUILD_GRAPH=false
GRAPHIFY_PLATFORM="codex"
WITH_LANGUAGE_SERVER=false
INSTALL_LANGUAGE_SERVER=false

PROFILE_FILE="docs/codex/harness-profile.env"
HARNESS_PROFILE="auto"

if [ -f "$PROFILE_FILE" ]; then
  # shellcheck disable=SC1090
  source "$PROFILE_FILE"
fi

HARNESS_PROFILE="${HARNESS_PROFILE:-auto}"

print_usage() {
  cat <<'USAGE'
Usage:
  ./scripts/codex/bootstrap.sh --check
  ./scripts/codex/bootstrap.sh --apply
  ./scripts/codex/bootstrap.sh --apply --graphify
  ./scripts/codex/bootstrap.sh --apply --graphify --graphify-platform codex
  ./scripts/codex/bootstrap.sh --apply --graphify --rebuild-graph
  ./scripts/codex/bootstrap.sh --apply --language-server
  ./scripts/codex/bootstrap.sh --apply --language-server --install-language-server

Options:
  --check                     Inspect the local environment only.
  --apply                     Apply safe local bootstrap steps.
  --graphify                  Install/apply Graphify integration when possible.
  --graphify-platform <name>  Target Graphify platform. Default: codex.
                              Examples: codex, opencode, aider, copilot, claw, droid, trae.
                              Use "default" for Graphify's default platform install.
  --rebuild-graph             Attempt graph rebuild when the local Graphify CLI supports it.
  --language-server           Check/apply profile-specific language server configuration.
  --install-language-server   Install missing language server dependencies/tools when possible.
  -h, --help                  Show this help.
USAGE
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
}

check_cmd_required() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd found: $(command -v "$cmd")"
    return 0
  fi

  warn "$cmd is required for profile '$HARNESS_PROFILE' but is not installed or not on PATH."
  return 1
}

check_cmd_optional() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd found: $(command -v "$cmd")"
    return 0
  fi

  warn "$cmd is optional and not installed or not on PATH."
  return 1
}

check_node_package_manager() {
  if [ -f "pnpm-lock.yaml" ] || [ -f "pnpm-workspace.yaml" ]; then
    check_cmd_required pnpm
  elif [ -f "package-lock.json" ]; then
    check_cmd_required npm
  elif [ -f "yarn.lock" ]; then
    check_cmd_required yarn
  elif [ -f "package.json" ]; then
    if command -v pnpm >/dev/null 2>&1; then
      echo "OK: pnpm found: $(command -v pnpm)"
    elif command -v npm >/dev/null 2>&1; then
      echo "OK: npm found: $(command -v npm)"
    else
      warn "No supported Node package manager found. Expected pnpm or npm."
      return 1
    fi
  else
    warn "No package.json found, but profile is '$HARNESS_PROFILE'."
  fi
}

check_gradle() {
  check_cmd_required java || true

  if [ -f "gradlew" ]; then
    echo "OK: Gradle wrapper found: ./gradlew"
  else
    check_cmd_required gradle || true
  fi
}

check_maven() {
  check_cmd_required java || true

  if [ -f "mvnw" ]; then
    echo "OK: Maven wrapper found: ./mvnw"
  else
    check_cmd_required mvn || true
  fi
}

check_python_base() {
  if command -v python3 >/dev/null 2>&1; then
    echo "OK: python3 found: $(command -v python3)"
  elif command -v python >/dev/null 2>&1; then
    echo "OK: python found: $(command -v python)"
  else
    warn "python3 or python is required for profile '$HARNESS_PROFILE' but not found."
    return 1
  fi
}

check_auto_detected_environment() {
  echo "Profile: auto"
  echo "Auto-detecting required tools from repository files"

  check_cmd_required git || true

  if [ -f "package.json" ] || [ -f "pnpm-workspace.yaml" ]; then
    echo
    echo "Detected Node/TypeScript project"
    check_cmd_required node || true
    check_node_package_manager || true
  fi

  if [ -f "pyproject.toml" ]; then
    echo
    echo "Detected Python project"
    check_python_base || true

    if grep -q "tool.poetry" pyproject.toml 2>/dev/null; then
      check_cmd_required poetry || true
    fi

    if [ -f "uv.lock" ]; then
      check_cmd_required uv || true
    fi
  fi

  if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] || [ -f "settings.gradle" ] || [ -f "settings.gradle.kts" ] || [ -f "gradlew" ]; then
    echo
    echo "Detected Gradle project"
    check_gradle
  fi

  if [ -f "pom.xml" ] || [ -f "mvnw" ]; then
    echo
    echo "Detected Maven project"
    check_maven
  fi
}

check_profile_environment() {
  echo "Checking environment"
  echo "Profile: $HARNESS_PROFILE"

  check_cmd_required git || true

  case "$HARNESS_PROFILE" in
    typescript)
      check_cmd_required node || true
      check_node_package_manager || true
      ;;
    python-poetry)
      check_python_base || true
      check_cmd_required poetry || true
      ;;
    python-uv)
      check_python_base || true
      check_cmd_required uv || true
      ;;
    jvm-gradle-java|jvm-gradle-kotlin)
      check_gradle
      ;;
    jvm-maven-java|jvm-maven-kotlin)
      check_maven
      ;;
    mixed)
      check_auto_detected_environment
      ;;
    docs-only)
      echo "Docs-only profile: git is the only required tool."
      ;;
    auto|"")
      check_auto_detected_environment
      ;;
    *)
      warn "Unknown HARNESS_PROFILE '$HARNESS_PROFILE'. Falling back to auto detection."
      check_auto_detected_environment
      ;;
  esac

  if [ "$WITH_GRAPHIFY" = true ]; then
    echo
    echo "Checking optional Graphify environment"
    if command -v graphify >/dev/null 2>&1; then
      echo "OK: graphify found: $(command -v graphify)"
    else
      warn "graphify is not installed or not on PATH."
    fi
  fi
}

apply_basic_setup() {
  echo
  echo "Applying basic harness setup"
  mkdir -p docs/codex scripts/codex .codex-runs
  chmod +x scripts/codex/*.sh 2>/dev/null || true
  echo "OK: ensured docs/codex, scripts/codex, and .codex-runs"
}

run_graphify() {
  if command -v graphify >/dev/null 2>&1; then
    graphify "$@"
    return $?
  fi

  if command -v python3 >/dev/null 2>&1 && python3 -m graphify --help >/dev/null 2>&1; then
    python3 -m graphify "$@"
    return $?
  fi

  if command -v python >/dev/null 2>&1 && python -m graphify --help >/dev/null 2>&1; then
    python -m graphify "$@"
    return $?
  fi

  return 127
}

install_graphify_if_missing() {
  if command -v graphify >/dev/null 2>&1; then
    echo "OK: graphify is already available: $(command -v graphify)"
    return 0
  fi

  if run_graphify --help >/dev/null 2>&1; then
    echo "OK: graphify is available through python -m graphify"
    return 0
  fi

  if [ "$APPLY" != true ]; then
    warn "graphify is not installed. Re-run with --apply --graphify to attempt installation."
    return 1
  fi

  echo
  echo "Installing Graphify CLI package: graphifyy"

  if command -v uv >/dev/null 2>&1; then
    if uv tool install graphifyy; then
      echo "OK: installed graphifyy via uv tool"
    else
      warn "uv tool install graphifyy failed"
    fi
  elif command -v pipx >/dev/null 2>&1; then
    if pipx install graphifyy; then
      echo "OK: installed graphifyy via pipx"
    else
      warn "pipx install graphifyy failed"
    fi
  elif command -v python3 >/dev/null 2>&1; then
    if python3 -m pip install --user graphifyy; then
      echo "OK: installed graphifyy via python3 -m pip --user"
    else
      warn "python3 -m pip install --user graphifyy failed"
    fi
  elif command -v python >/dev/null 2>&1; then
    if python -m pip install --user graphifyy; then
      echo "OK: installed graphifyy via python -m pip --user"
    else
      warn "python -m pip install --user graphifyy failed"
    fi
  else
    warn "Python 3.10+ is required to install Graphify."
    return 1
  fi

  if command -v graphify >/dev/null 2>&1; then
    echo "OK: graphify installed: $(command -v graphify)"
    return 0
  fi

  if run_graphify --help >/dev/null 2>&1; then
    echo "OK: graphify is available through python -m graphify"
    return 0
  fi

  warn "graphify command is still not available after installation."
  warn "If installed with plain pip on macOS, add the user scripts directory to PATH."
  return 1
}

apply_graphify_integration() {
  echo
  echo "Applying Graphify integration"
  echo "Platform: $GRAPHIFY_PLATFORM"

  if ! run_graphify --help >/dev/null 2>&1; then
    warn "Skipping Graphify integration because graphify is unavailable."
    return 1
  fi

  if [ "$GRAPHIFY_PLATFORM" = "default" ]; then
    if run_graphify install; then
      echo "OK: graphify install"
      return 0
    fi
  else
    if run_graphify install --platform "$GRAPHIFY_PLATFORM"; then
      echo "OK: graphify install --platform $GRAPHIFY_PLATFORM"
      return 0
    fi

    warn "Platform-specific install failed. Trying default Graphify install as fallback..."
    if run_graphify install; then
      echo "OK: graphify install"
      return 0
    fi
  fi

  warn "Graphify integration failed. Check local CLI help:"
  warn "  graphify --help"
  warn "  graphify install --help"
  return 1
}

attempt_graph_rebuild() {
  if [ "$REBUILD_GRAPH" != true ]; then
    return 0
  fi

  echo
  echo "Attempting Graphify graph rebuild"

  if ! run_graphify --help >/dev/null 2>&1; then
    warn "Cannot rebuild graph because graphify is unavailable."
    return 1
  fi

  mkdir -p graphify-out

  if run_graphify .; then
    echo "OK: graphify ."
    return 0
  fi

  if run_graphify build .; then
    echo "OK: graphify build ."
    return 0
  fi

  warn "Automatic graph rebuild was not supported by this local Graphify CLI."
  warn "After Graphify integration, run the assistant command in your coding agent:"
  warn "  /graphify ."
  return 1
}

report_graphify_status() {
  echo
  echo "Graphify status"

  if run_graphify --help >/dev/null 2>&1; then
    echo "OK: graphify is callable"
  else
    warn "graphify is not callable"
  fi

  if [ -f "graphify-out/GRAPH_REPORT.md" ]; then
    echo "OK: graph report found: graphify-out/GRAPH_REPORT.md"
  else
    warn "graphify-out/GRAPH_REPORT.md not found."
  fi

  if [ -f "graphify-out/graph.html" ]; then
    echo "OK: graph visualization found: graphify-out/graph.html"
  fi

  cat <<'NOTE'

Graphify notes:
- The PyPI package name is graphifyy.
- The CLI command is graphify.
- For Codex, the intended integration command is usually:
    graphify install --platform codex
- After platform integration, graph generation may be exposed as an assistant slash command:
    /graphify .

Codex user-level config note:
Some Graphify/Codex workflows may require this in ~/.codex/config.toml:

  [features]
  multi_agent = true

Do not commit user-level Codex configuration into this repository unless your team explicitly standardizes it.
NOTE
}

if [ "$#" -eq 0 ]; then
  print_usage
  exit 0
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      APPLY=false
      shift
      ;;
    --apply)
      APPLY=true
      shift
      ;;
    --graphify)
      WITH_GRAPHIFY=true
      shift
      ;;
    --graphify-platform)
      GRAPHIFY_PLATFORM="${2:-}"
      if [ -z "$GRAPHIFY_PLATFORM" ]; then
        echo "Missing value for --graphify-platform" >&2
        exit 1
      fi
      shift 2
      ;;
    --rebuild-graph)
      REBUILD_GRAPH=true
      shift
      ;;
    --language-server)
      WITH_LANGUAGE_SERVER=true
      shift
      ;;
    --install-language-server)
      WITH_LANGUAGE_SERVER=true
      INSTALL_LANGUAGE_SERVER=true
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

check_profile_environment

if [ "$APPLY" = true ]; then
  apply_basic_setup
fi

if [ "$WITH_GRAPHIFY" = true ]; then
  install_graphify_if_missing || true

  if [ "$APPLY" = true ]; then
    apply_graphify_integration || true
    attempt_graph_rebuild || true
  else
    warn "--graphify was provided without --apply, so integration was not applied."
  fi

  report_graphify_status
fi

if [ "$WITH_LANGUAGE_SERVER" = true ]; then
  echo
  echo "Language server setup requested"

  if [ -x "./scripts/codex/language-server.sh" ]; then
    if [ "$APPLY" = true ] && [ "$INSTALL_LANGUAGE_SERVER" = true ]; then
      ./scripts/codex/language-server.sh --apply --install
    elif [ "$APPLY" = true ]; then
      ./scripts/codex/language-server.sh --apply
    else
      ./scripts/codex/language-server.sh --check
    fi
  else
    warn "scripts/codex/language-server.sh not found or not executable."
  fi
fi

echo
echo "Bootstrap completed."
