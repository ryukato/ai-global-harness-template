# Python uv Profile

## Python Rules

- Use `.venv` for virtual environments when creating one.
- Keep dependency changes in `pyproject.toml` and `uv.lock`.
- Do not edit `.venv/`, `__pycache__/`, `.pytest_cache/`, `.mypy_cache/`, or `.ruff_cache/`.
- Prefer typed function signatures for public functions.
- Keep DB session and transaction boundaries explicit.
- Avoid broad formatting-only changes.

## Common Commands

```bash
uv sync
uv run ruff check .
uv run pytest
```

If mypy is configured:

```bash
uv run mypy .
```
