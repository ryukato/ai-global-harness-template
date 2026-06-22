# Local API Key Setup for Coding Agents

## Purpose

Some coding-agent workflows require API keys in the developer's local runtime.
Examples include LLM provider APIs, GitHub CLI tokens, internal API sandboxes,
or tool-specific credentials used by MCP servers.

API keys are local secrets. They must not be committed to the repository.

## Recommended Storage

Prefer one of these local-only storage options:

```text
1. The agent client's built-in secret manager, when available.
2. The operating system keychain or password manager.
3. Shell environment variables loaded from the developer's private shell profile.
4. A local env file that is ignored by git, such as `.env.local` or `.env.agent.local`.
```

Do not store real keys in checked-in docs, examples, screenshots, run logs, or
task output files.

## Common Environment Variables

Use the variable names required by the selected local tool. Common examples:

```bash
# LLM providers
export ANTHROPIC_API_KEY="..."
export OPENAI_API_KEY="..."

# GitHub CLI or GitHub API tooling
export GITHUB_TOKEN="..."

# Internal services or sandboxes
export INTERNAL_API_BASE_URL="https://..."
export INTERNAL_API_KEY="..."
```

These examples are placeholders. Keep project-approved variable names in
`docs/codex/project-context.md`, but never include real values.

## Local Env File Pattern

If the team uses local env files, create a private file:

```bash
cp .env.example .env.local
```

Then edit `.env.local` locally:

```dotenv
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GITHUB_TOKEN=
INTERNAL_API_BASE_URL=
INTERNAL_API_KEY=
```

The repository `.gitignore` should ignore:

```text
.env
.env.*        # covers `.env.local` and `.env.agent.local`
!.env.example
.secrets/
```

Only `.env.example` may be committed, and it must contain placeholders only.

## Validation

Before running workflows that require API keys, each developer should verify:

```bash
test -n "$ANTHROPIC_API_KEY" || echo "ANTHROPIC_API_KEY is not set"
test -n "$OPENAI_API_KEY" || echo "OPENAI_API_KEY is not set"
gh auth status
```

Run only the checks relevant to the tools used by the project.

## Rotation and Scope

- Use least-privilege API keys.
- Prefer per-developer keys over shared team keys.
- Prefer read-only keys for planning and review workflows.
- Rotate keys immediately if they appear in commits, logs, screenshots, or agent output files.
- Revoke keys that are no longer needed.

## Agent Rules

When an API key is missing:

1. Stop and report the missing local variable or credential.
2. Do not ask the user to paste a secret into chat unless the client provides a secure secret-entry mechanism.
3. Do not write secrets to repository files.
4. Continue with a no-network or pasted-context fallback only when the task can be completed safely without the key.

## Project-Specific Fields

Record non-secret project settings in `docs/codex/project-context.md`:

```text
Required local API variables:
Optional local API variables:
Secret owner or support channel:
Rotation policy:
Approved storage method:
Allowed agent write actions:
```
