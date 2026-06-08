# Graphify Integration

## Purpose

Graphify can be used as an optional repository navigation and graph-generation tool for AI coding agents.

This harness does not require Graphify, but it can install and apply the Graphify integration during bootstrap.

## Bootstrap Commands

Check whether Graphify is available:

```bash
./scripts/codex/bootstrap.sh --check
```

Install/apply Graphify for Codex:

```bash
./scripts/codex/bootstrap.sh --apply --graphify --graphify-platform codex
```

Install/apply Graphify for Claude Code:

```bash
./scripts/claude/bootstrap.sh --apply --graphify --graphify-platform default
```

Install/apply Graphify for OpenCode:

```bash
./scripts/codex/bootstrap.sh --apply --graphify --graphify-platform opencode
```

Use Graphify's default install path:

```bash
./scripts/codex/bootstrap.sh --apply --graphify --graphify-platform default
```

Attempt graph rebuild when your local Graphify CLI supports it:

```bash
./scripts/codex/bootstrap.sh --apply --graphify --rebuild-graph
```

## Package / CLI Names

- PyPI package: `graphifyy`
- CLI command: `graphify`

Preferred install paths:

```bash
uv tool install graphifyy
pipx install graphifyy
python -m pip install --user graphifyy
```

## Platform Install Examples

```bash
graphify install --platform codex
graphify install --platform opencode
graphify install --platform aider
graphify install --platform copilot
```

For Graphify's default platform behavior:

```bash
graphify install
```

For Claude Code, prefer Graphify's default install behavior unless your local Graphify CLI documents a Claude-specific platform value:

```bash
graphify install
```

Do not assume `claude-code` is a valid Graphify platform name unless your local CLI explicitly documents it.

## Graph Output

Expected output:

```text
graphify-out/
  GRAPH_REPORT.md
  graph.html
  graph.json
  cache/
```

When `graphify-out/GRAPH_REPORT.md` exists, agents should use it as a repository navigation aid before broad search.

## Usage Pattern

- Graphify is optional.
- If enabled for a project, use it before and after significant structural changes when practical.
- Store generated graph output under `graphify-out/`.
- Do not commit large generated cache files unless the repository intentionally tracks them.
- If Graphify cannot run, report:
  - command attempted
  - error summary
  - likely cause
  - recommended follow-up
