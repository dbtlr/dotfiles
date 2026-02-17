---
name: dev-log
description: This skill should be used when the user says "write a dev log", "document this session", "log the session", "session end", or when approaching context limits. Proactively triggered on task completion, session wrap-up, repo switch, or explicit request. Writes a comprehensive development log entry and updates shared knowledge files.
---

# Dev-Log: Session Documentation Skill

Write a comprehensive development log entry for the completed work session, then update shared knowledge files so future sessions have full context.

## Trigger Conditions

**Do not wait to be asked.** Write a dev log when any of these occur:

- A feature, bugfix, refactor, or investigation reaches completion
- The user signals session end ("done", "that's all", "good session", "wrap up")
- Context limits approaching and meaningful work has been done
- Switching git repos mid-session — log the prior work before continuing
- User explicitly says "dev log", "write a log", "document this", or runs `/dev-log`

The Stop hook is gone — **this skill is responsible for its own triggering.**

## 7-Step Workflow

### Step 1 — Run devlog_helper.sh

```text
Bash(command: "~/.claude/skills/dev-log/scripts/devlog_helper.sh", description: "Gather session metadata")
```

Capture from output:
- `TIMESTAMP` — use verbatim in log header (never invent)
- `WEEK_DIR` — week folder path
- `PREVIOUS_SESSION_PATH` — most recent prior log
- `SAME_DAY_SESSIONS` — any earlier sessions today
- `GIT_REPO` — repository basename (e.g. `my-app`)
- `GIT_BRANCH` — current branch
- `ISSUE_HINT` — issue IDs parsed from branch name (if present)
- `PROJECT_MANIFEST_PATH` — per-repo knowledge file path

Construct `SESSION_FILE_PATH`:
- With issues: `WEEK_DIR/FILE_DATE_FILE_TIME_ISSUE_HINT_description.md`
- Without issues: `WEEK_DIR/FILE_DATE_FILE_TIME_description.md`
- Description: 3–5 words, lowercase, hyphens (e.g. `add-user-auth`, `fix-prisma-connection-pool`)

### Step 2 — Load Context

Always load previous session for continuity:
```text
Read(file_path: "[PREVIOUS_SESSION_PATH]")
```

Load same-day sessions if any exist (script outputs these under `SAME_DAY_SESSIONS`).

If continuing work on a specific issue, find related sessions:
```text
Bash(command: "grep -rl 'ISSUE-ID' ~/vaults/agents/log/ 2>/dev/null", description: "Find sessions for this issue")
```

### Step 3 — Read Template

```text
Read(file_path: "~/.claude/skills/dev-log/references/template.md")
```

Use as structure guide, not a rigid checklist. Adapt for the session type.

### Step 4 — Read Domain Examples (when relevant)

```text
Read(file_path: "~/.claude/skills/dev-log/references/ts-web-examples.md")
```

Reference when documenting TypeScript errors, React patterns, build tooling, or API work.

### Step 5 — Write Session Log

Write to `SESSION_FILE_PATH`. Required sections every entry:

```markdown
# TIMESTAMP (timezone location) - Brief Title

## Overview
2–3 sentences. What was accomplished?

## Context
Why this work? Branch, issue IDs, user request, prior session link.

## Problem Analysis OR Implementation Approach
Bug fix → root cause discovery, investigation steps.
Feature → architecture, approach chosen.

## Implementation OR Solution
Specific changes: file paths, key patterns, algorithms, build issues fixed.
Include line numbers when referencing specific locations.

## Testing
How was the work validated? What was tested, what passed, what didn't?

## Design Decisions
**Why X not Y** — use Considered/Rejected/Chosen format for significant decisions.

## Key Learnings
Mistakes made and corrected. Surprises. Better approaches for next time.

## Files Modified
Grouped by repo if multi-repo work.

## Commits
Commit hashes and messages, or note if uncommitted with rationale.
```

Conditional sections (add when relevant):
- `## Remaining Work` — unfinished tasks, follow-ups
- `## Open Questions` — unresolved questions with context and blocking status
- `## Mysteries and Uncertainties` — unexplained behaviors, gaps in understanding
- `## TypeScript Patterns` — type errors encountered, inference issues, generics decisions
- `## References` — related sessions, external docs, issue links

**More detail is always better than less.** Write for a future session with zero memory of today.

### Step 6 — Update Knowledge Files

Update these files based on what was learned this session. Take ownership — don't just suggest updates.

**`~/vaults/agents/knowledge/partner_model.md`** — update every session:
- New observations about collaboration patterns and preferences
- Calibration notes from this session
- Communication style discoveries

**`~/vaults/agents/knowledge/patterns.md`** — update when new patterns found:
- Architectural decisions and rationales
- TypeScript/JavaScript patterns discovered
- Common pitfalls and their solutions
- Implementation examples worth preserving

**`PROJECT_MANIFEST_PATH`** (e.g. `~/vaults/agents/knowledge/projects/my-app.md`) — update every session with that repo:
- If file doesn't exist, create it using the project manifest template (see below)
- Tech stack (framework, bundler, DB, ORM, auth, testing)
- Key file paths (entry points, config files, important modules)
- Conventions (naming, file structure, state management patterns)
- Open questions and known issues
- Recent session summaries (keep last 3, linked to full logs)

**Project Manifest Template** (create on first session for a repo):
```markdown
# Project: REPO-NAME

## Tech Stack
- **Framework**: e.g. Next.js 14, React 18
- **Bundler**: e.g. Vite, Turbopack
- **Database**: e.g. PostgreSQL via Prisma
- **Auth**: e.g. NextAuth.js
- **Testing**: e.g. Vitest, Playwright

## Key Files
- Entry point: `src/app/layout.tsx`
- Config: `next.config.ts`, `tsconfig.json`
- DB schema: `prisma/schema.prisma`

## Conventions
- (naming, folder structure, state management, etc.)

## Known Issues
- (active bugs, tech debt, known gotchas)

## Open Questions
- (unresolved architectural decisions)

## Recent Sessions
- [DATE description](path/to/log.md) — one-line summary
- [DATE description](path/to/log.md) — one-line summary
- [DATE description](path/to/log.md) — one-line summary
```

### Step 7 — Commit

```text
Bash(command: "git -C ~/vaults/agents add log/ knowledge/ && git -C ~/vaults/agents commit -m 'Session log: [GIT_REPO] brief-description\n\nCo-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>'", description: "Commit dev log and knowledge updates to agents repo")
```

The `~/vaults/agents/` directory is a git repo that contains both `log/` and `knowledge/` — commit all session artifacts together in one commit.

## Important Notes

- **Never invent the timestamp** — always use `TIMESTAMP` from devlog_helper.sh output
- **More detail > less detail** — 500-line entries are fine; future context is priceless
- **Document mistakes** — failed approaches are as valuable as successful ones
- **Design Decisions section is gold** — "why X not Y" ages better than implementation details
- **Mysteries section is honest** — documenting unknowns prevents future sessions from wasting time on dead ends
- **One file per session** — never append to a weekly file
