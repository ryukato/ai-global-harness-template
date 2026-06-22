# Production Harness Guide

## What This Harness Is

A practical Claude Code harness for production repositories.

It supports:

- Jira-based work
- Repository-local work items
- CAWF-style plan, execute, review, and git commands
- Project-specific tech stack guidance
- Project-specific domain guidance
- Implementation planning
- Code review
- Test strategy
- Release readiness

## Recommended Usage

### Jira-Based

1. Put right-sized requirements in Jira.
2. Ask Claude Code to implement the ticket.
3. Claude uses:
   - `jira-ticket-analysis`
   - `implementation-planning`
   - `project-tech-stack`
   - `domain-context`
   - `test-strategy`

### GitHub-Based

1. Put the requirement in a GitHub issue or PR description.
2. Ask Claude Code to plan or implement from that GitHub source.
3. Claude uses:
   - `github-issue-analysis`
   - `implementation-planning`
   - `project-tech-stack`
   - `domain-context`
   - `test-strategy`

### Non-Jira

1. Create `work-items/tasks/TASK-xxx.md`.
2. Ask Claude Code to implement that work item.
3. Keep domain/architecture context in `docs/*`, not inside every task.

### CAWF Command Workflow

For teams that want a stricter staged workflow, use the CAWF commands adapted
from the internal coding-agent-wf POC:

```text
/project:cawf:plan <jira-url | github-url | work-item | request>
/project:cawf:execute <TASK-ID | plan path>
/project:cawf:review [origin/develop | origin/main]
/project:cawf:git <TASK-ID>
```

These commands save versioned artifacts under:

```text
.ai-workspace/active/<TASK-ID>/outputs/
```

Use this flow when you want human-reviewable planning and execution records
before commit or PR work.

Jira/GitHub loading requires the matching connector, MCP server, or authenticated
CLI in the user's Claude environment. This harness provides the reusable
analysis workflow, not repository-committed credentials.
See:

```text
docs/operations/local-api-key-setup.md
docs/operations/local-mcp-setup.md
```

## Right-Sized Ticket Principle

Tickets should define WHAT and WHY.

The repository harness should define HOW:

- architecture
- coding rules
- domain rules
- testing strategy
- release checklist

## Production Notes

A Production Harness should not be a pile of prompts.
It should be a maintainable context system:

- short global rules
- reusable skills
- stable project documents
- lightweight work items

---

## Agent Output Sharing Structure

This harness uses `.ai-workspace` to make multi-agent work visible to the team.

```text
.ai-workspace/active/<TASK-ID>/
├── task.md
├── context/
├── outputs/
└── final-summary.md
```

Recommended default agent flow:

```text
explorer -> implementer -> reviewer
```

Use `architect` only for large or architecture-sensitive tasks.

### Why File-Based Outputs

File-based outputs make AI work:

- reviewable
- searchable
- archivable
- shareable across team members
- independent from chat history

### Document Growth Control

Detailed files under `.ai-workspace/active` are not intended to live forever.
They are archived at release/tag time according to:

```text
docs/operations/ai-artifact-archive-policy.md
```
