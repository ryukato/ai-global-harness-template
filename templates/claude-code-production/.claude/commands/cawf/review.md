# cawf:review

Use this command to review the current branch diff against the expected base branch and write review findings.

## Usage

```text
/project:cawf:review
/project:cawf:review origin/main
/project:cawf:review origin/develop
```

## Prompt

Act as a principal software engineer and code review architect. Review for correctness, security, performance, maintainability, test coverage, and unintended behavior.

Inputs are supplied through `$ARGUMENTS`.

1. Determine the base ref:
   - Use `$ARGUMENTS` when provided.
   - Otherwise prefer `origin/develop` if it exists.
   - Otherwise use `origin/main`.
2. Run:

```text
git diff -U5 --merge-base <base-ref>
```

3. Summarize the apparent intent of the change in one sentence before listing findings.
4. Read every changed file.
5. Read directly imported, called, or neighboring files when needed to understand behavior.
6. Focus deepest analysis on non-test application code. Review tests for meaningful correctness gaps, not cosmetic issues.

Review constraints:

1. Comment only on changed lines from the diff.
2. Report only demonstrable bugs, risks, or meaningful improvement opportunities.
3. Do not add style nits unless they affect execution, readability, or maintainability in a material way.
4. Do not tell the author to merely "check", "confirm", "verify", or "ensure" something. State the concrete issue and suggested fix.
5. Do not comment on license headers, copyright headers, or future dates.
6. If the same issue appears in several places, report it once and mention the other locations.

Severity:

- `CRITICAL`: security vulnerability, data loss, or system-breaking bug.
- `HIGH`: major correctness issue, severe performance problem, resource leak, or architecture violation.
- `MEDIUM`: missing validation, fragile logic, meaningful maintainability problem, or incorrect test assertion.
- `LOW`: small but useful cleanup, documentation typo, test quality concern, or minor maintainability improvement.

## Output File

If a task workspace can be inferred from a plan or branch ticket id, write to:

```text
.ai-workspace/active/<TASK-ID>/outputs/review-v<N>.md
```

Otherwise write to:

```text
.ai-workspace/active/review-YYYYMMDD-HHMMSS/outputs/review-v1.md
```

Never overwrite an existing report.

Use this output structure:

````markdown
# Review: <TASK-ID or branch>

# Change summary: <single sentence>

## Findings

### File: path/to/file

#### L<LINE_NUMBER>: [<SEVERITY>] <single sentence summary>

<Why this is an issue.>

Suggested change:

```diff
 unchanged line
-old line
+new line
 unchanged line
```
````

If no issues are found:

```markdown
# Change summary: <single sentence>

No issues found. Code looks ready to merge.
```

Report findings first, ordered by severity, then mention the saved review path and any residual test gaps.
