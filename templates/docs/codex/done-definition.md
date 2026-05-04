# Definition of Done

A task is complete only when all applicable items are satisfied.

## Implementation

- Requested behavior is implemented.
- Change is limited to the task scope.
- No generated outputs were edited accidentally.
- No secrets or local-only files were added.
- Existing behavior is preserved unless the task explicitly changes it.

## Quality

- Types are explicit enough.
- Business logic is placed in the appropriate layer.
- Repeated semantic literals are extracted into constants.
- Error handling is intentional.
- Edge cases are considered.

## Verification

- `./scripts/codex/verify.sh` was run, or a clear reason was provided.
- Relevant app-level checks were run when available.
- Failing checks are reported honestly.

## Documentation

- Relevant docs were updated when behavior, setup, API, or domain rules changed.

## Final Report

The final report includes:

- Summary
- Files changed
- Commands run
- Verification result
- Risks or follow-up items
