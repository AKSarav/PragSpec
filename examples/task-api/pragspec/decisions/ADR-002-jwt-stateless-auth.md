# ADR-002: Stateless JWT over Session-Based Auth

## Status
Accepted

## Context
The API needs an authentication mechanism. The two standard options are:

1. **Session-based auth** — server issues a session ID stored in a cookie; session state lives in the database or a cache (Redis); every request hits the store to validate the session
2. **Stateless JWT** — server signs a token at login; subsequent requests carry the token; the server validates the signature without any database lookup

This is a v1 API with no existing infrastructure. The expected client is a frontend app
or a script — not a browser-first application where `HttpOnly` cookies are the default
safe choice.

## Decision
Use **stateless JWT** (HS256) with a 1-hour expiry. No refresh tokens in v1.

- Tokens are signed with a secret loaded from `JWT_SECRET` env var
- Payload: `{ sub: userId, email, iat, exp }`
- Clients send the token as `Authorization: Bearer <token>`
- No server-side session storage — zero additional infrastructure

## Consequences

**Enables:**
- No database lookup on every authenticated request — validation is a pure cryptographic operation
- No Redis or session store needed — the service remains self-contained
- Stateless design simplifies horizontal scaling if added later

**Constrains:**
- **Token revocation is not possible** before expiry — if a token is stolen, it is valid until it expires (1 hour)
- Clients must re-authenticate after 1 hour — there is no refresh token mechanism in v1
- If token revocation becomes a requirement (e.g. logout, forced sign-out), this ADR must be superseded with a token denylist or a switch to session-based auth

**Future path:**
If revocation or longer sessions are needed, introduce refresh tokens (short-lived access token + long-lived refresh token stored in DB) and supersede this ADR.
