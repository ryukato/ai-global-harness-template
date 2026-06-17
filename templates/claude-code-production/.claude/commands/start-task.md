# start-task

Use this command to initialize a task workspace.

## Prompt

Create a task workspace under:

```text
.ai-workspace/active/<TASK-ID>/
```

Use the template from:

```text
.ai-workspace/templates/TASK-000-template/
```

Populate:

- `task.md`
- `context/jira.md` if Jira is used
- `context/domain-summary.md` if domain behavior is affected
- `context/architecture-summary.md` if architecture is affected

Then identify which agent outputs are required.
