# PragSpec

**Pragmatic Spec Driven Development** — a lightweight framework for AI-assisted software delivery.

PragSpec is a minimalist approach to Spec Driven Development (SDD) designed for teams and AI agents to co-author, navigate, and act on living documentation. It deliberately reduces the complexity of heavier SDD frameworks by collapsing per-feature multi-file structures into a single, scannable `/docs` tree.

---

## Why PragSpec

Modern AI coding agents work best when they have:

- A clear **entry point** to load as context before acting
- **Dense, single-file** units of work they can reason about atomically
- **Explicit constraints** they must not violate during generation
- **Traceable decisions** explaining *why* things are the way they are

Heavy SDD frameworks create cognitive overhead — for humans and agents alike. PragSpec strips it to the minimum that actually powers delivery.

---

## Structure

```
docs/
├── README.md                  ← Agent entry point. Always read first.
├── architecture/
│   ├── overview.md            ← System context, tech stack, key design
│   ├── principles.md          ← Engineering principles this project follows
│   └── constraints.md         ← Hard limits (infra, compliance, scale)
├── features/
│   └── feature-name.md        ← One file per feature
├── decisions/
│   └── ADR-001-title.md       ← Architecture Decision Records
└── standards/
    ├── coding.md              ← Language/style conventions
    ├── error-model.md         ← Error response contract
    └── api-versioning.md      ← Versioning strategy
```

---

## Agent Interaction Model

Every agent session follows this read order:

1. **`docs/README.md`** — project index, active features, enforced standards
2. **`docs/architecture/overview.md`** — system context and constraints
3. **`docs/standards/*.md`** where `enforced: true` — hard constraints for generation
4. **Target `docs/features/feature-name.md`** — the specific unit of work

This sequence ensures the agent has full ground truth before touching code.

---

## Feature File Format

Every feature file follows this canonical structure:

```markdown
---
status: draft | ready | in-progress | done
---

## Why
Problem statement and motivation.

## What
Behavior, scope, and acceptance criteria.

## Data Model
(Optional) Key entities and relationships.

## Out of Scope
Explicit exclusions to prevent scope creep.

## Open Questions
Unresolved decisions that would block implementation.
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

When an agent loads a feature, it must also load all standards where `enforced: true` and `applies-to` matches the feature scope. This makes standards behave as hard constraints during code generation, not optional reading.

---

## ADR Convention

Write an ADR when:

- A decision **affects more than one feature** or constrains future architecture
- A **non-obvious tradeoff** was made that needs future context
- A decision was **actively rejected** and you need to prevent re-litigating it

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

For a new project, the minimum starting footprint:

```
docs/
  README.md               ← agent entry point
  architecture/
    overview.md
  standards/
    coding.md
  features/               ← empty, grow as needed
  decisions/              ← empty, grow as needed
```

Everything else grows as the project grows. Start here. Add only what earns its place.

---

## PragSpec vs Heavier SDD

| Concern | Heavy SDD (e.g. spec-kit) | PragSpec |
|---|---|---|
| Per-feature docs | 5 files (spec, plan, tasks, research, data-model) | 1 file with sections |
| Memory / context | Separate `constitution.md` | `docs/README.md` as index |
| Task tracking | `tasks.md` per feature | External issue tracker |
| Templates | Explicit template system | Conventions in README |
| Standards | Ad hoc | First-class with enforceability frontmatter |
| ADRs | Optional / implicit | Explicit `/decisions` folder |
| Agent entry point | Defined per framework | `docs/README.md` always |
