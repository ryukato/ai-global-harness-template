---
name: jira-ticket-analysis
description: Use when the task is provided as a Jira ticket, issue, or similar lightweight work item.
---


# Jira Ticket Analysis Skill

## Purpose

Turn a reasonably sized Jira ticket into an implementable plan without requiring overly detailed tickets.

## Ticket Quality Principle

A good ticket should describe:

- What outcome is needed
- Why it matters
- Key requirements
- Acceptance criteria
- Explicit out-of-scope items when helpful

A ticket does not need to prescribe class names, file names, internal architecture, or full implementation design.

## Analysis Steps

1. Extract the ticket title and goal.
2. Identify behavior change.
3. Extract requirements and acceptance criteria.
4. Identify missing but necessary context.
5. Resolve context from repository docs and code before asking questions.
6. Convert the ticket into a short implementation plan.
7. Identify test cases from acceptance criteria.

## When Ticket Is Too Vague

Do not stop immediately. First inspect related code, domain documents, architecture documents, nearby tests, and similar previous implementation patterns.

Only ask a question if implementation would otherwise require guessing a business decision.

## Output

- Interpreted goal
- Assumptions
- Affected areas
- Implementation plan
- Test plan
