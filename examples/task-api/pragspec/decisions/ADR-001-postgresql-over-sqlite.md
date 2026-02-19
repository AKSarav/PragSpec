# ADR-001: PostgreSQL over SQLite

## Status
Accepted

## Context
The service needs a relational database to store users and tasks with a foreign key
relationship (`tasks.userId` → `users.id`). Two options were considered:

1. **SQLite** — embedded, zero infrastructure, single file
2. **PostgreSQL** — full relational database, requires a running server

The file-upload API example (in this repository) chose SQLite because it was a single-entity,
single-user service with no relational concerns. The task API is different:

- **Two entities with a relationship** — users own tasks; cascading deletes must be enforced at the DB level, not the application level
- **Concurrent writes** — multiple users writing tasks simultaneously; SQLite's write-lock model is unsuitable for any real concurrency
- **Future growth** — filtering, indexing, and querying tasks by user + status at scale benefits from PostgreSQL's query planner and indexing capabilities
- **Prisma support** — Prisma has first-class PostgreSQL support; switching from SQLite to PostgreSQL later requires a schema migration and data migration, not just a config change

## Decision
Use **PostgreSQL 16** as the database. It is provisioned as a Docker container for local
development and as a managed instance (e.g. RDS, Supabase) in production.

## Consequences

**Enables:**
- Proper FK constraints and cascade deletes enforced at the database level
- Concurrent multi-user writes without serialization bottlenecks
- Efficient indexed queries on `(userId, status)` and `(userId, createdAt)` as the task list grows
- Production-grade durability and point-in-time recovery options

**Constrains:**
- Local development requires Docker (or a local Postgres installation) — no zero-dependency setup
- CI pipeline must provision a Postgres instance for test runs
- Connection string management via `DATABASE_URL` env var is required in all environments

**Mitigation:**
A `docker-compose.yml` should be provided in the repository root to make local Postgres
setup a single `docker compose up -d` command.
