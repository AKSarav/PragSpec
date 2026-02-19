---
status: ready
---

# File Upload

## Functional

### Why
Applications that handle user-generated content need a reliable, consistent way to
store and retrieve files without building their own storage layer. This feature
provides the core file management surface — upload, retrieve, download, delete —
as a clean REST API.

### What

1. A client sends a file via `POST /v1/files` (multipart/form-data).
2. The API validates the file size and MIME type, rejects it with a clear error if invalid.
3. On success, the file is stored and the client receives a unique file ID plus metadata.
4. The client can retrieve metadata at any time using the file ID.
5. The client can download the original file content using the file ID.
6. The client can permanently delete a file using the file ID.

**Acceptance criteria:**
- A valid file upload returns 201 with a unique ID and metadata
- An oversized file returns 400 with code `FILE_TOO_LARGE`
- A disallowed MIME type returns 400 with code `UNSUPPORTED_MIME_TYPE`
- Metadata retrieval returns the original filename, size, type, and upload timestamp
- File download streams the original content with correct `Content-Type` and `Content-Disposition`
- Deletion returns 204 and subsequent requests for that ID return 404
- An invalid UUID as file ID returns 400 with code `INVALID_FILE_ID`
- A valid but non-existent file ID returns 404 with code `FILE_NOT_FOUND`

### Out of Scope
- Authentication and authorization — all endpoints are open in v1
- Multi-file batch upload in a single request
- File versioning or overwrite
- Virus / malware scanning
- Image thumbnail generation
- Cloud/object storage (S3, GCS) — deferred, see ADR-001
- List / search files endpoint — not in v1
- File expiry / TTL

---

## Technical

### Data Model

**`files` table (SQLite)**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT (UUID4) | Primary key |
| `original_filename` | TEXT | As provided by the client |
| `stored_filename` | TEXT | `{uuid4}{ext}` on disk, never exposed to clients |
| `mime_type` | TEXT | Validated MIME type |
| `size_bytes` | INTEGER | File size in bytes |
| `uploaded_at` | DATETIME | UTC timestamp, set at insert |

**Filesystem layout**
```
uploads/
  a1b2c3d4-e5f6-7890-abcd-ef1234567890.pdf
  b2c3d4e5-f6a1-2345-bcde-f12345678901.png
```

### API Contract

All routes use prefix `/v1`. All error responses follow `standards/error-model.md`.

---

#### `POST /v1/files` — Upload

**Request:** `multipart/form-data`, field name `file`

**Validations (in order):**
1. File size ≤ 50 MB → else `FILE_TOO_LARGE` (400)
2. MIME type in allowed list → else `UNSUPPORTED_MIME_TYPE` (400)

**Response 201:**
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "original_filename": "report.pdf",
  "mime_type": "application/pdf",
  "size_bytes": 204800,
  "uploaded_at": "2026-02-20T10:00:00Z"
}
```

---

#### `GET /v1/files/{file_id}` — Get metadata

- `file_id` must be a valid UUID4 → else `INVALID_FILE_ID` (400)
- File must exist → else `FILE_NOT_FOUND` (404)

**Response 200:** same shape as upload response.

---

#### `GET /v1/files/{file_id}/download` — Download

- Same `file_id` validations as above
- Streams file bytes as response body
- Sets `Content-Disposition: attachment; filename="{original_filename}"`
- Sets `Content-Type` to the stored MIME type

**Response 200:** raw file bytes.

---

#### `DELETE /v1/files/{file_id}` — Delete

- Same `file_id` validations as above
- Deletes the physical file from disk and the metadata record from SQLite
- If metadata exists but the file is missing from disk: log `warning`, delete metadata record, return 204 (do not error)

**Response 204:** no body.

---

**Error codes used by this feature:**

| Code | Status | Trigger |
|---|---|---|
| `FILE_TOO_LARGE` | 400 | Upload exceeds 50 MB |
| `UNSUPPORTED_MIME_TYPE` | 400 | MIME type not in allowed list |
| `INVALID_FILE_ID` | 400 | `file_id` is not a valid UUID4 |
| `FILE_NOT_FOUND` | 404 | No file exists with the given ID |
| `STORAGE_ERROR` | 500 | Filesystem read/write/delete failed |

---

### Implementation Notes

- Use `python-multipart` for multipart parsing in FastAPI
- Read file size from `UploadFile.size` if available; otherwise stream and count bytes — do not buffer the entire file in memory before validation
- Use `python-magic` (libmagic binding) to validate MIME type from file content, not just the client-provided `content_type` header — clients can lie
- The `StorageBackend` protocol must be the only interface the service layer uses for filesystem operations; never call `open()` or `os.*` directly in `file_service.py`
- Use `asyncio`-compatible file I/O (`aiofiles`) for all disk reads and writes
- Wrap all storage operations in try/except and raise a domain-level `StorageError` — never let `OSError` or `IOError` surface to the router

---

## Open Questions
_(none — all questions resolved before status was set to ready)_
