---
name: atlassian-context
description: Use Jira and Confluence context through Atlassian Rovo MCP safely for tickets, specs, runbooks, and wiki references.
---

# Atlassian Context

Use this skill when a task references Jira issues, Confluence/wiki pages, product specs, runbooks, acceptance criteria, or Atlassian project context.

Confluence is the Atlassian wiki product. In this harness, "Atlassian Wiki" means Confluence unless the project documents another wiki system.

## Official Remote MCP Server

Use Atlassian's current remote MCP endpoint when configuring clients:

```text
https://mcp.atlassian.com/v1/mcp/authv2
```

For local IDE or custom MCP clients that need a stdio proxy, Atlassian documents this `mcp-remote` pattern:

```bash
npx -y mcp-remote@latest https://mcp.atlassian.com/v1/mcp/authv2
```

Do not add the older SSE endpoint to new project guidance. Atlassian documents the older SSE endpoint as no longer recommended and not supported after June 30, 2026.

## What To Check

Read `docs/claude/project-context.md` for:

```text
Atlassian Cloud site URL
Jira project keys
Confluence spaces
Primary product/spec pages
Issue workflow constraints
Allowed write actions
Required confirmation before writes
```

## Rules

- Use configured Atlassian MCP tools when available and when the user has appropriate permissions.
- Treat Jira and Confluence as external source material.
- Summarize relevant findings instead of copying large page contents into repository files.
- Confirm before creating or updating Jira issues or Confluence pages unless the user explicitly requested that exact write action.
- Never commit OAuth tokens, API tokens, cookies, or local MCP credential files.
- If MCP access is unavailable, say so clearly and ask for the relevant ticket/page content or URL.

## Security Notes

Atlassian Rovo MCP access depends on the authenticated user's product permissions, client support, organization controls, IP allowlisting, and domain allowlisting policies. Do not assume API-token authentication is allowed; Atlassian documents OAuth 2.1 as the recommended/default authorization flow.

## References

- Atlassian Rovo MCP getting started: https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/
- Atlassian Rovo MCP IDE setup: https://support.atlassian.com/atlassian-rovo-mcp-server/docs/setting-up-ides/
- Atlassian Rovo MCP security/admin overview: https://support.atlassian.com/security-and-access-policies/docs/understand-atlassian-rovo-mcp-server/
- Atlassian remote MCP server overview: https://www.atlassian.com/platform/remote-mcp-server
