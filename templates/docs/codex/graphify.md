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
