---
enforced: true
applies-to: [all]
---

# Coding Standards

## Language
Python 3.11+. No compatibility shims for older versions.

## Style
- Formatter: **Black** (line length 88). All code must pass `black --check` before commit.
- Linter: **Ruff** with default ruleset.
- Type hints: **required on all function signatures** — parameters and return types.
  Use `from __future__ import annotations` at the top of every module.
- No `type: ignore` comments unless accompanied by an explanatory comment.

## Naming Conventions
- Modules and packages: `snake_case`
- Classes: `PascalCase`
- Functions and variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Pydantic models: suffix with `Request`, `Response`, or `Model` (e.g. `UploadResponse`)

## Project Structure
```
src/
  main.py              ← FastAPI app factory and router registration
  routers/
    files.py           ← /v1/files route handlers (thin, delegate to services)
  services/
    file_service.py    ← business logic, no HTTP concerns
  models/
    file_model.py      ← SQLAlchemy ORM model
  schemas/
    file_schema.py     ← Pydantic request/response schemas
  storage/
    local_storage.py   ← filesystem abstraction (StorageBackend protocol)
  config.py            ← settings via pydantic-settings
  database.py          ← async SQLAlchemy engine and session factory
tests/
  conftest.py
  test_files.py
```

## Layering Rules
- Routers must not contain business logic. They validate input, call a service, and return a response.
- Services must not import from `routers/` or use FastAPI types (`Request`, `Response`).
- Storage layer must be accessed only through the `StorageBackend` protocol — never imported directly
  in routers or services.

## Error Handling
- All expected errors must use the error model defined in `standards/error-model.md`.
- Never let unhandled exceptions surface to the client. Use a global exception handler in `main.py`.
- Log unexpected errors with `structlog` at `error` level including a traceback.

## Testing
- Framework: **pytest** with **httpx** async client.
- Coverage threshold: **80%** minimum on `src/`.
- Every API endpoint must have at least: a success case test and a validation-error test.
- Use `tmp_path` pytest fixture for filesystem-dependent tests — never write to `./uploads/` in tests.

## Dependencies
- Manage with **pip + requirements.txt** (or pyproject.toml if using a build tool).
- Pin exact versions in `requirements.txt`. Use `pip-compile` to generate it.
- No unused dependencies. Each dependency must map to a concrete usage.
