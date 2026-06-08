---
name: summarize-changes
description: Summarize uncommitted changes, likely intent, verification status, and risk areas from the current git diff.
---

# Summarize Changes

Use this skill when the user asks what changed, wants a commit message, asks for a diff summary, or wants a quick risk scan before committing.

## Steps

1. Inspect repository status:

```bash
git status --short
```

2. Inspect the relevant diff:

```bash
git diff --stat
git diff
```

3. Summarize:

```text
Summary
- ...

Files changed
- ...

Likely intent
- ...

Verification observed
- ...

Risks / follow-up
- ...
```

Do not stage, commit, push, or open a pull request unless the user explicitly asks.
