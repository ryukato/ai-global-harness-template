# Planning / Design Harness Guide

This harness is for product managers, planners, and designers who need a lighter agent workspace than the full engineering harness.

## What It Installs

- `CLAUDE.md` and `AGENTS.md`
- Claude agents and skills for requirement review, Jira issue drafting, Figma review, and design handoff
- Planning documents under `docs/planning`
- Design documents under `docs/design`
- Local setup guidance under `docs/operations`
- Artifact templates under `templates/planning`, `templates/design`, `templates/jira`, `templates/qa`, and `templates/retrospective`

It intentionally does not install application code, build scripts, architecture templates, release archive workflows, or `scripts/claude/verify.sh`.

## Recommended Start

```bash
./scripts/harness/install-to-project.sh /path/to/workspace --profile planning-design
```

Then fill in:

```text
docs/planning/product-brief.md
docs/planning/requirement-template.md
docs/design/design-note-template.md
```

Use these reusable artifact templates when creating formal deliverables:

```text
templates/README.md
templates/planning/release-overview-template.md
templates/planning/requirement-template.md
templates/design/design-handoff-template.md
templates/jira/ticket-template.md
templates/qa/qa-test-plan-template.md
templates/retrospective/sprint-review-retrospective-template.md
```

## External Tools

Jira, Figma, GitHub, and other MCP/API credentials are expected to be configured on each user's local machine. Use:

```text
docs/operations/local-mcp-setup.md
docs/operations/local-api-key-setup.md
```

Do not commit `.mcp.json`, `.env`, or token files.
