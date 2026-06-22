# cawf:git

Use this command after implementation and review are complete to prepare commit and pull request work.

## Usage

```text
/project:cawf:git <TASK-ID or issue link>
```

## Prompt

Act as a version-control operator. Analyze completed changes and prepare commit/PR steps. Do not edit product code, run broad tests, merge PRs, or force push.

Inputs are supplied through `$ARGUMENTS`.

Preparation:

1. Read `git status --short`.
2. Read staged and unstaged diffs.
3. Check for secrets, credentials, private keys, `.env` contents, tokens, and accidental generated artifacts.
4. Identify the current branch with `git branch --show-current`.
5. Refuse direct commit or push on protected branches: `main`, `master`, `develop`, `release/*`.
6. Read `.github/commit_template.md` and `.github/pull_request_template.md` if present.
7. Use `.ai-workspace/active/<TASK-ID>/outputs/plan-v*.md`, `execute-v*.md`, and `review-v*.md` when available to understand the change.

Branch and commit standards:

1. Prefer branch names:
   - `feature/<ISSUE-ID>` for feature work.
   - `hotfix/<ISSUE-ID>` for urgent production fixes.
2. Keep each PR focused on one purpose.
3. If the diff is too large or mixes unrelated work, ask the user whether to split it.
4. Draft a commit message and PR body that follow repository templates when available.
5. Show the exact commit message and PR body before committing.
6. Wait for explicit user approval before running `git commit`, `git push`, or PR creation.

Execution after approval:

1. Stage only files that belong to this change.
2. Commit with the approved message.
3. Push the current branch without `--force`.
4. Create a PR if the GitHub CLI or GitHub connector is available.
5. Assign the PR to the detected local user when possible.
6. Do not merge the PR.

Review-loop handling:

1. For review feedback fixes, preserve the original PR title unless the user requests a change.
2. After responding to reviewer comments, request re-review when tooling is available.
3. If a merge or rebase conflict occurs, stop and ask for a resolution strategy.

Report:

```markdown
### Git Summary

1. Branch: `<branch>`
2. Commit: `<sha or pending>`
3. Push: `<remote/branch or pending>`
4. PR: `<url or pending>`
5. Notes: <risks, skipped steps, or required approvals>
```
