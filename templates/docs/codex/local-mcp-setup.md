# Local MCP Setup for Coding Agents

## Purpose

Coding agents run in each developer's local environment. Access to Jira,
Confluence, GitHub, and other external systems is therefore a local developer
setup concern, not a repository credential concern.

This repository provides harness instructions, reusable prompts, scripts, and
review guidance. It does not provide shared MCP credentials.

For local API key setup, see:

```text
docs/codex/local-api-key-setup.md
```

## Required Local Setup

Each developer who wants agent workflows to read Jira, Confluence, GitHub
issues, or pull requests must configure the matching connector, MCP server, or
CLI authentication in their own local agent runtime.

Typical requirements:

```text
Jira / Confluence -> Atlassian connector or Atlassian Rovo MCP
GitHub            -> GitHub connector, GitHub MCP, or authenticated gh CLI
```

## Repository Boundary

Commit these items:

- project-level Jira project keys or GitHub repository names
- allowed read/write actions
- links to public or internal setup documentation
- non-secret MCP server names or endpoint references
- fallback instructions for when MCP access is unavailable

Do not commit these items:

- OAuth tokens
- API tokens
- cookies
- local MCP config files containing secrets
- personal access tokens
- generated local auth caches
- `.env` files with credentials
- `.env.agent*` files with credentials
- `.secrets/` files or directories

## Recommended Developer Checklist

Before using Jira or GitHub backed agent workflows, each developer should verify:

1. The local agent client can list the configured MCP/connector tools.
2. The developer is signed in with their own user account.
3. Jira/Confluence access matches the developer's normal permissions.
4. GitHub access matches the developer's normal repository permissions.
5. Write actions require explicit task or user approval.
6. Tokens and local auth files are excluded by `.gitignore` or stored outside the repository.

## Fallback Behavior

If a connector or MCP server is unavailable, the agent must stop and report the
missing local setup. It should ask the user to provide the relevant issue,
ticket, or PR content directly instead of guessing.

For read-only planning, pasted ticket content is acceptable when it does not
include secrets or sensitive customer data.

## Project-Specific Fields

Record non-secret project settings in `docs/codex/project-context.md`:

```text
Atlassian Cloud site URL:
Jira project keys:
Confluence spaces:
GitHub organization:
GitHub repositories:
Allowed agent write actions:
Required approval before writes:
Local setup owner or support channel:
```

## Security Notes

- MCP access should use each developer's own identity and permissions.
- Shared bot credentials should not be used unless the security model is
  explicitly approved by the organization.
- Agents should summarize external context in outputs, not copy entire private
  ticket or wiki contents into repository files.
- Redact sensitive values before writing agent outputs to run logs or task files.
