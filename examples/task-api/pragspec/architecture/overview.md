# Technical Spec

## Tech Stack

| Layer | Choice | Version |
|---|---|---|
| Language | TypeScript | 5.x |
| Runtime | Node.js | 20 LTS |
| Framework | Express | 4.x |
| ORM | Prisma | 5.x |
| Database | PostgreSQL | 16 |
| Auth | jsonwebtoken + bcrypt | latest stable |
| Validation | Zod | 3.x |
| Test framework | Vitest + supertest | latest stable |

## System Design

The service follows a layered architecture: route handlers → controllers → services → repository (via Prisma).

- **Routes** (`src/routes/`) register Express routers and apply middleware. No logic.
- **Controllers** (`src/controllers/`) parse and validate incoming requests using Zod, call service methods, and return HTTP responses. No database access.
- **Services** (`src/services/`) own all business logic — ownership checks, hashing, token generation. No Express types.
- **Prisma client** is the only database access layer. It is injected into services; never imported directly in controllers or routes.
- **Middleware** (`src/middleware/`) contains `authenticate.ts` — validates the JWT from `Authorization: Bearer <token>` and attaches `req.user` to the request. All task routes apply this middleware.

Authentication flow: client POSTs credentials → service verifies password hash → signs JWT → returns token. Subsequent requests carry the token; middleware validates it and extracts `userId` before the controller runs.

## Integration Points

None at this stage. PostgreSQL is the only external dependency — no email provider, no third-party auth service.

## Constraints

- **User isolation** — every database query on the `tasks` table must include a `WHERE userId = req.user.id` clause. The service layer enforces this; it is never left to the controller.
- **Password storage** — bcrypt with a minimum cost factor of **12**. Passwords are hashed in the service before any database write. Plain passwords must never appear in logs.
- **JWT expiry** — access tokens expire in `1h`. No refresh tokens in v1. Clients must re-authenticate on expiry.
- **JWT secret** — loaded from `JWT_SECRET` environment variable. The service must not start if this variable is unset.
- **Database URL** — loaded from `DATABASE_URL` environment variable. Prisma uses this directly.
- TypeScript strict mode (`"strict": true`) is enabled. No `any` types without an explanatory comment.
