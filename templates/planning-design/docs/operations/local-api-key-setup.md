# Local API Key Setup

Some agent workflows may need API keys for Jira, Figma, GitHub, LLM providers, or internal tools.

## Rules

- Store keys locally only.
- Prefer a system keychain, password manager, or local shell profile.
- If an `.env` file is needed, keep it untracked.
- Rotate keys immediately if they are committed, pasted into chat, or shared in logs.

## Example

```bash
export GITHUB_TOKEN="..."
export FIGMA_TOKEN="..."
export ATLASSIAN_API_TOKEN="..."
```

Use names that match your local MCP configuration.

## Verification

Before asking an agent to use an external tool, verify:

- The key belongs to your own account or approved service account.
- The key has the minimum required permissions.
- The key expiration and rotation policy are acceptable.
- The target project, repository, or design file is allowed for agent access.
