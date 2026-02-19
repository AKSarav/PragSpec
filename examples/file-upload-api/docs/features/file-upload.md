---
status: ready
---

# File Upload

## Why
Applications that need to handle user-generated files (documents, images, attachments)
require a reliable, consistent way to upload, store, retrieve, and delete those files.
This feature provides the core CRUD surface for file management as a REST API.

## What

### Endpoints

#### `POST /v1/files` — Upload a file
- Accepts `multipart/form-data` with a single `file` field.
- Validates:
  - File size must not exceed **50 MB**. Return `FILE_TOO_LARGE` (400) if exceeded.
  - MIME type must be in the configured allowed list. Return `UNSUPPORTED_MIME_TYPE` (400) if not.
- On success:
  - Saves the file to local storage as `{uuid4}{original_extension}`.
  - Persists metadata to SQLite: `id`, `original_filename`, `stored_filename`, `mime_type`,
    `size_bytes`, `uploaded_at`.
  - Returns **201** with the file metadata response body.

**Response body (201):**
```json
{
  "id": "a1b2c3d4-...",
  "original_filename": "report.pdf",
  "mime_type": "application/pdf",
  "size_bytes": 204800,
  "uploaded_at": "2026-02-20T10:00:00Z"
}
```

---

#### `GET /v1/files/{file_id}` — Get file metadata
- Returns metadata for the given file ID.
- `file_id` must be a valid UUID4. Return `INVALID_FILE_ID` (400) if not.
- Return `FILE_NOT_FOUND` (404) if no record exists with that ID.
- Returns **200** with the same metadata response shape as upload.

---

#### `GET /v1/files/{file_id}/download` — Download file content
- Streams the file back to the client.
- Sets `Content-Disposition: attachment; filename="{original_filename}"`.
- Sets `Content-Type` to the stored MIME type.
- `file_id` validation and not-found handling same as above.
- Returns **200** with file bytes as the response body.

---

#### `DELETE /v1/files/{file_id}` — Delete a file
- Deletes the file from the filesystem and removes the metadata record from SQLite.
- `file_id` validation and not-found handling same as above.
- Returns **204 No Content** on success.
- If the metadata record exists but the file is missing from disk, log the inconsistency
  at `warning` level, delete the metadata record, and still return **204**.

---

### Accepted MIME Types (default)
Configurable via `ALLOWED_MIME_TYPES` environment variable (comma-separated).
Default allowed set:

```
image/jpeg, image/png, image/gif, image/webp,
application/pdf,
text/plain, text/csv,
application/vnd.openxmlformats-officedocument.wordprocessingml.document,
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
```

---

## Data Model

### `files` table (SQLite)

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT (UUID4) | Primary key |
| `original_filename` | TEXT | As provided by the client |
| `stored_filename` | TEXT | `{uuid4}{ext}` on disk |
| `mime_type` | TEXT | Validated MIME type |
| `size_bytes` | INTEGER | File size in bytes |
| `uploaded_at` | DATETIME | UTC, set at insert time |

### Filesystem layout
```
uploads/
  a1b2c3d4-e5f6-...-pdf
  b2c3d4e5-f6a1-...-png
```

Storage root is configurable via `UPLOAD_DIR` env var. Defaults to `./uploads/`.

---

## Out of Scope
- Authentication and authorization — all endpoints are open in v1
- Multi-file batch upload in a single request
- File versioning / update (overwrite)
- Virus / malware scanning
- Image thumbnail generation
- Cloud/object storage (S3, GCS) — see ADR-001 for why this is deferred
- Pagination on a list-files endpoint — list endpoint is not in v1

---

## Open Questions
- _(none — all questions resolved before status was set to ready)_
