---
name: figma-to-requirement-review
description: Compare Figma design artifacts with planning requirements and identify gaps before handoff.
---

# Figma To Requirement Review

Use this skill when the user asks whether a Figma design is ready for requirement or engineering handoff.

## Inputs

- Figma link or selected frame context
- `docs/planning/*`
- `docs/design/figma-review-checklist.md`
- `docs/design/design-ready-checklist.md`

## Rules

- Compare the design against documented requirements.
- Identify missing states, flows, copy, data dependencies, and accessibility notes.
- Do not edit Figma files without explicit approval.
- Do not create Jira issues without explicit approval.
- If Figma MCP is unavailable, explain what cannot be verified and continue from screenshots or written context if available.

## Output

Return:

- Summary
- Requirement Coverage
- Missing or Ambiguous UI States
- Design / Requirement Mismatches
- Handoff Risks
- Recommended Follow-up Issues
