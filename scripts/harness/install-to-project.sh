#!/usr/bin/env bash
set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TARGET_DIR=""
PROFILE=""
INIT_SCAFFOLD=false
FORCE_INIT=false
DRY_RUN=false
INSTALL_MODE="safe"
BACKUP_DIR=""
AGENT_TARGETS="codex"
MIXED_FRONTEND_LANG="typescript"
MIXED_BACKEND_LANG="typescript"

print_usage() {
  cat <<'USAGE'
Usage:
  ./scripts/harness/install-to-project.sh /path/to/target-project --profile <profile> [options]

Profiles:
  typescript
  python-poetry
  python-uv
  jvm-gradle-java
  jvm-gradle-kotlin
  jvm-maven-java
  jvm-maven-kotlin
  mixed
  docs-only

Options:
  --init-scaffold       Create profile-specific minimal project files before installing the harness.
                        Supported for: typescript, python-poetry, python-uv,
                        mixed, jvm-gradle-java, jvm-gradle-kotlin,
                        jvm-maven-java, jvm-maven-kotlin.
                        Use this for empty or throwaway projects, not normal existing repos.

  --force-init          Allow init scaffold to overwrite existing scaffold files.

  --frontend-lang <lang>
                        Frontend language for --profile mixed --init-scaffold.
                        Supported: typescript. Default: typescript.

  --backend-lang <lang>
                        Backend language for --profile mixed --init-scaffold.
                        Supported: typescript. Default: typescript.

  --mode <mode>         How to handle existing harness target files.
                        safe       Default. Do not overwrite existing files. Write incoming files as *.harness-new.
                        backup     Backup existing files to .ai-harness-backups/<timestamp>/, then overwrite.
                        overwrite  Overwrite existing files directly.

  --agent <agent>       Agent entrypoint to install.
                        codex       Default. Install AGENTS.md plus Codex docs/scripts.
                        claude-code Install CLAUDE.md plus the Claude Code production harness.
                        both        Install both Codex and Claude Code harnesses.

  --dry-run             Print what would happen without writing files.

  -h, --help            Show this help.

Examples:
  # Existing TypeScript project: safe install, no scaffold
  ./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript

  # Existing project with backups, then overwrite harness files
  ./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --mode backup

  # Empty TypeScript test project: create scaffold + harness
  ./scripts/harness/install-to-project.sh /tmp/dummy-ts --profile typescript --init-scaffold

  # Empty mixed monorepo: create frontend/backend/libs + harness
  ./scripts/harness/install-to-project.sh /tmp/dummy-mixed --profile mixed --init-scaffold --frontend-lang typescript --backend-lang typescript

  # Install both Codex and Claude Code entrypoints
  ./scripts/harness/install-to-project.sh /path/to/project --profile typescript --agent both

  # Preview
  ./scripts/harness/install-to-project.sh /path/to/project --profile typescript --dry-run
USAGE
}

log() {
  printf '%s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
}

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

ensure_backup_dir() {
  if [ -z "$BACKUP_DIR" ]; then
    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    BACKUP_DIR="$TARGET_DIR/.ai-harness-backups/$stamp"
  fi
}

backup_existing_file() {
  local dst="$1"
  ensure_backup_dir

  local rel="${dst#$TARGET_DIR/}"
  local backup="$BACKUP_DIR/$rel"

  if [ "$DRY_RUN" = true ]; then
    log "DRY-RUN backup: $dst -> $backup"
    return 0
  fi

  mkdir -p "$(dirname "$backup")"
  cp "$dst" "$backup"
  log "Backed up: $dst -> $backup"
}

write_file_from_source() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ "$DRY_RUN" = true ]; then
    if [ -f "$dst" ]; then
      case "$INSTALL_MODE" in
        safe)
          log "DRY-RUN conflict: would write incoming file to ${dst}.harness-new"
          ;;
        backup)
          log "DRY-RUN conflict: would backup then overwrite $dst"
          ;;
        overwrite)
          log "DRY-RUN conflict: would overwrite $dst"
          ;;
      esac
    else
      log "DRY-RUN create: $dst"
    fi
    return 0
  fi

  if [ -f "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      log "Unchanged: $dst"
      return 0
    fi

    case "$INSTALL_MODE" in
      safe)
        cp "$src" "${dst}.harness-new"
        warn "Existing file kept: $dst"
        warn "Incoming file written to: ${dst}.harness-new"
        return 0
        ;;
      backup)
        backup_existing_file "$dst"
        cp "$src" "$dst"
        log "Overwritten with backup: $dst"
        return 0
        ;;
      overwrite)
        cp "$src" "$dst"
        log "Overwritten: $dst"
        return 0
        ;;
      *)
        fail "Unknown install mode: $INSTALL_MODE"
        ;;
    esac
  fi

  cp "$src" "$dst"
  log "Created: $dst"
}

write_generated_file() {
  local dst="$1"
  local content="$2"
  local tmp
  tmp="$(mktemp)"
  printf "%s" "$content" > "$tmp"
  write_file_from_source "$tmp" "$dst"
  rm -f "$tmp"
}

copy_template() {
  local rel="$1"
  local dst_rel="$2"
  write_file_from_source "$HARNESS_ROOT/$rel" "$TARGET_DIR/$dst_rel"
}

agent_namespace() {
  case "$1" in
    codex)
      echo "codex"
      ;;
    claude-code)
      echo "claude"
      ;;
    *)
      fail "Unknown agent target: $1"
      ;;
  esac
}

render_for_namespace() {
  local src="$1"
  local dst="$2"
  local namespace="$3"

  sed \
    -e "s#docs/codex#docs/$namespace#g" \
    -e "s#scripts/codex#scripts/$namespace#g" \
    -e "s#\\.codex-runs#.$namespace-runs#g" \
    "$src" > "$dst"
}

write_rendered_file_from_source() {
  local src="$1"
  local dst="$2"
  local namespace="$3"
  local tmp
  tmp="$(mktemp)"
  render_for_namespace "$src" "$tmp" "$namespace"
  write_file_from_source "$tmp" "$dst"
  rm -f "$tmp"
}

copy_template_for_namespace() {
  local rel="$1"
  local dst_rel="$2"
  local namespace="$3"

  write_rendered_file_from_source "$HARNESS_ROOT/$rel" "$TARGET_DIR/$dst_rel" "$namespace"
}

detect_project_name() {
  if [ -f "$TARGET_DIR/package.json" ] && command -v node >/dev/null 2>&1; then
    local package_name
    package_name="$(cd "$TARGET_DIR" && node -e "try { const p = require('./package.json'); process.stdout.write(p.name || ''); } catch (_) {}" 2>/dev/null || true)"
    if [ -n "$package_name" ]; then
      echo "$package_name"
      return 0
    fi
  fi

  if [ -f "$TARGET_DIR/README.md" ]; then
    local heading
    heading="$(sed -n 's/^# \{1,\}//p' "$TARGET_DIR/README.md" | head -n 1)"
    if [ -n "$heading" ]; then
      echo "$heading"
      return 0
    fi
  fi

  basename "$TARGET_DIR"
}

detect_package_manager() {
  if [ -f "$TARGET_DIR/package.json" ] && command -v node >/dev/null 2>&1; then
    local declared_pm
    declared_pm="$(cd "$TARGET_DIR" && node -e "try { const p = require('./package.json'); process.stdout.write(p.packageManager || ''); } catch (_) {}" 2>/dev/null || true)"
    if [ -n "$declared_pm" ]; then
      echo "$declared_pm"
      return 0
    fi
  fi

  if [ -f "$TARGET_DIR/pnpm-lock.yaml" ] || [ -f "$TARGET_DIR/pnpm-workspace.yaml" ]; then
    echo "pnpm (detected from pnpm lock/workspace file)"
  elif [ -f "$TARGET_DIR/yarn.lock" ]; then
    echo "yarn (detected from yarn.lock)"
  elif [ -f "$TARGET_DIR/package-lock.json" ]; then
    echo "npm (detected from package-lock.json)"
  elif [ -f "$TARGET_DIR/package.json" ]; then
    echo "npm (fallback for package.json without lockfile)"
  elif [ -f "$TARGET_DIR/poetry.lock" ]; then
    echo "poetry (detected from poetry.lock)"
  elif [ -f "$TARGET_DIR/uv.lock" ]; then
    echo "uv (detected from uv.lock)"
  else
    echo "TODO: record package manager or state that this project has none."
  fi
}

detect_repository_structure() {
  local found=false
  local dir

  for dir in apps services packages libs src docs scripts templates work-items .claude .github; do
    if [ -d "$TARGET_DIR/$dir" ]; then
      found=true
      printf '%s/\n' "$dir"
    fi
  done

  if [ "$found" = false ]; then
    echo "TODO: Add the important directories. For existing repositories, prefer observed root directories over desired future structure."
  fi
}

detect_setup_commands() {
  if [ -f "$TARGET_DIR/package.json" ]; then
    local pm
    pm="$(detect_package_manager)"
    case "$pm" in
      pnpm@*)
        echo "corepack $pm install"
        return 0
        ;;
      pnpm*)
        echo "corepack pnpm install"
        return 0
        ;;
      yarn@*)
        echo "corepack $pm install"
        return 0
        ;;
      yarn*)
        echo "corepack yarn install"
        return 0
        ;;
      npm*|npm@*)
        if [ -f "$TARGET_DIR/package-lock.json" ]; then
          echo "npm ci"
        else
          echo "npm install"
        fi
        return 0
        ;;
    esac
  fi

  if [ -f "$TARGET_DIR/pyproject.toml" ] && [ -f "$TARGET_DIR/poetry.lock" ]; then
    echo "poetry install"
  elif [ -f "$TARGET_DIR/pyproject.toml" ] && [ -f "$TARGET_DIR/uv.lock" ]; then
    echo "uv sync"
  else
    echo "TODO"
  fi
}

detect_test_commands() {
  if [ -f "$TARGET_DIR/package.json" ] && command -v node >/dev/null 2>&1; then
    local run_prefix
    local pm
    pm="$(detect_package_manager)"
    case "$pm" in
      pnpm@*)
        run_prefix="corepack $pm run"
        ;;
      pnpm*)
        run_prefix="corepack pnpm run"
        ;;
      yarn@*)
        run_prefix="corepack $pm run"
        ;;
      yarn*)
        run_prefix="corepack yarn run"
        ;;
      *)
        run_prefix="npm run"
        ;;
    esac

    local scripts
    scripts="$(cd "$TARGET_DIR" && node -e "
      try {
        const p = require('./package.json');
        const prefix = process.argv[1];
        const names = Object.keys(p.scripts || {});
        const preferred = names.filter((name) => ['lint', 'typecheck', 'test', 'build'].includes(name));
        process.stdout.write(preferred.map((name) => prefix + ' ' + name).join('\n'));
      } catch (_) {}
    " "$run_prefix" 2>/dev/null || true)"
    if [ -n "$scripts" ]; then
      echo "$scripts"
      return 0
    fi
  fi

  echo "TODO"
}

escape_newlines() {
  awk '
    {
      gsub(/\\/, "\\\\")
      printf "%s%s", separator, $0
      separator = "\\n"
    }
  '
}

copy_project_context_for_namespace() {
  local rel="$1"
  local dst_rel="$2"
  local namespace="$3"
  local rendered
  local tmp
  local repository_structure
  local setup_commands
  local test_commands

  rendered="$(mktemp)"
  tmp="$(mktemp)"
  render_for_namespace "$HARNESS_ROOT/$rel" "$rendered" "$namespace"
  repository_structure="$(detect_repository_structure | escape_newlines)"
  setup_commands="$(detect_setup_commands | escape_newlines)"
  test_commands="$(detect_test_commands | escape_newlines)"

  awk \
    -v project_name="$(detect_project_name)" \
    -v selected_profile="$PROFILE" \
    -v repository_structure="$repository_structure" \
    -v package_manager="$(detect_package_manager)" \
    -v setup_commands="$setup_commands" \
    -v test_commands="$test_commands" '
      BEGIN {
        gsub(/\\n/, "\n", repository_structure)
        gsub(/\\n/, "\n", setup_commands)
        gsub(/\\n/, "\n", test_commands)
      }
      $0 == "{{PROJECT_NAME}}" { print project_name; next }
      $0 == "{{SELECTED_HARNESS_PROFILE}}" { print selected_profile; next }
      $0 == "{{REPOSITORY_STRUCTURE}}" { print repository_structure; next }
      $0 == "{{PACKAGE_MANAGER}}" { print package_manager; next }
      $0 == "{{SETUP_COMMANDS}}" { print setup_commands; next }
      $0 == "{{TEST_COMMANDS}}" { print test_commands; next }
      { print }
    ' "$rendered" > "$tmp"

  write_file_from_source "$tmp" "$TARGET_DIR/$dst_rel"
  rm -f "$rendered" "$tmp"
}

copy_template_tree() {
  local rel="$1"
  local dst_rel="$2"
  local src_root="$HARNESS_ROOT/$rel"

  [ -d "$src_root" ] || fail "Template directory not found: $rel"

  while IFS= read -r -d '' src; do
    local file_rel="${src#$src_root/}"
    write_file_from_source "$src" "$TARGET_DIR/$dst_rel/$file_rel"
  done < <(find "$src_root" -type f -print0 | sort -z)
}

install_claude_code_production_harness() {
  local template_root="templates/claude-code-production"

  if ! agent_target_enabled codex; then
    copy_template "$template_root/AGENTS.md" "AGENTS.md"
  fi

  copy_template "$template_root/.gitignore" ".gitignore"
  copy_template_tree "$template_root/.ai-workspace" ".ai-workspace"
  copy_template_tree "$template_root/.claude" ".claude"
  copy_template_tree "$template_root/scripts/claude" "scripts/claude"
  copy_template_tree "$template_root/docs/architecture" "docs/architecture"
  copy_template_tree "$template_root/docs/decisions" "docs/decisions"
  copy_template_tree "$template_root/docs/domain" "docs/domain"
  copy_template_tree "$template_root/docs/operations" "docs/operations"
  write_generated_file "$TARGET_DIR/docs/operations/harness-profile.env" "HARNESS_PROFILE=$PROFILE
"
  copy_template_tree "$template_root/templates/jira" "templates/jira"
  copy_template_tree "$template_root/templates/work-items" "templates/work-items"
  copy_template_tree "$template_root/work-items" "work-items"

  copy_template "$template_root/HARNESS-GUIDE.md" "HARNESS-GUIDE.md"

  if [ -d "$HARNESS_ROOT/$template_root/.github" ]; then
    copy_template_tree "$template_root/.github" ".github"
  fi

  if [ "$DRY_RUN" != true ]; then
    chmod +x "$TARGET_DIR"/scripts/claude/*.sh 2>/dev/null || true
  fi
}

agent_target_enabled() {
  local wanted="$1"

  case "$AGENT_TARGETS" in
    both)
      return 0
      ;;
    "$wanted")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

install_agent_entrypoint() {
  local target_rel="$1"
  local base_rel="$2"
  local display_name="$3"
  local namespace="$4"
  local profile_file="$PROFILE_DIR/AGENTS.append.md"
  local target_file="$TARGET_DIR/$target_rel"
  local marker="Profile-specific rules appended by ai-global-harness: $PROFILE"

  [ -f "$HARNESS_ROOT/$base_rel" ] || fail "Agent template not found: $base_rel"

  local tmp
  tmp="$(mktemp)"

  if [ -f "$target_file" ]; then
    if grep -q "$marker" "$target_file"; then
      log "$display_name already contains profile rules for $PROFILE"
      rm -f "$tmp"
      return 0
    fi

    if [ "$DRY_RUN" = true ]; then
      case "$INSTALL_MODE" in
        safe)
          log "DRY-RUN conflict: existing $display_name kept; incoming file would be ${target_file}.harness-new"
          ;;
        backup)
          log "DRY-RUN conflict: would backup then overwrite merged $display_name"
          ;;
        overwrite)
          log "DRY-RUN conflict: would overwrite $display_name with merged profile rules"
          ;;
      esac
      rm -f "$tmp"
      return 0
    fi

    case "$INSTALL_MODE" in
      safe)
        cat "$HARNESS_ROOT/$base_rel" > "$tmp"
        if [ -f "$profile_file" ]; then
          {
            echo
            echo "<!-- $marker -->"
            echo
            cat "$profile_file"
          } >> "$tmp"
        fi
        write_rendered_file_from_source "$tmp" "$target_file" "$namespace"
        ;;
      backup|overwrite)
        cat "$target_file" > "$tmp"
        if [ -f "$profile_file" ]; then
          {
            echo
            echo "<!-- $marker -->"
            echo
            cat "$profile_file"
          } >> "$tmp"
        fi
        write_rendered_file_from_source "$tmp" "$target_file" "$namespace"
        ;;
    esac
  else
    cat "$HARNESS_ROOT/$base_rel" > "$tmp"
    if [ -f "$profile_file" ]; then
      {
        echo
        echo "<!-- $marker -->"
        echo
        cat "$profile_file"
      } >> "$tmp"
    fi
    write_rendered_file_from_source "$tmp" "$target_file" "$namespace"
  fi

  rm -f "$tmp"
}

install_harness_namespace() {
  local namespace="$1"
  local docs_dir="docs/$namespace"
  local scripts_dir="scripts/$namespace"
  local runs_dir=".$namespace-runs"

  [ "$namespace" = "codex" ] || fail "Unsupported harness namespace: $namespace"

  copy_project_context_for_namespace "templates/docs/codex/project-context.md" "$docs_dir/project-context.md" "$namespace"
  if [ "$namespace" != "claude" ]; then
    copy_template_for_namespace "templates/docs/codex/code-review.md" "$docs_dir/code-review.md" "$namespace"
  fi
  copy_template_for_namespace "templates/docs/codex/done-definition.md" "$docs_dir/done-definition.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/task-template.short.md" "$docs_dir/task-template.short.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/task-template.medium.md" "$docs_dir/task-template.medium.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/run-log-format.md" "$docs_dir/run-log-format.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/general-scaffold-principles.md" "$docs_dir/general-scaffold-principles.md" "$namespace"
  if [ "$namespace" != "claude" ]; then
    copy_template_for_namespace "templates/docs/codex/legacy-project-guidance.md" "$docs_dir/legacy-project-guidance.md" "$namespace"
    copy_template_for_namespace "templates/docs/codex/atlassian-mcp.md" "$docs_dir/atlassian-mcp.md" "$namespace"
    copy_template_for_namespace "templates/docs/codex/local-mcp-setup.md" "$docs_dir/local-mcp-setup.md" "$namespace"
    copy_template_for_namespace "templates/docs/codex/local-api-key-setup.md" "$docs_dir/local-api-key-setup.md" "$namespace"
  fi
  copy_template_for_namespace "templates/docs/codex/monorepo-layout.md" "$docs_dir/monorepo-layout.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/backend-architecture-boundaries.md" "$docs_dir/backend-architecture-boundaries.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/frontend-structure.md" "$docs_dir/frontend-structure.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/proxy-bff-pattern.md" "$docs_dir/proxy-bff-pattern.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/shared-contracts.md" "$docs_dir/shared-contracts.md" "$namespace"
  if [ "$namespace" != "claude" ]; then
    copy_template_for_namespace "templates/docs/codex/graphify.md" "$docs_dir/graphify.md" "$namespace"
  fi
  copy_template_for_namespace "templates/docs/codex/harness-profile.md" "$docs_dir/harness-profile.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/existing-project-install.md" "$docs_dir/existing-project-install.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/typescript-scaffold-troubleshooting.md" "$docs_dir/typescript-scaffold-troubleshooting.md" "$namespace"
  if [ "$namespace" != "claude" ]; then
    copy_template_for_namespace "templates/docs/codex/dependency-fallback.md" "$docs_dir/dependency-fallback.md" "$namespace"
  fi
  copy_template_for_namespace "templates/docs/codex/jvm-profiles.md" "$docs_dir/jvm-profiles.md" "$namespace"
  copy_template_for_namespace "templates/docs/codex/language-server.md" "$docs_dir/language-server.md" "$namespace"

  write_generated_file "$TARGET_DIR/$docs_dir/harness-profile.env" "HARNESS_PROFILE=$PROFILE
"

  copy_template_for_namespace "templates/scripts/codex/bootstrap.sh" "$scripts_dir/bootstrap.sh" "$namespace"
  copy_template_for_namespace "templates/scripts/codex/verify.sh" "$scripts_dir/verify.sh" "$namespace"
  copy_template_for_namespace "templates/scripts/codex/changed-files.sh" "$scripts_dir/changed-files.sh" "$namespace"
  copy_template_for_namespace "templates/scripts/codex/summarize-diff.sh" "$scripts_dir/summarize-diff.sh" "$namespace"
  copy_template_for_namespace "templates/scripts/codex/start-run.sh" "$scripts_dir/start-run.sh" "$namespace"
  copy_template_for_namespace "templates/scripts/codex/collect-run-summary.sh" "$scripts_dir/collect-run-summary.sh" "$namespace"
  copy_template_for_namespace "templates/scripts/codex/weekly-report.sh" "$scripts_dir/weekly-report.sh" "$namespace"
  copy_template_for_namespace "templates/scripts/codex/language-server.sh" "$scripts_dir/language-server.sh" "$namespace"

  if [ "$DRY_RUN" != true ]; then
    chmod +x "$TARGET_DIR"/"$scripts_dir"/*.sh 2>/dev/null || true
    mkdir -p "$TARGET_DIR/$runs_dir"
    touch "$TARGET_DIR/$runs_dir/.gitkeep"
  fi
}

if [ "$#" -lt 1 ]; then
  print_usage
  exit 1
fi

TARGET_DIR="$1"
shift

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --init-scaffold)
      INIT_SCAFFOLD=true
      shift
      ;;
    --force-init)
      FORCE_INIT=true
      shift
      ;;
    --frontend-lang)
      MIXED_FRONTEND_LANG="${2:-}"
      shift 2
      ;;
    --backend-lang)
      MIXED_BACKEND_LANG="${2:-}"
      shift 2
      ;;
    --mode)
      INSTALL_MODE="${2:-}"
      shift 2
      ;;
    --agent|--agents)
      AGENT_TARGETS="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
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

[ -n "$PROFILE" ] || fail "Missing --profile"

case "$PROFILE" in
  typescript|python-poetry|python-uv|jvm-gradle-java|jvm-gradle-kotlin|jvm-maven-java|jvm-maven-kotlin|mixed|docs-only)
    ;;
  *)
    fail "Unknown profile: $PROFILE"
    ;;
esac

case "$INSTALL_MODE" in
  safe|backup|overwrite)
    ;;
  *)
    fail "Invalid --mode: $INSTALL_MODE. Use safe, backup, or overwrite."
    ;;
esac

case "$AGENT_TARGETS" in
  codex|claude-code|both)
    ;;
  *)
    fail "Invalid --agent: $AGENT_TARGETS. Use codex, claude-code, or both."
    ;;
esac

mkdir -p "$TARGET_DIR"

PROFILE_DIR="$HARNESS_ROOT/profiles/$PROFILE"
[ -d "$PROFILE_DIR" ] || fail "Profile directory not found: $PROFILE_DIR"

if [ "$INIT_SCAFFOLD" = true ]; then
  INIT_ARGS=("$TARGET_DIR" "--profile" "$PROFILE")
  if [ "$PROFILE" = "mixed" ]; then
    INIT_ARGS+=("--frontend-lang" "$MIXED_FRONTEND_LANG" "--backend-lang" "$MIXED_BACKEND_LANG")
  fi
  if [ "$FORCE_INIT" = true ]; then
    INIT_ARGS+=("--force")
  fi
  if [ "$DRY_RUN" = true ]; then
    log "DRY-RUN: would run init-project.sh ${INIT_ARGS[*]}"
  else
    "$HARNESS_ROOT/scripts/harness/init-project.sh" "${INIT_ARGS[@]}"
  fi
fi

log "Installing AI harness"
log "Target: $TARGET_DIR"
log "Profile: $PROFILE"
log "Mode: $INSTALL_MODE"
log "Agent entrypoints: $AGENT_TARGETS"
if [ "$DRY_RUN" = true ]; then
  log "Dry run: true"
fi

# Agent entrypoint files require special handling so profile rules can be included.
if agent_target_enabled codex; then
  install_agent_entrypoint "AGENTS.md" "templates/AGENTS.base.md" "AGENTS.md" "codex"
  install_harness_namespace "codex"
fi

if agent_target_enabled claude-code; then
  install_agent_entrypoint "CLAUDE.md" "templates/CLAUDE.base.md" "CLAUDE.md" "claude"
  install_claude_code_production_harness
fi

log ""
log "Installed."
if [ "$INSTALL_MODE" = "safe" ]; then
  log ""
  log "Safe mode note:"
  log "  Existing files were not overwritten."
  log "  Review any *.harness-new files:"
  log "    1. Compare each conflict artifact with the existing project file."
  log "    2. Merge useful template content into the real file."
  log "    3. Delete or intentionally keep each *.harness-new file."
  log "    4. Do not commit unresolved template placeholders."
fi
if [ "$INSTALL_MODE" = "backup" ] && [ -n "$BACKUP_DIR" ]; then
  log ""
  log "Backup directory:"
  log "  $BACKUP_DIR"
fi

log ""
log "Next steps:"
log "  cd \"$TARGET_DIR\""

case "$PROFILE" in
  typescript)
    if [ -f "$TARGET_DIR/package.json" ]; then
      log "  pnpm install"
    fi
    ;;
  python-poetry)
    if [ -f "$TARGET_DIR/pyproject.toml" ]; then
      log "  poetry install"
    fi
    ;;
  python-uv)
    if [ -f "$TARGET_DIR/pyproject.toml" ]; then
      log "  uv sync"
    fi
    ;;
esac

if agent_target_enabled codex; then
  log "  ./scripts/codex/bootstrap.sh --check"
  log "  ./scripts/codex/verify.sh"
fi

if agent_target_enabled claude-code; then
  log "  ./scripts/claude/verify.sh"
  log "  Review CLAUDE.md"
  log "  Fill in docs/architecture/tech-stack.md and docs/domain/domain-model.md"
fi
