---
name: graphify
description: Use optional Graphify repository maps and bootstrap integration without assuming global installs or unsupported platform names.
---

# Graphify

Use this skill when the user asks about Graphify, repository graphing, graph rebuilds, or navigation through `graphify-out/`.

## Harness Commands

Check whether Graphify is available:

```bash
./scripts/claude/bootstrap.sh --check
```

Apply Graphify for Claude Code using Graphify's default install behavior:

```bash
./scripts/claude/bootstrap.sh --apply --graphify --graphify-platform default
```

Attempt graph rebuild only when the local Graphify CLI supports it:

```bash
./scripts/claude/bootstrap.sh --apply --graphify --rebuild-graph
```

## Package / CLI Names

- PyPI package: `graphifyy`
- CLI command: `graphify`

Do not assume `claude-code` is a valid Graphify platform name unless the local `graphify` CLI explicitly documents it.

## Usage Pattern

- Graphify is optional.
- Do not install or modify Graphify globally unless the user explicitly asks and the action is safe.
- When `graphify-out/GRAPH_REPORT.md` exists, use it as a repository navigation aid before broad search.
- Store generated graph output under `graphify-out/`.
- Do not commit large generated cache files unless the repository intentionally tracks them.
- If Graphify cannot run, report the command attempted, error summary, likely cause, and recommended follow-up.
