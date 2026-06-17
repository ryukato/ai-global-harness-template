# Claude Code Production Harness v2

Production-oriented Claude Code harness for long-lived repositories.

Supports both:

1. Jira-based work management
2. Repository-local work items

Core idea:

- `CLAUDE.md` = always-on repository rules
- `.claude/skills/*` = reusable task guidance
- `.claude/commands/*` = repeatable workflow prompts
- `.claude/agents/*` = optional role-specific guidance
- `docs/architecture/*` = technical context
- `docs/domain/*` = business/domain context
- `work-items/*` or Jira = implementation scope

Fill in `docs/architecture/tech-stack.md` and `docs/domain/domain-model.md` for each project.
