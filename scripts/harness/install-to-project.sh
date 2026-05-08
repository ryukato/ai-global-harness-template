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

  --dry-run             Print what would happen without writing files.

  -h, --help            Show this help.

Examples:
  # Existing TypeScript project: safe install, no scaffold
  ./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript

  # Existing project with backups, then overwrite harness files
  ./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --mode backup

  # Empty TypeScript test project: create scaffold + harness
  ./scripts/harness/install-to-project.sh /tmp/dummy-ts --profile typescript --init-scaffold

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

append_profile_rules_to_agents() {
  local profile_file="$PROFILE_DIR/AGENTS.append.md"
  local target_agents="$TARGET_DIR/AGENTS.md"

  [ -f "$profile_file" ] || return 0

  local tmp
  tmp="$(mktemp)"

  if [ -f "$target_agents" ]; then
    cat "$target_agents" > "$tmp"
    {
      echo
      echo "<!-- Profile-specific rules appended by ai-global-harness: $PROFILE -->"
      echo
      cat "$profile_file"
    } >> "$tmp"

    if [ "$DRY_RUN" = true ]; then
      case "$INSTALL_MODE" in
        safe)
          log "DRY-RUN conflict: would write merged AGENTS.md to ${target_agents}.harness-new"
          ;;
        backup)
          log "DRY-RUN conflict: would backup then overwrite merged AGENTS.md"
          ;;
        overwrite)
          log "DRY-RUN conflict: would overwrite AGENTS.md with merged profile rules"
          ;;
      esac
      rm -f "$tmp"
      return 0
    fi

    if grep -q "Profile-specific rules appended by ai-global-harness: $PROFILE" "$target_agents"; then
      log "Profile rules already present in AGENTS.md"
      rm -f "$tmp"
      return 0
    fi

    write_file_from_source "$tmp" "$target_agents"
  else
    cat "$HARNESS_ROOT/templates/AGENTS.base.md" > "$tmp"
    {
      echo
      echo "<!-- Profile-specific rules appended by ai-global-harness: $PROFILE -->"
      echo
      cat "$profile_file"
    } >> "$tmp"
    write_file_from_source "$tmp" "$target_agents"
  fi

  rm -f "$tmp"
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
if [ "$DRY_RUN" = true ]; then
  log "Dry run: true"
fi

# AGENTS.md requires special handling so profile rules can be included.
if [ -f "$TARGET_DIR/AGENTS.md" ]; then
  if grep -q "Profile-specific rules appended by ai-global-harness: $PROFILE" "$TARGET_DIR/AGENTS.md"; then
    log "AGENTS.md already contains profile rules for $PROFILE"
  else
    case "$INSTALL_MODE" in
      safe)
        # Do not mutate existing AGENTS.md in safe mode.
        tmp_agents="$(mktemp)"
        cat "$HARNESS_ROOT/templates/AGENTS.base.md" > "$tmp_agents"
        if [ -f "$PROFILE_DIR/AGENTS.append.md" ]; then
          {
            echo
            echo "<!-- Profile-specific rules appended by ai-global-harness: $PROFILE -->"
            echo
            cat "$PROFILE_DIR/AGENTS.append.md"
          } >> "$tmp_agents"
        fi

        if [ "$DRY_RUN" = true ]; then
          log "DRY-RUN conflict: existing AGENTS.md kept; incoming file would be AGENTS.md.harness-new"
        else
          cp "$tmp_agents" "$TARGET_DIR/AGENTS.md.harness-new"
          warn "Existing AGENTS.md kept."
          warn "Incoming AGENTS.md written to: $TARGET_DIR/AGENTS.md.harness-new"
        fi
        rm -f "$tmp_agents"
        ;;
      backup|overwrite)
        append_profile_rules_to_agents
        ;;
    esac
  fi
else
  append_profile_rules_to_agents
fi

copy_template "templates/docs/codex/project-context.md" "docs/codex/project-context.md"
copy_template "templates/docs/codex/code-review.md" "docs/codex/code-review.md"
copy_template "templates/docs/codex/done-definition.md" "docs/codex/done-definition.md"
copy_template "templates/docs/codex/task-template.short.md" "docs/codex/task-template.short.md"
copy_template "templates/docs/codex/task-template.medium.md" "docs/codex/task-template.medium.md"
copy_template "templates/docs/codex/run-log-format.md" "docs/codex/run-log-format.md"
copy_template "templates/docs/codex/general-scaffold-principles.md" "docs/codex/general-scaffold-principles.md"
copy_template "templates/docs/codex/monorepo-layout.md" "docs/codex/monorepo-layout.md"
copy_template "templates/docs/codex/backend-architecture-boundaries.md" "docs/codex/backend-architecture-boundaries.md"
copy_template "templates/docs/codex/frontend-structure.md" "docs/codex/frontend-structure.md"
copy_template "templates/docs/codex/proxy-bff-pattern.md" "docs/codex/proxy-bff-pattern.md"
copy_template "templates/docs/codex/shared-contracts.md" "docs/codex/shared-contracts.md"
copy_template "templates/docs/codex/graphify.md" "docs/codex/graphify.md"
copy_template "templates/docs/codex/harness-profile.md" "docs/codex/harness-profile.md"
copy_template "templates/docs/codex/existing-project-install.md" "docs/codex/existing-project-install.md"
copy_template "templates/docs/codex/typescript-scaffold-troubleshooting.md" "docs/codex/typescript-scaffold-troubleshooting.md"
copy_template "templates/docs/codex/dependency-fallback.md" "docs/codex/dependency-fallback.md"
copy_template "templates/docs/codex/jvm-profiles.md" "docs/codex/jvm-profiles.md"
copy_template "templates/docs/codex/language-server.md" "docs/codex/language-server.md"

# harness-profile.env is intentionally generated for the selected profile.
write_generated_file "$TARGET_DIR/docs/codex/harness-profile.env" "HARNESS_PROFILE=$PROFILE
"

copy_template "templates/scripts/codex/bootstrap.sh" "scripts/codex/bootstrap.sh"
copy_template "templates/scripts/codex/verify.sh" "scripts/codex/verify.sh"
copy_template "templates/scripts/codex/changed-files.sh" "scripts/codex/changed-files.sh"
copy_template "templates/scripts/codex/summarize-diff.sh" "scripts/codex/summarize-diff.sh"
copy_template "templates/scripts/codex/start-run.sh" "scripts/codex/start-run.sh"
copy_template "templates/scripts/codex/collect-run-summary.sh" "scripts/codex/collect-run-summary.sh"
copy_template "templates/scripts/codex/weekly-report.sh" "scripts/codex/weekly-report.sh"
copy_template "templates/scripts/codex/language-server.sh" "scripts/codex/language-server.sh"

if [ "$DRY_RUN" != true ]; then
  chmod +x "$TARGET_DIR"/scripts/codex/*.sh 2>/dev/null || true
  mkdir -p "$TARGET_DIR/.codex-runs"
  touch "$TARGET_DIR/.codex-runs/.gitkeep"
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

log "  ./scripts/codex/bootstrap.sh --check"
log "  ./scripts/codex/verify.sh"
