# Claude Code Project Skills

This document explains how the Claude Code harness separates always-read project documents from on-demand project skills.

## Official Shape

Claude skills are directories that contain a required `SKILL.md` file.

Project-local skills live at:

```text
.claude/skills/<skill-name>/SKILL.md
```

Claude Code also supports personal skills under:

```text
~/.claude/skills/<skill-name>/SKILL.md
```

`SKILL.md` starts with YAML frontmatter. The `name` should match the skill directory name, and `description` tells Claude when to load the skill.

## Installed Harness Skills

For Claude Code installs, the harness keeps general project context in `docs/claude/` and installs repeatable workflow guidance as project skills:

```text
.claude/skills/code-review/SKILL.md
.claude/skills/legacy-maintenance/SKILL.md
.claude/skills/atlassian-context/SKILL.md
.claude/skills/graphify/SKILL.md
.claude/skills/dependency-fallback/SKILL.md
.claude/skills/language-server-setup/SKILL.md
.claude/skills/summarize-changes/SKILL.md
```

These are project skills, so they apply only inside the repository where the harness is installed.

## What Stays In docs/claude

Keep stable, always-useful project facts in `docs/claude/`, especially:

```text
docs/claude/project-context.md
docs/claude/done-definition.md
docs/claude/harness-profile.md
docs/claude/existing-project-install.md
docs/claude/general-scaffold-principles.md
```

Use skills for repeatable procedures that should load only when relevant, such as code review, legacy maintenance, Atlassian context lookup, Graphify usage, dependency fallback, and language server setup.

## Common Claude Skill Categories

Anthropic documents these broad skill categories:

- Anthropic skills: pre-built document creation skills for Excel, Word, PowerPoint, and PDF workflows.
- Partner skills: skills from partners such as Notion, Figma, and Atlassian for connector-oriented workflows.
- Organization-provisioned skills: skills deployed by Team or Enterprise administrators.
- Custom skills: user-created skills for specialized workflows such as Jira or Linear integration, brand guidelines, emails, or repeatable project procedures.

This harness does not copy Anthropic-provided or third-party skills into a project. It installs custom project skills for harness workflows only.

## References

- Claude Code skills: https://docs.claude.com/en/docs/claude-code/skills
- Claude skills overview: https://claude.com/docs/skills/overview
- Creating custom skills: https://claude.com/docs/skills/how-to
