# AI Artifact Archive Policy Draft v1

## 1. Purpose

The purpose of this policy is to preserve AI-assisted development artifacts while preventing uncontrolled repository growth.

AI artifacts are useful because they record:

- task interpretation
- explored code paths
- architecture decisions
- implementation notes
- review findings
- final verification

However, detailed artifacts should not remain in the active repository forever.

---

## 2. Scope

This policy applies to:

```text
.ai-workspace/active/**
.ai-workspace/completed/**
.ai-workspace/archive-index/**
```

It does not replace source code, tests, ADRs, or product documentation.

---

## 3. Workspace Lifecycle

```text
active task
  -> completed summary
  -> release/tag archive
  -> repository cleanup
  -> archive index
```

### Active

Detailed task folders live here while work is ongoing:

```text
.ai-workspace/active/<TASK-ID>/
```

### Completed

After implementation/review, create a compact summary:

```text
.ai-workspace/completed/<TASK-ID>.md
```

### Archived

At release/tag time, detailed active folders are compressed and uploaded to long-term storage.

### Indexed

The repository keeps a release-level archive index:

```text
.ai-workspace/archive-index/releases/<VERSION>.md
```

---

## 4. Archive Trigger

Recommended triggers:

- Git tag matching `v*`
- GitHub Release published

Optional triggers:

- monthly schedule
- quarterly schedule
- manual workflow dispatch

Release/tag based archiving is preferred because it preserves the AI artifacts for the same code snapshot that was released.

---

## 5. Archive Contents

Archive package should include:

```text
.ai-workspace/active/**
.ai-workspace/templates/**
.ai-workspace/completed/**
.ai-workspace/archive-index/**
work-items/**
docs/architecture/**
docs/domain/**
docs/decisions/**
docs/operations/**
CLAUDE.md
AGENTS.md
HARNESS-GUIDE.md
```

Include only what is useful to reconstruct the work context.

---

## 6. Long-Term Storage

Recommended storage:

```text
s3://ai-artifact-archive/<repository>/releases/<version>/ai-workspace-<version>.zip
```

Alternative storage:

- shared drive
- internal artifact repository
- GitHub Actions artifact for short-term retention only

GitHub Actions artifacts should be treated as short-term storage.
Use S3 or equivalent for long-term retention.

---

## 7. Repository Cleanup Policy

After successful archive:

Keep:

```text
.ai-workspace/completed/<TASK-ID>.md
.ai-workspace/archive-index/releases/<VERSION>.md
```

Remove or move:

```text
.ai-workspace/active/<TASK-ID>/
```

Do not delete active task folders before archive upload succeeds.

---

## 8. Retention Draft

Suggested defaults:

| Artifact | Location | Retention |
|---|---|---|
| active task folders | repository | current release cycle |
| completed summaries | repository | 12~24 months or project lifetime |
| release archive zip | S3/shared storage | 3~7 years |
| GitHub workflow artifact | GitHub Actions | 30~90 days |

Adjust based on legal, audit, and company policy.

---

## 9. Security / Confidentiality

Before archiving:

- Do not include secrets.
- Do not include access tokens.
- Do not include private customer data unless explicitly approved.
- Redact sensitive logs.
- Prefer links or summarized evidence over raw sensitive payloads.

---

## 10. Recovery

An archive must allow a team member to understand:

- what task was performed
- what context was used
- what agents produced
- what decisions were made
- what code/release it relates to
