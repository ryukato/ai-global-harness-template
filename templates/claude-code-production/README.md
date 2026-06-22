# Claude Code Production Harness v2

Production-oriented Claude Code harness for long-lived repositories.

Supports both:

1. Jira-based work management
2. Repository-local work items

Core idea:

- `CLAUDE.md` = always-on repository rules
- `.claude/skills/*` = reusable task guidance
- `.claude/commands/*` = repeatable workflow prompts
- `.claude/commands/cawf/*` = staged plan, execute, review, and git workflow
- `.claude/agents/*` = optional role-specific guidance
- `docs/architecture/*` = technical context
- `docs/domain/*` = business/domain context
- `work-items/*` or Jira = implementation scope

Fill in `docs/architecture/tech-stack.md` and `docs/domain/domain-model.md` for each project.

CAWF-style commands:

```text
/project:cawf:plan
/project:cawf:execute
/project:cawf:review
/project:cawf:git
```

Their artifacts are stored in `.ai-workspace/active/<TASK-ID>/outputs/`.

Jira and GitHub commands require matching runtime access:

```text
Jira    -> Atlassian connector/MCP
GitHub  -> GitHub connector/MCP or authenticated gh CLI
```

Each developer configures this access in their own local coding-agent runtime.
Do not commit tokens or local auth files. See:

```text
docs/operations/local-api-key-setup.md
docs/operations/local-mcp-setup.md
```
