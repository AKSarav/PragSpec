---
enforced: true
applies-to: [all]
---

# Coding Standards

## Language & Runtime
TypeScript 5.x, Node.js 20 LTS. Strict mode enabled in `tsconfig.json` (`"strict": true`).
No `any` types without an inline comment explaining why it cannot be avoided.

## Style
- Formatter: **Prettier** (default config, `printWidth: 100`). All code must pass `prettier --check`.
- Linter: **ESLint** with `@typescript-eslint` recommended rules.
- No `console.log` in production code — use a structured logger (e.g. `pino`).
- Imports: absolute paths using `@/` alias for `src/`. No relative `../../` imports beyond one level.

## Naming Conventions
- Files and directories: `camelCase` for files (`userService.ts`), `kebab-case` for route files (`user-routes.ts`)
- Classes and types: `PascalCase`
- Variables, functions, methods: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Zod schemas: suffix with `Schema` (e.g. `createTaskSchema`)
- Prisma models: match the Prisma schema exactly (PascalCase singular)

## Project Structure
```
src/
  app.ts                  ← Express app factory (no listen() call)
  server.ts               ← Entry point: creates app, starts listener
  routes/
    auth.routes.ts        ← /v1/auth/* route registration
    task.routes.ts        ← /v1/tasks/* route registration (with auth middleware)
    user.routes.ts        ← /v1/users/* route registration (with auth middleware)
  controllers/
    auth.controller.ts
    task.controller.ts
    user.controller.ts
  services/
    auth.service.ts
    task.service.ts
    user.service.ts
  middleware/
    authenticate.ts       ← JWT validation, attaches req.user
    error-handler.ts      ← Global error handler (Express 4 signature)
  schemas/
    auth.schema.ts        ← Zod schemas for auth endpoints
    task.schema.ts        ← Zod schemas for task endpoints
  lib/
    prisma.ts             ← Singleton Prisma client instance
    jwt.ts                ← sign/verify helpers
  types/
    express.d.ts          ← Augments Express Request with req.user
prisma/
  schema.prisma
tests/
  auth.test.ts
  tasks.test.ts
```

## Layering Rules
- Controllers parse + validate input (Zod) and call services. No Prisma imports in controllers.
- Services contain business logic. No Express types (`Request`, `Response`). No direct Prisma calls in controllers.
- All Prisma access goes through services. The Prisma client singleton lives in `lib/prisma.ts`.
- Middleware must not contain business logic — only cross-cutting concerns (auth, logging, error handling).

## Error Handling
- All errors follow `standards/error-model.md`.
- Services throw typed `AppError` instances (with `code`, `statusCode`, `message`).
- The global error handler in `middleware/error-handler.ts` catches all errors and formats them.
- Never let unhandled promise rejections surface — use `express-async-errors` or explicit try/catch in controllers.

## Testing
- Framework: **Vitest** + **supertest**.
- Coverage threshold: **80%** on `src/`.
- Every endpoint must have at least a success case and an auth-failure case.
- Use an in-memory test database or a dedicated test schema — never run tests against the production DB.
- Reset database state between test suites using Prisma's `$transaction` rollback or `prisma.$executeRaw`.

## Dependencies
- Manage with **npm**. Pin exact versions in `package.json` (`"express": "4.18.2"`, not `"^4"`).
- No unused dependencies. Run `npm ls` to verify before committing.
- Avoid adding a new dependency when a Node.js built-in or an already-present package covers the need.
