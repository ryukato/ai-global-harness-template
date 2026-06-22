# cawf:execute

Use this command to implement an approved CAWF plan and write an execution report.

## Usage

```text
/project:cawf:execute <TASK-ID>
/project:cawf:execute .ai-workspace/active/<TASK-ID>/outputs/plan-v<N>.md
/project:cawf:execute <free-form request>
```

## Prompt

Act as a careful code executor in EXECUTION mode. You may edit files, but only inside the scope justified by the approved plan or user request.

Inputs are supplied through `$ARGUMENTS`. Choose the mode:

1. Task id: find the highest-version `plan-v<N>.md` under `.ai-workspace/active/<TASK-ID>/outputs/`.
2. Plan path: read that exact plan.
3. Free-form request: infer a small scope from the request and current branch. If the work is not trivial, ask the user to run `/project:cawf:plan` first.

Before editing:

1. Read `CLAUDE.md`.
2. Read the selected plan if one exists.
3. Read all paths listed under `Relevant Paths` and `Files To Check`.
4. Stop if the plan contains any `BLOCKER` open question.
5. State assumptions and tradeoffs before making changes.

Implementation rules:

1. Make the minimum precise change required to satisfy the goal and acceptance criteria.
2. Prefer existing project patterns and helpers.
3. Do not introduce dependencies unless they are clearly necessary.
4. Do not change build configuration, rename files, or refactor unrelated code unless the plan requires it.
5. Do not use broad suppressions such as `as any`, `@ts-ignore`, swallowed errors, or untracked TODOs as substitutes for real fixes.
6. Remove only unused code created by your own change.
7. Do not commit, push, create a branch, or open a PR. Use `/project:cawf:git` for that.

Verification rules:

1. Run the plan's test commands first.
2. Run `./scripts/claude/verify.sh` when present.
3. If a test fails, classify it as:
   - `in_scope_regression`: caused by this change; fix within the plan.
   - `pre_existing_failure`: existed outside this change; document and do not fix.
   - `environment_issue`: tool, dependency, secret, service, or infrastructure problem.
4. Retry an in-scope fix at most twice for the same failure.
5. If still blocked, stop and report the blocker instead of expanding scope.

## Output File

Write the execution report to the next available version:

```text
.ai-workspace/active/<TASK-ID>/outputs/execute-v<N>.md
```

If there is no task id, use:

```text
.ai-workspace/active/misc-YYYYMMDD-HHMMSS/outputs/execute-v1.md
```

Never overwrite an existing report.

Use this structure:

```markdown
# Execute: <TASK-ID>

> Summary: <2-3 line implementation and verification summary>

## Meta

| Field | Value |
| --- | --- |
| Task ID | <TASK-ID> |
| Plan File | <path or none> |
| Status | success / blocked |
| Version | v<N> |

## Execution Summary

### Changed Files

| File | Change |
| --- | --- |

### Verification Result

| Test Type | Status | Detail |
| --- | --- | --- |

### Manual Test Checklist

- [ ] ...
```

If blocked, replace the verification section with:

```markdown
## Execution Summary - Blocked

### Changed Files

### Verification Failure

**Failed command:** `<command>`
**Category:** in_scope_regression / pre_existing_failure / environment_issue
**Attempted fixes:** <summary>

**Root cause:**

**Required action from user:**
```

Report the saved execution path, changed file count, verification result, and any manual checks.
