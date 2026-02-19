---
enforced: true
applies-to: [api]
---

# Error Model

All API error responses must follow this structure. No exceptions.

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
| `VALIDATION_ERROR` | 400 | Request body or query params failed schema validation |
| `UNAUTHORIZED` | 401 | Missing, malformed, or expired JWT |
| `INVALID_CREDENTIALS` | 401 | Wrong email or password during login |
| `EMAIL_ALREADY_EXISTS` | 409 | Registration attempted with an already-registered email |
| `TASK_NOT_FOUND` | 404 | Task doesn't exist or belongs to another user |
| `INTERNAL_ERROR` | 500 | Unexpected server-side error |

## HTTP Status Mapping

| Situation | Status |
|---|---|
| Schema / input validation failure | 400 |
| Missing or invalid auth token | 401 |
| Wrong credentials | 401 |
| Resource not found (or ownership mismatch) | 404 |
| Duplicate unique resource | 409 |
| Unexpected server error | 500 |

## Rules
- Never expose stack traces, SQL queries, or internal paths in error responses
- `code` is a stable string — clients branch logic on this, not on `message`
- `message` is for humans and logging, not for programmatic use
- `details` is optional; use it for field-level Zod validation errors
- Ownership mismatches return **404**, not 403 — do not reveal that a resource exists but is forbidden
- Login failures always return `INVALID_CREDENTIALS` regardless of whether the email exists — no user enumeration

## `details` Shape for Validation Errors

When returning `VALIDATION_ERROR`, populate `details` with Zod's formatted error output:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed.",
    "details": {
      "title": ["Required"],
      "dueDate": ["Invalid date format"]
    }
  }
}
```
