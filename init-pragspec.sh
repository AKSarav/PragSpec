#!/usr/bin/env bash
# init-pragspec.sh — Scaffold a PragSpec directory structure in any project
# Usage: ./init-pragspec.sh [project-name]
#
# Creates a pragspec/ directory — the single source of truth for what the
# system is, how it is built, and why decisions were made.

set -euo pipefail

PROJECT="${1:-my-project}"
ROOT="pragspec"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()   { echo -e "  ${CYAN}created${RESET}  $1"; }
skip()  { echo -e "  ${CYAN}skipped${RESET}  $1 (already exists)"; }
done_() { echo -e "${GREEN}✓${RESET} $1"; }

echo ""
echo -e "  ${BOLD}PragSpec${RESET} — scaffolding for: ${BOLD}$PROJECT${RESET}"
echo "  ────────────────────────────────────────"
echo ""

# ── Directories ───────────────────────────────────────────────────────────────

for dir in \
  "$ROOT/architecture" \
  "$ROOT/features" \
  "$ROOT/decisions" \
  "$ROOT/standards"; do
  mkdir -p "$dir"
  log "$dir/"
done
echo ""

# ── Helper: write only if the file doesn't already exist ─────────────────────

write_if_new() {
  local path="$1"
  local content="$2"
  if [ -f "$path" ]; then
    skip "$path"
  else
    printf '%s\n' "$content" > "$path"
    log "$path"
  fi
}

# ── pragspec/spec.md — Functional Spec + Index ────────────────────────────────

write_if_new "$ROOT/spec.md" "# $PROJECT — Spec

> **Agent entry point.** Read this file first, then \`architecture/overview.md\`,
> then all enforced standards, then the target feature file.

## Purpose
<!-- One sentence: what this system does and for whom -->

## Users
<!-- Who uses this system and in what context -->

## Core Capabilities
<!-- Numbered list of what the system can do at a high level -->

1.

## Non-Functional Requirements
<!-- Performance, availability, compliance, scale expectations -->

## Active Features

| Feature | Status |
|---|---|
| _(none yet)_ | — |

## Enforced Standards

| File | Scope |
|---|---|
| standards/coding.md | all |
| standards/error-model.md | api |

## Architecture
See [architecture/overview.md](architecture/overview.md) for the technical spec.
"

# ── pragspec/architecture/overview.md — Technical Spec ───────────────────────

write_if_new "$ROOT/architecture/overview.md" "# Technical Spec

## Tech Stack

<!-- List language versions, frameworks, databases, infra -->

| Layer | Choice | Version |
|---|---|---|
| Language | | |
| Framework | | |
| Database | | |
| Infrastructure | | |

## System Design
<!-- Key architectural patterns and how components fit together.
     3-5 sentences maximum. If a decision needs explanation, write an ADR. -->

## Integration Points
<!-- External systems, APIs, or services this project depends on.
     If none, write 'None at this stage.' -->

## Constraints
<!-- Hard limits: performance SLAs, compliance requirements, platform limits,
     scale targets, or anything an agent must treat as non-negotiable -->
"

# ── pragspec/standards/coding.md ─────────────────────────────────────────────

write_if_new "$ROOT/standards/coding.md" "---
enforced: true
applies-to: [all]
---

# Coding Standards

<!-- Hard constraints the agent must follow during code generation.
     Fill in for your language and framework. -->

## Language
<!-- e.g. Python 3.11+, TypeScript 5.x, Go 1.22 -->

## Style
<!-- Formatter, linter, line length, naming conventions -->

## Structure
<!-- Module layout, file naming, layering rules -->

## Testing
<!-- Framework, coverage threshold, what must be tested -->

## Dependencies
<!-- How to add dependencies, banned packages, version pinning policy -->
"

# ── pragspec/standards/error-model.md ────────────────────────────────────────

write_if_new "$ROOT/standards/error-model.md" "---
enforced: true
applies-to: [api]
---

# Error Model

All API error responses must follow this structure. No exceptions.

\`\`\`json
{
  \"error\": {
    \"code\": \"SNAKE_CASE_CODE\",
    \"message\": \"Human-readable description.\",
    \"details\": {}
  }
}
\`\`\`

## HTTP Status Mapping

| Situation | Status |
|---|---|
| Invalid input | 400 |
| Unauthenticated | 401 |
| Forbidden | 403 |
| Resource not found | 404 |
| Conflict / duplicate | 409 |
| Unexpected server error | 500 |

## Rules
- Never expose stack traces or internal paths in error responses
- \`code\` is a stable string identifier — clients branch logic on this, not on \`message\`
- \`message\` is human-readable, not machine-parseable
- \`details\` is optional; use it for field-level validation errors
"

# ── pragspec/standards/api-versioning.md ─────────────────────────────────────

write_if_new "$ROOT/standards/api-versioning.md" "---
enforced: true
applies-to: [api]
---

# API Versioning

## Strategy
<!-- e.g. URL prefix (/v1/), header-based, query param -->

## Current Version
<!-- e.g. v1 -->

## Rules
- Every route must include the version prefix explicitly — no implicit defaults
- Breaking changes require a new version prefix
- Deprecated endpoints must be supported for a minimum of two release cycles
"

# ── pragspec/features/.feature-template.md ───────────────────────────────────

write_if_new "$ROOT/features/.feature-template.md" "---
status: draft
---

# Feature Name

## Functional

### Why
<!-- Problem statement and motivation. Why does this need to exist? -->

### What
<!-- Behavior, scope, and acceptance criteria.
     Be specific enough that an agent can implement without asking questions. -->

### Out of Scope
<!-- Explicit exclusions. Prevents scope creep during implementation. -->

## Technical

### Data Model
<!-- Key entities, fields, and relationships.
     Only include if the feature introduces or modifies persistent data. -->

### API Contract
<!-- Endpoints, request/response shapes, status codes, error codes.
     Reference standards/error-model.md for error shape. -->

### Implementation Notes
<!-- Constraints, patterns, or non-obvious choices the agent must follow. -->

## Open Questions
<!-- Anything unresolved that would block a correct implementation.
     Resolve all of these before setting status: ready -->
"

# ── pragspec/decisions/.adr-template.md ──────────────────────────────────────

write_if_new "$ROOT/decisions/.adr-template.md" "# ADR-NNN: Title

## Status
Draft | Accepted | Superseded by ADR-NNN | Deprecated

## Context
<!-- What situation, constraint, or question forced this decision? -->

## Decision
<!-- What was decided. Be direct. -->

## Consequences
<!-- What this enables. What it constrains or closes off.
     What future teams or agents need to know as a result. -->
"

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
done_ "PragSpec scaffolded in ./$ROOT/"
echo ""
echo "  Next steps:"
echo "  1. Fill in pragspec/spec.md     — purpose, users, capabilities"
echo "  2. Fill in architecture/overview.md — tech stack, system design"
echo "  3. Update standards/coding.md   — conventions for your language"
echo "  4. cp features/.feature-template.md features/your-feature.md"
echo "  5. Build"
echo ""
