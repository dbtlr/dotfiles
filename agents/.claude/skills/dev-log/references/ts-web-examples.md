# TypeScript/Web Dev Log Examples

Concrete examples showing how to document common session types in TypeScript/web projects. These are structural patterns — adapt content to your actual session.

---

## Bug Fix: TypeScript Type Error

```markdown
# 2026-02-13T14:30+1100 - Fix TS2345 in UserProfile component

## Overview
Resolved a TypeScript error in `UserProfile` that was blocking the CI build. The component was receiving `user` props typed as `User | null` but the child component expected `User`. Added a null guard and updated the prop types to use discriminated unions.

## Context
CI build failing on main since yesterday's merge of the user settings PR. Error: `TS2345: Argument of type 'User | null' is not assignable to parameter of type 'User'`.

## Problem Analysis
Root cause: `useCurrentUser()` hook returns `User | null` (user may not be authenticated), but `<UserProfile>` was passing this directly to `<AvatarUpload>` which expected `User`. No null guard existed.

Investigation:
1. Checked the error location: `src/components/UserProfile.tsx:47`
2. Traced `user` prop through to `AvatarUpload` — it assumed non-null
3. Checked other consumers of `useCurrentUser` — all were already null-guarding

## Solution
Added early return when `user` is null and updated `AvatarUpload` props to be explicit:

```typescript
// src/components/UserProfile.tsx
export function UserProfile() {
  const user = useCurrentUser()
  if (!user) return <Skeleton />          // null guard added

  return <AvatarUpload user={user} />     // now User, not User | null
}
```

## TypeScript Patterns

#### Narrowing with Early Return vs Assertion
**Problem**: `user` typed as `User | null` needed to be `User` for child component.

**Approaches considered**:
- `user!` assertion — bad, unsafe, hides the real bug
- `user as User` cast — equally bad
- Early return — correct: narrows type in the rest of the function
- Optional chaining — doesn't work when child requires non-null prop

**Solution**: Early return. After `if (!user) return`, TypeScript narrows `user` to `User` for the rest of the function scope.

## Testing
- Build passes locally: `tsc --noEmit` exits 0
- Manual test: authenticated user sees avatar upload; unauthenticated user sees skeleton

## Design Decisions
#### Why discriminated union vs optional chaining?
**Considered**: `<AvatarUpload user={user ?? undefined} />` and making the prop optional.
**Rejected**: Would silently degrade — the upload would disappear with no indication. Wrong UX.
**Chosen**: Early return with skeleton — explicit loading/auth state with correct UX.

## Key Learnings
- `useCurrentUser()` should be treated as potentially null at every call site. Consider adding ESLint rule or wrapper that forces null-checking.

## Files Modified
**my-app**:
- `src/components/UserProfile.tsx:47` — added null guard, fixed prop passing

## Commits
**my-app** (`a1b2c3d`): fix: null guard for useCurrentUser in UserProfile
```

---

## Bug Fix: Runtime Error (Prisma / Database)

```markdown
# 2026-02-13T09:15+1100 - Fix Prisma connection pool exhaustion in dev

## Overview
Resolved intermittent "PrismaClientKnownRequestError: Too many connections" errors in local development. Root cause was `new PrismaClient()` being called on each request in a hot-reloaded Next.js dev server instead of using a singleton.

## Context
Local dev server throwing connection pool errors after ~5 minutes of use, requiring server restart. Not reproducible in production (different process lifecycle).

## Problem Analysis
In Next.js dev mode, `require()` cache is cleared on hot reload, causing each reload to instantiate a new `PrismaClient` — each holds a connection pool open. After 5-6 reloads, PostgreSQL's max_connections (default 100) is approached.

Stack trace:
```
PrismaClientKnownRequestError:
  Can't reach database server at `localhost:5432`
  Please make sure your database server is running at `localhost:5432`.
```

## Solution
Implemented the standard Next.js + Prisma singleton pattern:

```typescript
// src/lib/db.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }

export const db =
  globalForPrisma.prisma ??
  new PrismaClient({ log: ['query'] })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db
```

## Design Decisions
#### Why globalThis vs module-level singleton?
**Considered**: Top-level `const db = new PrismaClient()` in the module.
**Rejected**: Doesn't survive Next.js hot reload — the module is re-evaluated, creating a new instance.
**Chosen**: `globalThis` persists across hot reloads in the same Node process. Standard Prisma recommendation for Next.js dev.

## TypeScript Patterns
#### Extending globalThis with custom properties
Casting `globalThis as unknown as { prisma: PrismaClient }` is the idiomatic pattern for adding typed properties to globalThis without module augmentation. The double cast (`as unknown as`) bypasses the structural check cleanly.

## Testing
- Hot-reloaded dev server 10 times without connection errors
- `prisma.$queryRaw` confirms single connection pool active

## Files Modified
**my-app**:
- `src/lib/db.ts` — new singleton module
- `src/app/api/**/*.ts` — updated imports from `prisma` to `db`

## Commits
**my-app** (`b2c3d4e`): fix: Prisma singleton to prevent connection pool exhaustion in dev
```

---

## Feature: New API Endpoint (Next.js App Router)

```markdown
# 2026-02-10T16:45+1100 - Add POST /api/invitations endpoint

## Overview
Implemented the invitation system backend: POST `/api/invitations` creates a new team invitation, sends an email via Resend, and returns the invitation token. Includes rate limiting (5 invitations per user per hour) and proper error handling.

## Implementation Approach
Chose Next.js Route Handler over Server Action because this endpoint is called from a mobile client in addition to the web app. Server Actions are web-only.

Architecture:
1. Validate input with Zod schema
2. Check rate limit (Redis, Upstash)
3. Create invitation record in Postgres via Prisma
4. Send email via Resend SDK
5. Return `{ token }` or structured error

## Implementation

```typescript
// src/app/api/invitations/route.ts
export async function POST(req: Request) {
  const session = await auth()
  if (!session) return new Response('Unauthorized', { status: 401 })

  const body = inviteSchema.safeParse(await req.json())
  if (!body.success) return Response.json({ error: body.error }, { status: 400 })

  const { limit, reset } = await rateLimit(session.user.id)
  if (limit === 0) {
    return Response.json(
      { error: 'Rate limit exceeded', reset },
      { status: 429, headers: { 'Retry-After': String(reset) } }
    )
  }

  const invitation = await db.invitation.create({
    data: { email: body.data.email, teamId: session.user.teamId, invitedBy: session.user.id }
  })

  await resend.emails.send({ to: body.data.email, subject: 'You\'ve been invited', ... })

  return Response.json({ token: invitation.token }, { status: 201 })
}
```

## Design Decisions
#### Why Zod at the route handler vs middleware?
**Considered**: Validation middleware (e.g. a `withValidation` HOF).
**Rejected**: Too much abstraction for current needs; makes error paths less readable.
**Chosen**: Inline `safeParse` — explicit and colocated with the handler logic.

#### Why return 429 vs 200 with error body?
**Considered**: Always 200, error in body.
**Rejected**: Breaks standard HTTP semantics; clients (especially mobile) rely on status codes for retry logic.
**Chosen**: Proper 429 with `Retry-After` header — standard and machine-readable.

## Testing
- `curl -X POST` with valid/invalid body: returns 201 / 400 as expected
- Rate limit: 6th request returns 429 with `reset` timestamp
- Resend sandbox confirms email sends
- Prisma Studio: invitation record created with correct fields

## Files Modified
**my-app**:
- `src/app/api/invitations/route.ts` — new route handler
- `src/lib/rate-limit.ts` — new Upstash rate limiter helper
- `prisma/schema.prisma` — added Invitation model
- `prisma/migrations/20260210_add_invitations/migration.sql` — generated migration

## Commits
**my-app** (`c3d4e5f`): feat: POST /api/invitations with rate limiting and email
```

---

## Refactor: Extracting a Custom Hook

```markdown
# 2026-02-08T11:20+1100 - Extract useFormSubmit hook from 4 components

## Overview
Refactored duplicate form submission logic from `LoginForm`, `SignupForm`, `InviteForm`, and `SettingsForm` into a shared `useFormSubmit` hook. Reduces ~120 lines of duplicated error handling, loading state, and toast notification code to a single 40-line hook.

## Implementation Approach
The four forms all had nearly identical:
1. `isSubmitting` state
2. `try/catch` with toast on error
3. `router.refresh()` on success
4. Type-safe error narrowing for API vs network errors

The hook accepts a generic `action` function and returns `{ submit, isSubmitting }`.

## Implementation

```typescript
// src/hooks/useFormSubmit.ts
export function useFormSubmit<T>(action: (data: T) => Promise<void>) {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const router = useRouter()

  const submit = async (data: T) => {
    setIsSubmitting(true)
    try {
      await action(data)
      router.refresh()
    } catch (err) {
      toast.error(isApiError(err) ? err.message : 'Something went wrong')
    } finally {
      setIsSubmitting(false)
    }
  }

  return { submit, isSubmitting }
}
```

## TypeScript Patterns
#### Generic action parameter
Using `<T>` on the hook allows TypeScript to infer the form data type from the `action` function's parameter, without requiring explicit type annotation at the call site.

```typescript
// TypeScript infers T = LoginFormData from the action's signature
const { submit } = useFormSubmit(loginAction)
//                              ^-- (data: LoginFormData) => Promise<void>
```

#### Type guard for API errors
`isApiError` narrows `unknown` catch argument:
```typescript
function isApiError(err: unknown): err is { message: string } {
  return typeof err === 'object' && err !== null && 'message' in err
}
```

## Design Decisions
#### Why generic T vs `Record<string, unknown>`?
**Considered**: Accepting `Record<string, unknown>` as the action parameter type.
**Rejected**: Loses type safety at the call site — action implementations would need internal casts.
**Chosen**: Generic `T` — preserves end-to-end type safety from form schema through to action.

## Key Learnings
- The `finally` block for `setIsSubmitting(false)` is essential — missed this in two components originally, leaving them stuck in loading state on error.

## Files Modified
**my-app**:
- `src/hooks/useFormSubmit.ts` — new hook
- `src/components/auth/LoginForm.tsx` — refactored to use hook
- `src/components/auth/SignupForm.tsx` — refactored to use hook
- `src/components/team/InviteForm.tsx` — refactored to use hook
- `src/components/settings/SettingsForm.tsx` — refactored to use hook

## Commits
**my-app** (`d4e5f6a`): refactor: extract useFormSubmit hook, eliminate duplicated error handling
```

---

## Investigation: Build / Bundler Issue

```markdown
# 2026-02-06T15:00+1100 - Investigate Next.js build failure after Turbopack migration

## Overview
Investigated a cryptic build failure after migrating from webpack to Turbopack (`next dev --turbo`). Root cause: a dynamic `require()` in a server utility was incompatible with Turbopack's ESM-first module resolution. Fixed by converting to static `import`.

## Problem Analysis

Error:
```
Error: Cannot find module './locale-data/' + locale
    at eval (webpack-internal:///./src/lib/i18n.ts)
```

Investigation steps:
1. Error only in Turbopack, not webpack — isolated to bundler difference
2. `./locale-data/` is a dynamic require with string concatenation — known Turbopack limitation
3. Checked Turbopack compatibility docs — dynamic `require()` with runtime-computed paths not supported
4. Found 3 other dynamic requires in codebase via grep

## Solution
Converted dynamic require to a static import map:

```typescript
// Before (incompatible with Turbopack):
const data = require(`./locale-data/${locale}`)

// After (static import map):
const localeModules = {
  en: () => import('./locale-data/en'),
  ja: () => import('./locale-data/ja'),
  de: () => import('./locale-data/de'),
}
const data = await localeModules[locale]?.()
```

## Mysteries and Uncertainties
- Turbopack's docs say dynamic requires "may work" — unclear why some work and others don't. The distinguishing factor seems to be whether the path is fully resolvable at build time, but the boundary isn't documented clearly.

## Key Learnings
- Turbopack migration checklist should include: grep for `require(` with string interpolation before migrating.
- Dynamic requires with runtime-computed paths need static import maps in ESM/Turbopack contexts.

## Files Modified
**my-app**:
- `src/lib/i18n.ts` — converted dynamic require to static import map
- `src/lib/config-loader.ts` — same fix (found during grep)

## Commits
**my-app** (`e5f6a7b`): fix: replace dynamic require with static import map for Turbopack compat
```
