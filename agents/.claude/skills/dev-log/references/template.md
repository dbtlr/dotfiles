# Dev Log Entry Template

This template codifies patterns from dev log entries across TypeScript/web projects. Use it as a structural guide — adapt freely when the session calls for different organization.

**Flexibility:** This is not a rigid checklist. Session type drives structure:
- Investigation-heavy sessions may need more "Discovery" or "Root Cause" subsections
- Multi-issue sessions may need per-issue subsections
- Planning sessions emphasize "Design Decisions" over "Implementation"
- Quick fixes may skip some sections (but always document them!)
- TypeScript-heavy sessions should include the "TypeScript Patterns" section

The goal is comprehensive documentation for future sessions, not format adherence.

---

## Header Format

```markdown
# YYYY-MM-DDThh:mm±zzzz - Brief Title
```

Use the exact timestamp from `devlog_helper.sh`. Never invent it.

---

## Required Sections

### Overview
High-level summary of what was accomplished. 2–3 sentences capturing the essence.

**Purpose:** Quick understanding without reading the full entry.

---

### Context
Why this work? What's the background?
- Reference issue IDs if applicable (e.g. `PROJ-123`)
- Link to previous sessions if continuing work
- Explain user requests or pain points being addressed
- Note the branch name if relevant

**Purpose:** Understanding motivation and how this fits into the larger picture.

---

### Problem Analysis OR Implementation Approach

**For bug fixes:**
- Root cause discovery process
- Investigation steps taken (what was checked, what was ruled out)
- What was broken and why
- Error messages or stack traces (abridged, key parts)

**For features:**
- Architectural decisions made
- Approach chosen and why
- High-level design before diving into code

**Purpose:** Understanding the problem space or design approach.

---

### Implementation OR Solution
What code changes were made? What was built?

Be specific:
- File paths with line numbers when relevant (e.g. `src/lib/auth.ts:134`)
- Key code patterns or algorithms (include short snippets when clarifying)
- API changes, schema migrations, config changes
- Build issues encountered and how fixed
- UI changes with before/after descriptions

**Purpose:** Detailed record of what was actually changed.

---

### Testing
How was it validated?

**Include:**
- Manual testing results (scenarios tested, steps taken)
- Unit/integration test outcomes (passing, failing, new tests added)
- Edge cases verified
- What worked, what didn't
- Performance measurements if relevant

**Purpose:** Proving the changes work and documenting test coverage.

---

### Design Decisions
**Critical section** — document "why X not Y" thinking using this pattern:

```markdown
#### Why [Decision About What]?

**Considered:** [Alternative approach A]
- Pros: ...
- Cons: ...

**Rejected:** [Reason it didn't work or wasn't chosen]

**Chosen:** [Approach taken] because:
- [Rationale point 1]
- [Rationale point 2]
```

**Examples of good design decision topics:**
- Why this state management approach vs alternatives
- Why this API design (REST vs tRPC vs GraphQL endpoint)
- Why this database schema choice
- Why this abstraction level (hook vs context vs store)
- Why solve now vs defer (tech debt decisions)
- Why this error handling strategy
- Why this TypeScript type approach (branded types, discriminated unions, etc.)

**Purpose:** Future sessions need to understand WHY decisions were made. This is often the most valuable section — implementation details change, decision rationale stays relevant.

---

### Key Learnings
What did we discover? What would we do differently?

**Include:**
- Mistakes made and how corrected (be explicit — this is valuable!)
- Unexpected behaviors or framework quirks discovered
- Things that surprised us
- Better ways to approach similar problems in future
- "If I had to do this again, I would..."

**Purpose:** Capturing knowledge that prevents repeating mistakes.

---

### Files Modified
Complete list, grouped by repo if multi-repo work.

**Format:**
```markdown
**my-app**:
- `src/app/(auth)/login/page.tsx` — added OAuth provider buttons
- `src/lib/auth.ts` — configured NextAuth with GitHub provider
- `prisma/schema.prisma` — added Account and Session models

**shared-lib**:
- `packages/ui/src/Button.tsx` — added loading state prop
```

**Purpose:** Quick reference for what changed and where.

---

### Commits
List all commits made, or note if uncommitted with rationale.

**Format:**
```markdown
**my-app** (`a1b2c3d`):
- feat: add GitHub OAuth login flow
- fix: resolve Prisma session adapter type error

**Uncommitted**: [Explain why — e.g. waiting for test pass, or WIP mid-refactor]
```

**Purpose:** Linking session to git history and documenting commit strategy.

---

## Conditional Sections

Include these when relevant:

### Remaining Work
Unfinished tasks, next steps, follow-up items.

Use when:
- Session ended due to context limits mid-task
- Discovered additional work during implementation
- Follow-up tasks identified

**Format:** Bulleted list with enough detail for the next session to pick up cleanly.

---

### Open Questions
Things we need to figure out but haven't resolved yet.

**Format:**
```markdown
**Question**: [Specific question]

**Context**: Why it matters

**Status**: Not blocking / Blocking for [X]
```

---

### Mysteries and Uncertainties
Things we don't understand. Be explicit about unknowns.

**Examples:**
- Unexpected behavior observed but not explained
- Performance characteristics not understood
- Framework behavior that seems inconsistent
- Edge cases discovered but not fully investigated
- Type errors that were worked around, not understood

**Purpose:** Honest documentation of gaps in understanding. Future sessions may need to investigate these — better to know they exist.

---

### TypeScript Patterns
Include when the session involved significant TypeScript work.

**Format:**
```markdown
#### [Pattern or Issue Name]

**Context**: Where this came up

**Problem**: What the type error or challenge was (include error message if helpful)

**Solution**: How it was resolved

**Why it works**: Brief explanation of the TypeScript mechanic involved

**Example**:
\`\`\`typescript
// Before (error):
// After (fixed):
\`\`\`
```

**Common topics:**
- Generic constraint solutions
- Discriminated union patterns
- Conditional type usage
- `satisfies` vs `as` vs explicit annotation choices
- Type narrowing strategies
- Module augmentation patterns
- `infer` usage in template literal or mapped types

---

### References
- **Issues**: List with any status changes made this session
- **Related sessions**: Link to previous work on the same feature/bug
- **Knowledge files**: Which ones were read or updated
- **External docs**: Framework docs, blog posts, StackOverflow threads that were key

---

## Tips for Writing Good Dev Logs

1. **Write for your future self**: You have no memory between sessions. What context would you need?
2. **Document mistakes**: Failed approaches are valuable. Future sessions need to know what doesn't work.
3. **Be specific**: "Fixed the bug" is useless. "Fixed N+1 query in `getUserPosts` by adding Prisma `include`" is useful.
4. **Capture "why"**: Code shows "what", dev logs should show "why".
5. **Design Decisions are gold**: These age best. Implementation details may change, but decision rationale stays relevant.
6. **Don't skip "Mysteries"**: Unknown behaviors need documentation so future sessions can investigate or work around them.
7. **More detail > less detail**: 500-line entries are fine. Future context efficiency comes from loading only relevant sessions, not from skimping on detail within them.
8. **TypeScript section when in doubt**: If you spent time fighting the type system, future sessions need to know what you discovered.

---

## Section Naming Conventions

Use these exact names for consistency (grep-ability matters):
- `## Mysteries and Uncertainties` (not "Mysteries" alone)
- `## Key Learnings` (not "Learnings" or "Key Learning")
- `## Design Decisions` (not "Key Decisions")
- `## Files Modified` (not "Changed Files")
- `## TypeScript Patterns` (not "TypeScript Notes")
