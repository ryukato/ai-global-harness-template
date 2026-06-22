# cawf:plan

Use this command to turn a Jira ticket, GitHub issue, work item, or short request into a reviewable implementation plan.

## Usage

```text
/project:cawf:plan jira <jira-issue-url>
/project:cawf:plan github <github-issue-url>
/project:cawf:plan work-items/tasks/TASK-123.md
/project:cawf:plan <free-form request>
```

## Prompt

Act as a senior software architect in PLAN mode. Do not edit product code.

Inputs are supplied through `$ARGUMENTS`. Determine whether the input is a Jira URL, GitHub issue URL, work-item path, ticket id, or free-form request.

If the input is Jira or GitHub:

1. Use the available Atlassian or GitHub connector/MCP tool to read the ticket or issue.
2. If the connector is unavailable or access fails, stop and report the missing access.
3. For Jira, compare the ticket structure with `templates/jira/ticket-template.md` when present.

Local setup note:

- Jira and GitHub access must be configured in the developer's local Claude environment.
- Read `docs/operations/local-mcp-setup.md` if connector or MCP access is missing.
- Read `docs/operations/local-api-key-setup.md` if an API key or CLI token is missing.
- Do not ask for or write tokens into the repository.

Use these skills when applicable:

- `jira-ticket-analysis` for Jira tickets or Jira-like work items.
- `github-issue-analysis` for GitHub issues, pull requests, or discussion-style work items.
- `implementation-planning`, `project-tech-stack`, `domain-context`, and `test-strategy` for non-trivial changes.

Then perform these phases in order:

1. Issue interpretation:
   - Extract goal, acceptance criteria, scope, out-of-scope items, constraints, assumptions, and open questions.
   - Mark open questions as `BLOCKER`, `HIGH`, `MEDIUM`, or `LOW`.
   - If any `BLOCKER` or `HIGH` question exists, stop before writing a plan and ask the user for the missing decision.
2. Context loading:
   - Read `CLAUDE.md`, `docs/architecture/*`, `docs/domain/*`, `docs/operations/harness-profile.env`, and the directly relevant source files.
   - Select only directly relevant files, normally no more than 20.
   - Record why each file matters.
3. Impact analysis:
   - Identify files to check or change.
   - Trace likely dependency impact.
   - List risk points by severity.
   - Produce a test plan covering high-risk behavior first.
   - Include rollout, monitoring, or rollback notes only when the change warrants them.

## Output File

Create or reuse this task workspace:

```text
.ai-workspace/active/<TASK-ID>/
```

If no ticket id exists, use `misc-YYYYMMDD-HHMMSS`.

Write the plan to the next available version:

```text
.ai-workspace/active/<TASK-ID>/outputs/plan-v<N>.md
```

Never overwrite an existing plan.

Use this structure:

```markdown
# Plan: <TASK-ID>

> Summary: <2-3 line summary>

## Meta

| Field | Value |
| --- | --- |
| Task ID | <TASK-ID> |
| Source Type | jira / github / work-item / request |
| Source | <url, path, or request summary> |
| Status | complete / pending_answers |
| Version | v<N> |

## Phase 1: Issue Interpretation

### Goal

### Acceptance Criteria

### In Scope

### Out of Scope

### Constraints

### Assumptions

### Open Questions

| Field | Question | Impact |
| --- | --- | --- |

## Phase 2: Context Loading

### Relevant Paths

| Path | Reason |
| --- | --- |

### Relevant Docs

### Repository Constraints

### Unknowns

## Phase 3: Impact Analysis

### Files To Check

| Path | Reason |
| --- | --- |

### Risk Points

| Description | Severity |
| --- | --- |

### Test Plan

| Type | Description | Command or Manual Step |
| --- | --- | --- |

### Deployment Notes
```

Report the saved path, unresolved `MEDIUM`/`LOW` questions, major risks, and recommended next command.
