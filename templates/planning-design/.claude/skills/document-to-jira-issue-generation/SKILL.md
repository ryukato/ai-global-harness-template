---
name: document-to-jira-issue-generation
description: Convert reviewed planning documents into Jira-ready issue drafts.
---

# Document To Jira Issue Generation

Use this skill when the user wants to turn a planning document, product brief, or requirement note into Jira issue drafts.

## Inputs

- `docs/planning/product-brief.md`
- `docs/planning/requirement-template.md`
- `docs/planning/acceptance-criteria.md`
- `templates/jira/ticket-template.md`
- `templates/planning/release-overview-template.md`
- `templates/planning/requirement-template.md`
- Any user-provided planning document

## Rules

- Generate Jira-ready drafts first.
- Do not create, update, transition, or comment on Jira issues without explicit approval for the exact project, issue type, summary, and body.
- Preserve traceability back to the source document.
- Split large requirements into independently reviewable issues.
- Mark assumptions and open questions instead of inventing missing requirements.

## Output

For each issue draft, provide:

- Issue Type
- Summary
- Description
- Acceptance Criteria
- Dependencies
- Labels
- Source Reference
- Open Questions
