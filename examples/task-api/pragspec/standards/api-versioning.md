---
enforced: true
applies-to: [api]
---

# API Versioning

## Strategy
URL prefix versioning. All routes are prefixed with `/v{N}`.

## Current Version
`v1` — all routes live under `/v1/`.

## Rules
- Every route definition must include the version prefix explicitly. No implicit defaults.
- Breaking changes (removed or renamed fields, changed response shapes, removed endpoints) require a new version prefix (`/v2/`).
- Additive changes (new optional fields, new endpoints) do not require a version bump.
- When a new version is introduced, the previous version must remain functional for a minimum of **two release cycles**.
- Deprecated endpoints must return a `Deprecation` response header with the sunset date.

## Route Overview

```
POST   /v1/auth/register
POST   /v1/auth/login

GET    /v1/users/me

POST   /v1/tasks
GET    /v1/tasks
PATCH  /v1/tasks/:id
DELETE /v1/tasks/:id
```
