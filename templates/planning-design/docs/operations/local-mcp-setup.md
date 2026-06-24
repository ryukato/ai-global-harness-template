# Local MCP Setup

Coding agents run on each user's local environment. Jira, Figma, GitHub, and similar MCP servers must be configured locally by each user.

## Files

- Use `.mcp.example.json` as a reference.
- Keep real `.mcp.json` files local.
- Do not commit `.mcp.json`, `.env`, access tokens, cookies, or generated session files.

## Jira / Atlassian

Configure Atlassian MCP using your organization-approved method. Confirm that the local agent can read only the projects and spaces you are allowed to access.

## Figma

Configure Figma MCP using your organization-approved method. Confirm that the local agent can read the target file or frame before asking it to review a design.

## GitHub

GitHub MCP may require a Personal Access Token depending on your local setup.

Recommended token scope should be the minimum needed for the task:

- Repository read access for review-only workflows.
- Pull request read/write access only when the agent must create or update PR content.
- Issue read/write access only when the agent must create or update issues.

Token setup checklist:

1. Create the token from your GitHub account settings.
2. Limit repository access to the required organization or repository.
3. Set an expiration date.
4. Store it in your local secret manager or uncommitted `.env` file.
5. Reference it from `.mcp.json` using an environment variable such as `${GITHUB_TOKEN}`.

Never paste a token into tracked repository files.
