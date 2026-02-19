# File Upload API — Spec

> **Agent entry point.** Read this file first, then `architecture/overview.md`,
> then all enforced standards, then the target feature file.

## Purpose
A REST API that allows clients to upload, retrieve, download, and delete files.
Intended for internal or trusted-network use where applications need a simple,
self-contained file management service.

## Users
- **API clients** — developer-built applications that need file handling without
  building their own storage layer
- **Developers** — integrating the service into a broader application stack

## Core Capabilities

1. Upload a file (multipart/form-data) and receive a unique file ID
2. Retrieve file metadata by ID (filename, size, type, upload timestamp)
3. Download the original file content by ID
4. Delete a file and its metadata by ID

## Non-Functional Requirements

- Maximum file size: **50 MB** per upload
- Accepted MIME types: configurable via env var, defaults to common document and image types
- No authentication in v1 — all endpoints are open (internal/trusted network only)
- Single-node deployment — no horizontal scaling requirement at this stage
- Response time: < 200ms for metadata operations; streaming for file download/upload

## Active Features

| Feature | Status |
|---|---|
| [features/file-upload.md](features/file-upload.md) | ready |

## Enforced Standards

| File | Scope |
|---|---|
| [standards/coding.md](standards/coding.md) | all |
| [standards/error-model.md](standards/error-model.md) | api |
| [standards/api-versioning.md](standards/api-versioning.md) | api |

## Architecture
See [architecture/overview.md](architecture/overview.md) for the technical spec.

## Decisions
- [ADR-001: Local Filesystem over Object Storage](decisions/ADR-001-local-filesystem-storage.md)
