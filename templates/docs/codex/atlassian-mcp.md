# Atlassian MCP Integration

This document records optional setup guidance for connecting AI coding agents to Atlassian Jira and Confluence through Atlassian's official Rovo MCP Server.

Confluence is the Atlassian wiki product. In this harness, "Atlassian Wiki" means Confluence unless the project documents a different wiki system.

## Official Server

Use Atlassian's current remote MCP endpoint:

```text
https://mcp.atlassian.com/v1/mcp/authv2
```

Atlassian documents that the older SSE endpoint is no longer the recommended target and will not be supported after June 30, 2026:

```text
https://mcp.atlassian.com/v1/sse
```

Do not add the old SSE endpoint to new project guidance.

## What It Can Access

Depending on the user's Atlassian permissions and client support, Atlassian Rovo MCP can provide access to:

- Jira work items and project data
- Confluence pages and spaces
- Compass data, when the site uses Compass

Typical workflows include searching and summarizing Jira or Confluence content, creating or updating Jira issues or Confluence pages, and linking related content.

Actual capabilities vary by:

- the authenticated user's Jira, Confluence, or Compass permissions
- enabled tools in the MCP client
- Atlassian organization controls
- IP allowlisting and domain allowlisting policies

## Authentication and Security

Atlassian documents OAuth 2.1 as the recommended/default authorization flow for the Rovo MCP Server.

API token authentication may be available only if an Atlassian organization admin enables it. Do not assume API token authentication is allowed.

Security expectations:

- Do not commit OAuth tokens, API tokens, cookies, or local MCP credential files.
- MCP access should use the signed-in user's existing Atlassian permissions.
- High-impact write actions, such as creating/updating Jira issues or Confluence pages, should be confirmed in the task before execution.
- If the organization uses IP allowlisting, MCP tool calls must originate from allowed IPs for the relevant Atlassian app.
- Organization admins may control which external AI tool domains are allowed.
- Admins can review or revoke connected app access through Atlassian administration.

## Prerequisites

For supported remote clients:

- An Atlassian Cloud site with Jira, Confluence, and/or Compass.
- Access to the AI client or IDE.
- A browser for OAuth 2.1 authorization.
- Atlassian permissions for the projects, spaces, or pages the agent needs.

For local IDE or custom MCP clients:

- Node.js v18 or later.
- `npx`, if using `mcp-remote`.
- A browser for OAuth 2.1 authorization.
- An MCP-compatible client that supports remote HTTP servers or local stdio proxy servers.

## Example Client Configuration

Prefer a native remote HTTP MCP configuration when the client supports it:

```json
{
  "servers": {
    "atlassian-mcp-server": {
      "url": "https://mcp.atlassian.com/v1/mcp/authv2",
      "type": "http"
    }
  },
  "inputs": []
}
```

For clients that require a local stdio proxy, use `mcp-remote`:

```json
{
  "mcp.servers": {
    "Atlassian-Rovo-MCP": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote@latest",
        "https://mcp.atlassian.com/v1/mcp/authv2"
      ]
    }
  }
}
```

Manual proxy test:

```bash
npx -y mcp-remote@latest https://mcp.atlassian.com/v1/mcp/authv2
```

Keep the terminal session running while testing clients that connect through this local proxy.

## Project Context Fields

When a project uses Atlassian, fill these in `docs/codex/project-context.md`:

```text
Atlassian Cloud site URL:
Jira project keys:
Confluence spaces:
Primary product/spec pages:
Issue workflow constraints:
Allowed write actions:
Required confirmation before writes:
```

Examples:

```text
Atlassian Cloud site URL: https://example.atlassian.net
Jira project keys: QSM, MEDIA
Confluence spaces: QSM, ENG
Allowed write actions: read-only by default; create/update only when explicitly requested
```

## Agent Rules

- Prefer Atlassian MCP reads for Jira/Confluence context when the task references tickets, product specs, wiki pages, runbooks, or acceptance criteria.
- Treat Jira and Confluence as external source material; do not copy large page contents into code or docs unless the task explicitly requires a small excerpt.
- Summarize external context in the final report when it influenced code changes.
- Confirm before performing write actions in Jira or Confluence unless the user explicitly requested that exact write action.
- If Atlassian MCP is unavailable, report that clearly and ask for the relevant ticket/page content or URL.

## Troubleshooting

- If OAuth opens but tool calls fail, check Atlassian app permissions and IP allowlisting.
- If an admin authorization error appears, an Atlassian site or organization admin may need to complete the first consent flow or allow the AI tool domain.
- If API-token authentication fails, confirm whether the organization allows API-token auth for the Rovo MCP Server.
- If using `mcp-remote`, confirm Node.js v18+ and `npx` are available.

## References

- Atlassian Rovo MCP getting started: https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/
- Atlassian Rovo MCP IDE setup: https://support.atlassian.com/atlassian-rovo-mcp-server/docs/setting-up-ides/
- Atlassian Rovo MCP security/admin overview: https://support.atlassian.com/security-and-access-policies/docs/understand-atlassian-rovo-mcp-server/
- Atlassian remote MCP server overview: https://www.atlassian.com/platform/remote-mcp-server
