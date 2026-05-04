# Existing Project Installation Guide

This harness can be applied to existing repositories.

The recommended default is safe mode:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript
```

## Safe Mode

Safe mode is the default.

Behavior:

- New files are created.
- Existing files are not overwritten.
- If a target file already exists and differs, the incoming file is written as:

```text
<original-file>.harness-new
```

Example:

```text
AGENTS.md
AGENTS.md.harness-new
docs/codex/code-review.md
docs/codex/code-review.md.harness-new
```

Review and merge these manually.

## Backup Mode

Use backup mode when you want the harness files applied immediately but still want a rollback copy.

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --mode backup
```

Existing files are backed up to:

```text
.ai-harness-backups/<timestamp>/
```

Then overwritten.

## Overwrite Mode

Use only for throwaway or fully controlled repos.

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile typescript --mode overwrite
```

## Dry Run

Preview changes without writing files:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --dry-run
```

## Empty Project Scaffold

Use `--init-scaffold` only for empty or throwaway projects.

```bash
./scripts/harness/install-to-project.sh /path/to/empty-project --profile typescript --init-scaffold
```

Do not use `--init-scaffold` on normal existing repositories unless you intentionally want to add missing profile-specific project files.

## Recommended Existing Project Flow

```bash
# 1. Preview
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --dry-run

# 2. Safe install
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript

# 3. Review incoming conflicts
find /path/to/existing-project -name "*.harness-new" -print

# 4. Manually merge if needed

# 5. Check
cd /path/to/existing-project
./scripts/codex/bootstrap.sh --check
./scripts/codex/verify.sh
```

## Notes

- `AGENTS.md` is never overwritten in safe mode.
- `docs/codex/harness-profile.env` stores the selected profile.
- `scripts/codex/verify.sh` is designed to work with existing projects by preferring root scripts when present and avoiding duplicate package-level runs.


## Profile-aware verification

The selected profile is written to:

```text
docs/codex/harness-profile.env
```

`verify.sh` reads this file and runs only the matching verification flow.

For example:

```bash
HARNESS_PROFILE=typescript
```

means:

```text
Run Node/TypeScript checks only.
Do not run Python or JVM checks.
```
