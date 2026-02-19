# Technical Spec

## Tech Stack

| Layer | Choice | Version |
|---|---|---|
| Language | Python | 3.11 |
| Framework | FastAPI | 0.110 |
| Validation | Pydantic | v2 |
| Metadata store | SQLite via SQLAlchemy (async) | 2.x |
| File storage | Local filesystem | — |
| Test framework | pytest + httpx (async client) | latest stable |

## System Design

The service follows a layered architecture: thin route handlers → service layer → storage abstraction.

- **Routers** (`routers/files.py`) handle HTTP concerns only — parse input, call a service method, return a response. No business logic.
- **Services** (`services/file_service.py`) own all business logic — validation, metadata persistence, storage coordination. No FastAPI types.
- **Storage** (`storage/local_storage.py`) implements a `StorageBackend` protocol. This makes the storage layer swappable without changing the service. See ADR-001.
- **Models** (`models/file_model.py`) are SQLAlchemy ORM definitions. **Schemas** (`schemas/file_schema.py`) are Pydantic request/response shapes. These are kept strictly separate.

Files are stored on disk as `{uuid4}{original_extension}` to prevent filename collisions and path traversal. The original filename is stored in SQLite metadata only.

## Integration Points

None at this stage. The service is fully self-contained with no external dependencies.

## Constraints

- **50 MB** hard file size limit — enforced before writing to disk
- **MIME type allowlist** — configurable via `ALLOWED_MIME_TYPES` env var; requests outside the list are rejected with `UNSUPPORTED_MIME_TYPE`
- **Single-node only** — local filesystem storage means no horizontal scaling without a storage backend migration (see ADR-001)
- **No auth in v1** — the service is intended for trusted network environments only; exposing publicly requires adding an auth layer first
- **Upload directory** — configurable via `UPLOAD_DIR` env var, defaults to `./uploads/`; must be writable by the process
