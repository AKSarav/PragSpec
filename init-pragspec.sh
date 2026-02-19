#!/usr/bin/env bash
# init-pragspec.sh — Scaffold a PragSpec /docs structure in any project
# Usage: ./init-pragspec.sh [project-name]

set -euo pipefail

PROJECT="${1:-my-project}"
DOCS="docs"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

log()  { echo -e "${CYAN}  $1${RESET}"; }
done_() { echo -e "${GREEN}✓ $1${RESET}"; }

echo ""
echo "  PragSpec — scaffolding docs for: $PROJECT"
echo "  ─────────────────────────────────────────"
echo ""

# ── Directories ──────────────────────────────────────────────────────────────

for dir in \
  "$DOCS/architecture" \
  "$DOCS/features" \
  "$DOCS/decisions" \
  "$DOCS/standards"; do
  mkdir -p "$dir"
  log "created $dir/"
done

# ── Helper: write file only if it doesn't already exist ──────────────────────

write_if_new() {
  local path="$1"
  local content="$2"
  if [ -f "$path" ]; then
    log "skipped  $path (already exists)"
  else
    echo "$content" > "$path"
    done_ "created  $path"
  fi
}

# ── docs/README.md ────────────────────────────────────────────────────────────

write_if_new "$DOCS/README.md" "# $PROJECT — Spec Index

> **Agent entry point.** Read this file first, then architecture/overview.md,
> then all enforced standards, then the target feature file.

## Project
<!-- One sentence: what this system does and for whom -->

## Tech Stack
<!-- Language, framework, database, infra -->

## Active Features

| Feature | Status |
|---|---|
| _(none yet)_ | — |

## Enforced Standards

| File | Scope |
|---|---|
| standards/coding.md | all |
| standards/error-model.md | api |

## Architecture Files
- [overview.md](architecture/overview.md)

## Decisions
- _(none yet)_
"

# ── docs/architecture/overview.md ────────────────────────────────────────────

write_if_new "$DOCS/architecture/overview.md" "# Architecture Overview

## Purpose
<!-- What problem does this system solve? Who uses it? -->

## System Context
<!-- Where does this fit in the broader ecosystem? What does it depend on? -->

## Tech Stack
<!-- List language versions, frameworks, databases, infra -->

## Key Design Choices
<!-- 3-5 sentences on the most important architectural decisions.
     If a decision needs explanation, write an ADR and reference it here. -->

## Constraints
<!-- Hard limits: performance SLAs, compliance requirements, platform limits -->
"

# ── docs/architecture/principles.md ──────────────────────────────────────────

write_if_new "$DOCS/architecture/principles.md" "# Engineering Principles

<!-- List 4-6 principles this project commits to.
     These inform tradeoffs when the spec is ambiguous. -->

- **Simplicity first** — prefer the straightforward solution unless there is a
  demonstrated need for complexity
- **Explicit over implicit** — make contracts, errors, and side effects visible
- **Standards enforced** — all standards/coding.md rules apply without exception
- **ADRs for non-obvious choices** — if a future developer would ask \"why did
  they do it this way?\", write an ADR
"

# ── docs/standards/coding.md ─────────────────────────────────────────────────

write_if_new "$DOCS/standards/coding.md" "---
enforced: true
applies-to: [all]
---

# Coding Standards

<!-- Fill in language/framework-specific conventions.
     These are hard constraints the agent must follow during code generation. -->

## Language
<!-- e.g. Python 3.11+, TypeScript 5.x -->

## Style
<!-- e.g. Black formatter, ESLint config, line length, naming conventions -->

## Structure
<!-- e.g. module layout, file naming, layering rules -->

## Testing
<!-- e.g. pytest, coverage threshold, what must be tested -->

## Dependencies
<!-- e.g. how to add dependencies, banned packages, version pinning policy -->
"

# ── docs/standards/error-model.md ────────────────────────────────────────────

write_if_new "$DOCS/standards/error-model.md" "---
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
- \`code\` must be a stable string identifier (used by clients for logic branching)
- \`message\` is for humans, not machines
- \`details\` is optional, used for field-level validation errors
"

# ── docs/standards/api-versioning.md ─────────────────────────────────────────

write_if_new "$DOCS/standards/api-versioning.md" "---
enforced: true
applies-to: [api]
---

# API Versioning

## Strategy
<!-- e.g. URL prefix (/v1/), header-based, query param -->

## Current Version
<!-- e.g. v1 -->

## Rules
- Breaking changes require a new version prefix
- Deprecated endpoints must be supported for [N] release cycles
- Version must be explicit in all route definitions — no implicit defaults
"

# ── Feature template hint ─────────────────────────────────────────────────────

write_if_new "$DOCS/features/.feature-template.md" "---
status: draft
---

# Feature Name

## Why
<!-- Problem statement and motivation. Why does this need to exist? -->

## What
<!-- Behavior, scope, and acceptance criteria.
     Use a bullet list or numbered steps. Be specific enough that
     an agent can implement it without asking clarifying questions. -->

## Data Model
<!-- Optional. Key entities, fields, and relationships.
     Only include if the feature introduces or modifies persistent data. -->

## Out of Scope
<!-- Explicit exclusions. Prevents scope creep during implementation. -->

## Open Questions
<!-- Anything unresolved that would block a correct implementation.
     Resolve these before setting status: ready -->
"

# ── ADR template hint ─────────────────────────────────────────────────────────

write_if_new "$DOCS/decisions/.adr-template.md" "# ADR-NNN: Title

## Status
Draft | Accepted | Superseded by ADR-NNN | Deprecated

## Context
<!-- What situation, constraint, or question forced this decision? -->

## Decision
<!-- What was decided. Be direct. -->

## Consequences
<!-- What this enables. What it constrains or closes off.
     What future teams need to know as a result. -->
"

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}  PragSpec scaffolded in ./$DOCS/${RESET}"
echo ""
echo "  Next steps:"
echo "  1. Fill in docs/README.md — project name, tech stack"
echo "  2. Fill in docs/architecture/overview.md"
echo "  3. Update docs/standards/coding.md for your language"
echo "  4. Copy .feature-template.md → features/your-feature.md"
echo "  5. Start building"
echo ""
