---
name: github-issue-analysis
description: Use when the task is provided as a GitHub issue, pull request description, or GitHub discussion-style work item.
---

# GitHub Issue Analysis Skill

## Purpose

Turn a GitHub issue or pull request description into an implementable plan.

This skill covers analysis only. Access to GitHub content depends on the
Claude runtime having a GitHub connector, GitHub MCP server, or authenticated
`gh` CLI available.

## Source Loading

When given a GitHub URL or issue reference:

1. Use the available GitHub connector, MCP tool, or `gh` CLI to load:
   - title
   - body
   - labels
   - linked pull requests or issues when visible
   - comments that clarify scope or acceptance criteria
2. If GitHub access is unavailable, stop and report the missing capability.
3. Do not infer private issue details that were not loaded or provided by the user.

## Analysis Steps

1. Identify the requested outcome and why it matters.
2. Extract explicit acceptance criteria.
3. Convert checklists, reproduction steps, screenshots, and comments into testable requirements.
4. Separate implementation scope from discussion, alternatives, and future work.
5. Record relevant labels such as `bug`, `security`, `regression`, `breaking-change`, or `documentation`.
6. Identify linked code paths, modules, tests, docs, or configuration mentioned in the issue.
7. Resolve missing context from repository docs and nearby code before asking the user.
8. Ask only when a missing decision would change implementation behavior or user-visible outcome.

## Pull Request Context

If the input is a pull request URL:

1. Treat the PR title/body as the declared intent.
2. Read the changed files and review comments when available.
3. Distinguish requested implementation work from review feedback.
4. Do not assume the PR is correct; use the repository code and tests as the source of truth.

## Output

Provide:

- interpreted goal
- acceptance criteria
- in-scope and out-of-scope items
- assumptions
- open questions with severity
- relevant paths to inspect
- initial test plan

Use this skill with `implementation-planning`, `project-tech-stack`,
`domain-context`, and `test-strategy` for non-trivial implementation work.
