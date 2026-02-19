# Task API — Spec

> **Agent entry point.** Read this file first, then `architecture/overview.md`,
> then all enforced standards, then the target feature file.

## Purpose
A REST API for personal task management. Users register, authenticate, and manage
their own tasks. Each user can only see and modify their own data.

## Users
- **Registered users** — individuals managing a personal task list via a client application
- **API clients** — frontend apps or scripts integrating task management capabilities

## Core Capabilities

1. User self-registration with email and password
2. User login returning a JWT access token
3. Authenticated users can create tasks with a title, optional description, and due date
4. Authenticated users can list their own tasks, filtered by status
5. Authenticated users can update any field of their own tasks
6. Authenticated users can delete their own tasks

## Non-Functional Requirements

- All task endpoints require a valid JWT — unauthenticated requests return 401
- A user must never be able to read or modify another user's tasks
- JWT access tokens expire after **1 hour**
- Passwords must be hashed with bcrypt before storage — never stored in plaintext
- Response time: < 150ms for all operations under normal load
- No rate limiting in v1 (trusted network environment assumed)

## Active Features

| Feature | Status |
|---|---|
| [features/user-management.md](features/user-management.md) | ready |
| [features/task-management.md](features/task-management.md) | ready |

## Enforced Standards

| File | Scope |
|---|---|
| [standards/coding.md](standards/coding.md) | all |
| [standards/error-model.md](standards/error-model.md) | api |
| [standards/api-versioning.md](standards/api-versioning.md) | api |

## Architecture
See [architecture/overview.md](architecture/overview.md) for the technical spec.

## Decisions
- [ADR-001: PostgreSQL over SQLite](decisions/ADR-001-postgresql-over-sqlite.md)
- [ADR-002: Stateless JWT over Session-Based Auth](decisions/ADR-002-jwt-stateless-auth.md)
