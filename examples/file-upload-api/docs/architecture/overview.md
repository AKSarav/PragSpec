# Architecture Overview

## Purpose
A lightweight REST API for file management — upload, retrieve metadata, download, and delete files.
Primary users are developer-clients integrating file handling into their applications.

## System Context
Standalone service. No external service dependencies at this stage.
Clients communicate via HTTP. No authentication provider is integrated yet —
auth is out of scope for the initial version (see `features/file-upload.md` Out of Scope).

## Tech Stack

| Layer | Choice |
|---|---|
| Language | Python 3.11 |
| Framework | FastAPI 0.110 |
| Validation | Pydantic v2 |
| Metadata store | SQLite via SQLAlchemy (async) |
| File storage | Local filesystem under `./uploads/` |
| Test framework | pytest + httpx (async client) |

## Key Design Choices

- **FastAPI** chosen for automatic OpenAPI generation, Pydantic integration, and async support
  without the overhead of Django or Flask.
- **SQLite** for metadata (filename, size, mime-type, upload timestamp, unique ID) keeps the
  service self-contained with no external database dependency for this stage.
- **Local filesystem** for file storage. See [ADR-001](../decisions/ADR-001-local-filesystem-storage.md)
  for the tradeoff decision.
- Files are stored as `{uuid4}{original_extension}` on disk; the original filename is persisted
  in the metadata store only. This prevents filename collisions and path traversal attacks.

## Constraints
- Maximum file size: **50 MB** per upload
- Accepted mime types: configurable via `ALLOWED_MIME_TYPES` env var; defaults to common document
  and image types
- No authentication in v1 — all endpoints are open (intended for internal/trusted network use)
- Single-node only — local filesystem storage means no horizontal scaling without a storage migration
