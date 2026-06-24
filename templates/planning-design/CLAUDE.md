# Claude Planning / Design Harness

This repository is a lightweight planning and design workspace. It is not a production application scaffold.

## Context Loading

Read these files before doing planning or design work:

- `docs/planning/product-brief.md`
- `docs/planning/requirement-template.md`
- `docs/planning/acceptance-criteria.md`
- `docs/planning/jira-issue-guidelines.md`
- `docs/design/design-note-template.md`
- `docs/design/figma-review-checklist.md`
- `docs/design/design-ready-checklist.md`
- `docs/design/handoff-guidelines.md`
- `docs/operations/local-mcp-setup.md`
- `docs/operations/local-api-key-setup.md`
- `templates/planning/*`
- `templates/design/*`
- `templates/jira/*`
- `templates/qa/*`
- `templates/retrospective/*`
- `templates/README.md`

## Workflows

- Use `document-to-jira-issue-generation` to turn reviewed requirements into Jira issue drafts.
- Use `figma-to-requirement-review` to compare Figma screens with documented requirements.
- Use `requirement-review` to inspect scope, acceptance criteria, ambiguity, and engineering handoff risk.
- Use `design-handoff-review` to check UI states, copy, accessibility notes, data dependencies, and unresolved decisions.
- Use the artifact templates under `templates/` when drafting release overviews, requirements, handoff notes, Jira tickets, QA plans, or sprint reviews.

## Guardrails

- Do not create implementation code unless the user explicitly asks to switch from planning/design into development.
- Do not modify Jira, Figma, Confluence, GitHub, or other external systems without explicit approval for the exact target and content.
- Do not commit secrets, API keys, access tokens, cookies, or user session data.
- Treat local MCP and API-key setup as each user's own workstation responsibility.

## Output Style

Prefer short structured sections:

- Summary
- Findings
- Open Questions
- Proposed Jira Issues
- Handoff Notes
