# AI Task Run Log Format

Use this format when recording agent-assisted work.

```text
.codex-runs/
  YYYYMMDD-HHMM-task-slug/
    task.md
    changed-files.txt
    diffstat.txt
    verify-result.txt
    summary.md
```

## task.md

Original task instruction.

## changed-files.txt

Output of:

```bash
git status --short
git diff --name-status
```

## diffstat.txt

Output of:

```bash
git diff --stat
```

## verify-result.txt

Output of:

```bash
./scripts/codex/verify.sh
```

## summary.md

Final summary:

- Summary
- Files changed
- Commands run
- Verification result
- Risks / follow-up
