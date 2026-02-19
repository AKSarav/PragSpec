---
enforced: true
applies-to: [api]
---

# API Versioning

## Strategy
URL prefix versioning: all routes are prefixed with `/v{N}`.

## Current Version
`v1` — all routes live under `/v1/`.

## Rules
- Every route definition must include the version prefix explicitly. No implicit defaults.
- Breaking changes (removed fields, changed response shape, removed endpoints) require a new
  version prefix (`/v2/`).
- Additive changes (new optional fields, new endpoints) do not require a version bump.
- When a new version is introduced, the previous version must remain functional for a minimum
  of **two release cycles** before deprecation.
- Deprecated endpoints must return a `Deprecation` response header with the sunset date.

## Example

```
POST   /v1/files
GET    /v1/files/{file_id}
GET    /v1/files/{file_id}/download
DELETE /v1/files/{file_id}
```
