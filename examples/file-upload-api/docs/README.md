# File Upload API — Spec Index

> **Agent entry point.** Read this file first, then `architecture/overview.md`,
> then all enforced standards, then the target feature file.

## Project
A REST API that allows authenticated users to upload, retrieve, and delete files.
Built with Python + FastAPI. Files stored on the local filesystem (see ADR-001 for why not S3).

## Tech Stack
- Python 3.11
- FastAPI 0.110
- Pydantic v2
- SQLite (metadata store)
- Local filesystem (file storage)
- pytest + httpx (testing)

## Active Features

| Feature | Status |
|---|---|
| [file-upload.md](features/file-upload.md) | ready |

## Enforced Standards

| File | Scope |
|---|---|
| [standards/coding.md](standards/coding.md) | all |
| [standards/error-model.md](standards/error-model.md) | api |
| [standards/api-versioning.md](standards/api-versioning.md) | api |

## Architecture Files
- [architecture/overview.md](architecture/overview.md)

## Decisions
- [ADR-001: Local Filesystem over Object Storage](decisions/ADR-001-local-filesystem-storage.md)
