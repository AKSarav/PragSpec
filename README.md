# PragSpec

**Pragmatic Spec Driven Development** — a lightweight framework for AI-assisted software delivery.


<p align="center">
<img src="PragSpec.png" alt="PragSpec Logo" width="600">
</p>

Any project containing a `pragspec/` directory is explicitly using this methodology.
That directory is the single source of truth for what the system is, how it is built, and why decisions were made — for both humans and AI agents.



## Why PragSpec

Modern AI coding agents work best when they have:

- A clear **entry point** to load as context before acting
- **Dense, single-file** units of work they can reason about atomically
- **Explicit constraints** they must not violate during generation
- **Traceable decisions** explaining *why* things are the way they are

Heavy SDD frameworks create cognitive overhead — for humans and agents alike. PragSpec strips it to the minimum that actually powers delivery.

---

## Directory Structure

```
pragspec/
├── spec.md                    ← Functional Spec + project index. Always read first.
├── architecture/
│   └── overview.md            ← Technical Spec: stack, design, constraints
├── features/
│   └── feature-name.md        ← One file per feature (functional + technical sections)
├── decisions/
│   └── ADR-001-title.md       ← Architecture Decision Records
└── standards/
    ├── coding.md              ← Language/style conventions (enforced)
    ├── error-model.md         ← Error response contract (enforced)
    └── api-versioning.md      ← Versioning strategy (enforced)
```

---

## Agent Interaction Model

Every agent session follows this read order:

1. **`pragspec/spec.md`** — functional scope, active features, enforced standards list
2. **`pragspec/architecture/overview.md`** — tech stack, system design, hard constraints
3. **`pragspec/standards/*.md`** where `enforced: true` — hard constraints for code generation
4. **Target `pragspec/features/feature-name.md`** — the specific unit of work

This sequence ensures the agent has complete ground truth before touching code.

---

## `spec.md` — Functional Spec

The project-level functional specification and entry point index.

```markdown
# Project Name — Spec

## Purpose
What the system does and for whom.

## Users
Who uses this system and in what context.

## Core Capabilities
Numbered list of what the system can do at a high level.

## Non-Functional Requirements
Performance, availability, compliance, scale expectations.

## Active Features

| Feature | Status |
|---|---|
| features/feature-name.md | ready |

## Enforced Standards

| File | Scope |
|---|---|
| standards/coding.md | all |
| standards/error-model.md | api |
```

---

## `architecture/overview.md` — Technical Spec

The project-level technical specification.

```markdown
# Technical Spec

## Tech Stack
Language, framework, database, infra — with version pins.

## System Design
Key architectural patterns and how components fit together.

## Integration Points
External systems, APIs, or services this project depends on.

## Constraints
Hard limits: performance SLAs, compliance, platform restrictions.
```

---

## Feature File Format

Every feature file contains both a functional and technical view in one place.

```markdown
---
status: draft | ready | in-progress | done
---

# Feature Name

## Functional

### Why
Problem statement and motivation.

### What
Behavior, scope, and acceptance criteria.

### Out of Scope
Explicit exclusions to prevent scope creep.

## Technical

### Data Model
Key entities, fields, and relationships.

### API Contract
Endpoints, request/response shapes, error codes.

### Implementation Notes
Constraints, patterns, or non-obvious choices the agent must follow.

## Open Questions
Unresolved decisions that would block a correct implementation.
```

**Rules:**
- No tasks in feature files. Tasks live in your issue tracker (GitHub Issues, Linear, Jira).
- No research dumps. Distill findings into decisions.
- If a decision affects only this feature, note it here. If it affects the system, write an ADR.

---

## Standards Convention

Standards files use frontmatter to signal enforceability:

```markdown
---
enforced: true
applies-to: [api, data-model, all]
---
```

When an agent loads a feature, it must also load all standards where `enforced: true` and
`applies-to` matches the feature scope. Standards are hard constraints during code generation,
not optional reading.

---

## ADR Convention

Write an ADR when:
- A decision **affects more than one feature** or constrains future architecture
- A **non-obvious tradeoff** was made that needs future context
- A direction was **actively rejected** and you want to prevent re-litigating it

**Filename:** `ADR-NNN-short-title.md`

```markdown
# ADR-NNN: Title

## Status
Accepted | Superseded by ADR-NNN | Deprecated

## Context
What situation forced this decision.

## Decision
What was decided.

## Consequences
What this enables and what it constrains.
```

---

## Getting Started

Scaffold PragSpec in any project:

```bash
chmod +x init-pragspec.sh
./init-pragspec.sh [project-name]
```

See `examples/` for complete worked examples.

---

## Minimum Viable PragSpec

```
pragspec/
  spec.md                    ← functional spec + index
  architecture/
    overview.md              ← technical spec
  standards/
    coding.md
  features/                  ← empty, grow as needed
  decisions/                 ← empty, grow as needed
```

Start here. Add only what earns its place.

---

## PragSpec vs Heavier SDD

| Concern | Heavy SDD (e.g. spec-kit) | PragSpec |
|---|---|---|
| Per-feature docs | 5 files (spec, plan, tasks, research, data-model) | 1 file with Functional + Technical sections |
| Memory / context | Separate `constitution.md` | `pragspec/spec.md` as functional entry point |
| Technical spec | Scattered across templates | `pragspec/architecture/overview.md` |
| Task tracking | `tasks.md` per feature | External issue tracker |
| Templates | Explicit template system | Conventions defined here |
| Standards | Ad hoc | First-class with enforceability frontmatter |
| ADRs | Optional / implicit | Explicit `decisions/` folder |
| Project identity | Generic `docs/` folder | `pragspec/` — self-describing |
