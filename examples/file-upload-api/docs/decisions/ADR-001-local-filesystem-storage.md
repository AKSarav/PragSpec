# ADR-001: Local Filesystem over Object Storage

## Status
Accepted

## Context
The file upload API needs a place to persist uploaded file bytes. The two natural options were:

1. **Local filesystem** — files written to a configured directory on the same server
2. **Object storage** (S3, GCS, Azure Blob) — files pushed to a managed cloud storage service

Object storage is generally the production-grade choice for file persistence. However, this service
is in an early stage where:
- Deployment target is a single server (no horizontal scaling requirement yet)
- There is no cloud infrastructure provisioned or budgeted
- The team needs to iterate quickly without configuring IAM roles, bucket policies, or SDK credentials
- The risk of data loss from local storage is acceptable at this stage given the use case

## Decision
Use the **local filesystem** as the storage backend for v1. Files are written to a configurable
directory (`UPLOAD_DIR`, default `./uploads/`). All storage interactions go through a
`StorageBackend` protocol interface so the implementation is swappable.

## Consequences

**Enables:**
- Zero external dependencies — the service runs with no cloud account or credentials
- Simpler local development and testing (`tmp_path` fixture, no mocking of S3 clients)
- Faster v1 delivery

**Constrains:**
- The service cannot scale horizontally — multiple instances would not share the same
  filesystem, causing inconsistent reads
- File data is at risk if the server disk fails and no backup is in place
- Migrating to object storage later requires a data migration script (move files + update
  `stored_filename` records) — the `StorageBackend` protocol makes the code change trivial
  but the data migration is a one-time operational task

**Future path:**
When horizontal scaling or high-availability is required, replace `local_storage.py` with
an `s3_storage.py` implementation of the `StorageBackend` protocol. This ADR should be
superseded at that point.
