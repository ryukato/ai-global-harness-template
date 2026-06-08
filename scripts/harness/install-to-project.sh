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
                        jvm-gradle-java, jvm-gradle-kotlin,
                        jvm-maven-java, jvm-maven-kotlin.
                        Use this for empty or throwaway projects, not normal existing repos.

  --force-init          Allow init scaffold to overwrite existing scaffold files.

  --mode <mode>         How to handle existing harness target files.
                        safe       Default. Do not overwrite existing files. Write incoming files as *.harness-new.
                        backup     Backup existing files to .ai-harness-backups/<timestamp>/, then overwrite.
                        overwrite  Overwrite existing files directly.

  --agent <agent>       Agent entrypoint to install.
                        codex       Default. Install AGENTS.md.
                        claude-code Install CLAUDE.md.
                        both        Install both AGENTS.md and CLAUDE.md.

  --dry-run             Print what would happen without writing files.

  -h, --help            Show this help.

Examples:
  # Existing TypeScript project: safe install, no scaffold
  ./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript

  # Existing project with backups, then overwrite harness files
  ./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --mode backup

  # Empty TypeScript test project: create scaffold + harness
  ./scripts/harness/install-to-project.sh /tmp/dummy-ts --profile typescript --init-scaffold

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

  if [ "$namespace" = "claude" ]; then
    sed \
      -e "s#docs/codex#docs/$namespace#g" \
      -e "s#scripts/codex#scripts/$namespace#g" \
      -e "s#\\.codex-runs#.$namespace-runs#g" \
      -e "s#docs/$namespace/code-review.md#.claude/skills/code-review/SKILL.md#g" \
      -e "s#docs/$namespace/legacy-project-guidance.md#.claude/skills/legacy-maintenance/SKILL.md#g" \
      -e "s#docs/$namespace/atlassian-mcp.md#.claude/skills/atlassian-context/SKILL.md#g" \
      -e "s#docs/$namespace/graphify.md#.claude/skills/graphify/SKILL.md#g" \
      -e "s#docs/$namespace/dependency-fallback.md#.claude/skills/dependency-fallback/SKILL.md#g" \
      -e "s#docs/$namespace/language-server.md#.claude/skills/language-server-setup/SKILL.md#g" \
      "$src" > "$dst"
  else
    sed \
      -e "s#docs/codex#docs/$namespace#g" \
      -e "s#scripts/codex#scripts/$namespace#g" \
      -e "s#\\.codex-runs#.$namespace-runs#g" \
      "$src" > "$dst"
  fi
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

install_claude_project_skills() {
  copy_template_for_namespace "templates/skills/claude/code-review/SKILL.md" ".claude/skills/code-review/SKILL.md" "claude"
  copy_template_for_namespace "templates/skills/claude/legacy-maintenance/SKILL.md" ".claude/skills/legacy-maintenance/SKILL.md" "claude"
  copy_template_for_namespace "templates/skills/claude/atlassian-context/SKILL.md" ".claude/skills/atlassian-context/SKILL.md" "claude"
  copy_template_for_namespace "templates/skills/claude/graphify/SKILL.md" ".claude/skills/graphify/SKILL.md" "claude"
  copy_template_for_namespace "templates/skills/claude/dependency-fallback/SKILL.md" ".claude/skills/dependency-fallback/SKILL.md" "claude"
  copy_template_for_namespace "templates/skills/claude/language-server-setup/SKILL.md" ".claude/skills/language-server-setup/SKILL.md" "claude"
  copy_template_for_namespace "templates/skills/claude/summarize-changes/SKILL.md" ".claude/skills/summarize-changes/SKILL.md" "claude"
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

  copy_template_for_namespace "templates/docs/codex/project-context.md" "$docs_dir/project-context.md" "$namespace"
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
  if [ "$namespace" != "claude" ]; then
    copy_template_for_namespace "templates/docs/codex/language-server.md" "$docs_dir/language-server.md" "$namespace"
  else
    copy_template_for_namespace "templates/docs/codex/claude-skills.md" "$docs_dir/claude-skills.md" "$namespace"
    install_claude_project_skills
  fi

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
  install_harness_namespace "claude"
fi

log ""
log "Installed."
if [ "$INSTALL_MODE" = "safe" ]; then
  log ""
  log "Safe mode note:"
  log "  Existing files were not overwritten."
  log "  Review any *.harness-new files and merge manually if needed."
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
  log "  ./scripts/claude/bootstrap.sh --check"
  log "  ./scripts/claude/verify.sh"
fi
