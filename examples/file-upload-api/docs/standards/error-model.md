---
enforced: true
applies-to: [api]
---

# Error Model

All API error responses must use this structure. No exceptions.

```json
{
  "error": {
    "code": "SNAKE_CASE_CODE",
    "message": "Human-readable description.",
    "details": {}
  }
}
```

## Error Codes Used in This API

| Code | Status | Meaning |
|---|---|---|
| `FILE_TOO_LARGE` | 400 | Upload exceeds the 50 MB limit |
| `UNSUPPORTED_MIME_TYPE` | 400 | File type not in the allowed list |
| `INVALID_FILE_ID` | 400 | Provided file ID is not a valid UUID |
| `FILE_NOT_FOUND` | 404 | No file exists with the given ID |
| `STORAGE_ERROR` | 500 | Filesystem write/read/delete failed |
| `INTERNAL_ERROR` | 500 | Unexpected server-side error |

## HTTP Status Mapping

| Situation | Status |
|---|---|
| Invalid input / constraint violation | 400 |
| Resource not found | 404 |
| Filesystem or storage failure | 500 |
| Unexpected server error | 500 |

## Rules
- Never expose stack traces, internal paths, or filesystem details in error responses.
- `code` is a stable string identifier — clients branch logic on this, not on `message`.
- `message` is human-readable, suitable for logging or display.
- `details` is optional. Use it for field-level validation errors (e.g. from Pydantic).
- The global exception handler in `main.py` must catch all unhandled exceptions and
  return `INTERNAL_ERROR` with status 500.
