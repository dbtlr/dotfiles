---
name: devlog
description: "Two subcommands: 'init' bootstraps a project's Life Lab integration (context, permissions, gitignore) and loads project context every session. 'write' creates a comprehensive dev log entry and updates shared knowledge files. Run as /devlog init <name> or /devlog write."
---

# Dev-Log Skill

Two subcommands for Life Lab vault integration:
- **`/devlog init <project name>`** — Bootstrap and load project context
- **`/devlog write`** — Write a session log and update knowledge files

All artifacts live in the Life Lab vault at `~/data/vaults/Life Lab/`.

---

## `/devlog init <project name>`

**MANDATORY on every session start for bootstrapped projects.** This command is called from `CLAUDE.local.md` before any other work. It ensures the project is correctly wired to Life Lab and loads all project context into the session.

### Step 1 — Resolve Project Name

The `<project name>` argument is the Life Lab project name. Match it against `~/data/vaults/Life Lab/Projects/`:

1. **Exact match** → use it
2. **Case-insensitive or substring match** → ask user: "Did you mean {X}?"
3. **No match** → ask user: "Create new project '{name}' in Life Lab, or no project for this repo?"
   - If creating new: `mkdir -p ~/data/vaults/Life\ Lab/Projects/{name}` and create `context.md` from template (see below)
   - If no project: use `vault_project: none` — log-only mode

### Step 2 — Write/Repair CLAUDE.local.md

Check if `CLAUDE.local.md` exists in the repo root with correct content. If missing or incomplete, write it. This is **self-healing** — it runs every time and repairs silently.

Write the following content (replace `{ProjectName}` and `{ProjectPath}`):

```markdown
# Project: {ProjectName}

## MANDATORY: Life Lab Integration

vault_project: {ProjectName}

**Before doing ANYTHING else in this session**, run: `/devlog init {ProjectName}`

This loads project context, ensures permissions, and prepares the session for logging.

## MANDATORY: Load Project Context

After init completes, immediately read:
```
~/data/vaults/Life Lab/Projects/{ProjectName}/context.md
```

This file contains the current state of the project, what's next, open questions, and learnings from previous sessions. **Do not skip this.** Working without context wastes time rediscovering things previous sessions already learned.

## Project Artifact Paths

Write all plans, specs, and research to the Life Lab vault — **not** to this repo:
- Plans: `~/data/vaults/Life Lab/Projects/{ProjectName}/plans/`
- Specs: `~/data/vaults/Life Lab/Projects/{ProjectName}/specs/`
- Research: `~/data/vaults/Life Lab/Projects/{ProjectName}/research/`

## Dev Log Frontmatter

When writing dev logs for this project, use this frontmatter:
```yaml
---
type: log
project: "[[{ProjectName}]]"
date: YYYY-MM-DD
---
```

## MANDATORY: Dev-Log is Always Active

Dev-log is always on. You do not need to be asked. Write a dev log (`/devlog write`) when **any** of these milestones occur:

- **Task completion** — a feature, bugfix, refactor, or investigation is finished
- **Session wrap-up** — user signals they're done ("that's all", "good session", "wrap up", "done for now")
- **Context approaching limits** — write before you lose context of what was done
- **Repo switch** — switching to a different git repo mid-session; log the previous work first
- **Explicit request** — user says "dev log", "write a log", "document this"

**Do not ask permission.** Do not wait for a prompt. When a milestone hits, run `/devlog write`.
```

If `vault_project: none`, omit the project context loading, artifact paths, and frontmatter sections — keep only the dev-log trigger conditions with log-only instructions.

### Step 3 — Write/Repair .claude/settings.local.json

Check if `.claude/settings.local.json` exists with the required permissions. If missing or incomplete, write/merge them.

**Required permissions:**
```json
{
  "permissions": {
    "allow": [
      "Read(~/data/vaults/Life Lab/Log/**)",
      "Write(~/data/vaults/Life Lab/Log/**)",
      "Edit(~/data/vaults/Life Lab/Log/**)",
      "Read(~/data/vaults/Life Lab/Projects/{ProjectName}/**)",
      "Write(~/data/vaults/Life Lab/Projects/{ProjectName}/**)",
      "Edit(~/data/vaults/Life Lab/Projects/{ProjectName}/**)"
    ]
  }
}
```

If `vault_project: none`, only include the `Log/` permissions.

If the file already exists with other permissions, **merge** — add the Life Lab entries without removing existing ones.

### Step 4 — Ensure Gitignore

Check `.gitignore` for `CLAUDE.local.md` and `.claude/settings.local.json`. Add them if missing. Do not duplicate existing entries.

### Step 5 — Load Context (Already Initialized)

If the project was already initialized (CLAUDE.local.md existed and was correct), output the following into context so the agent has it immediately:

```
✓ Life Lab project: {ProjectName}
  Context: ~/data/vaults/Life Lab/Projects/{ProjectName}/context.md
  Plans:   ~/data/vaults/Life Lab/Projects/{ProjectName}/plans/
  Specs:   ~/data/vaults/Life Lab/Projects/{ProjectName}/specs/
  Research:~/data/vaults/Life Lab/Projects/{ProjectName}/research/
  Logs:    ~/data/vaults/Life Lab/Log/

Now read the context.md file to load project state.
```

Then **immediately read** `~/data/vaults/Life Lab/Projects/{ProjectName}/context.md`.

---

## `/devlog write`

Write a comprehensive dev log entry for the completed work, then update shared knowledge files.

**Do not wait to be asked.** This command triggers on milestones defined in `CLAUDE.local.md`.

### Step 1 — Run devlog_helper.sh

```text
Bash(command: "~/.claude/skills/dev-log/scripts/devlog_helper.sh", description: "Gather session metadata")
```

Capture from output:
- `TIMESTAMP` — use verbatim in log header (never invent)
- `FILE_DATE`, `FILE_TIME` — for filename construction
- `GIT_REPO`, `GIT_BRANCH` — repo context
- `ISSUE_HINT` — issue IDs from branch name
- `PROJECT_NAME` — from CLAUDE.local.md (may be `(none)`)
- `PROJECT_CONTEXT_PATH` — path to context.md (may be `(none)`)
- `LOG_DIR` — where to write the log
- `PREVIOUS_SESSION_PATH` — most recent prior log

Construct `SESSION_FILE_PATH`:
- With issues: `LOG_DIR/FILE_DATE_FILE_TIME_ISSUE_HINT_description.md`
- Without issues: `LOG_DIR/FILE_DATE_FILE_TIME_description.md`
- Description: 3–5 words, lowercase, hyphens (e.g. `add-user-auth`, `fix-prisma-pool`)

### Step 2 — Load Context

Always load previous session for continuity:
```text
Read(file_path: "[PREVIOUS_SESSION_PATH]")
```

Load same-day sessions if any exist (script outputs these under `SAME_DAY_SESSIONS`).

If continuing work on a specific issue, find related sessions:
```text
Bash(command: "grep -rl 'ISSUE-ID' ~/data/vaults/Life\ Lab/Log/ 2>/dev/null", description: "Find sessions for this issue")
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

Write to `SESSION_FILE_PATH`. Start with frontmatter:

```yaml
---
type: log
project: "[[PROJECT_NAME]]"
date: FILE_DATE
---
```

If `PROJECT_NAME` is `(none)`, use `project: "[[unlinked]]"` or derive from repo context.

Required sections every entry:

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

**`~/data/vaults/Life Lab/System/partner_model.md`** — update every session:
- New observations about collaboration patterns and preferences
- Calibration notes from this session
- Communication style discoveries

**`PROJECT_CONTEXT_PATH`** (if not `(none)`) — update every session with that project:
- If file doesn't exist, create it using the project context template (see below)
- Current state (what was just built, what's merged, what's in-flight)
- What's next (immediate next step)
- Open questions (things that need decisions)
- Recent activity (keep last 3 session summaries, linked to full logs)
- Learnings (novel discoveries — library quirks, patterns that worked, debugging approaches)
- Tech stack, key files, conventions, known issues (keep accurate)

**Project Context Template** (create on first session for a project):
```markdown
# Project: REPO-NAME

## Tech Stack
- **Language**: e.g. Rust, TypeScript
- **Framework**: e.g. Next.js 14, Actix
- **Testing**: e.g. Vitest, cargo test

## Key Files
- Entry point: `src/main.rs`
- Config: `Cargo.toml`

## Conventions
- (naming, folder structure, patterns)

## Known Issues
- (active bugs, tech debt, gotchas)

## Open Questions
- (unresolved decisions)

## Learnings
- (novel discoveries from building this project)

## Current State
- (what was just built, what's in-flight)

## What's Next
- (immediate next step)

## Recent Sessions
- [DATE description](~/data/vaults/Life Lab/Log/log-file.md) — one-line summary
```

### Step 7 — Commit

```text
Bash(command: "git -C \"$HOME/data/vaults/Life Lab\" add Log/ System/ Projects/ && git -C \"$HOME/data/vaults/Life Lab\" commit -m 'vault(dev-log): [GIT_REPO] brief-description' && git -C \"$HOME/data/vaults/Life Lab\" push", description: "Commit and push dev log and knowledge updates to Life Lab vault")
```

If nothing to commit (clean tree), skip silently.

---

## Important Notes

- **Never invent the timestamp** — always use `TIMESTAMP` from devlog_helper.sh output
- **More detail > less detail** — 500-line entries are fine; future context is priceless
- **Document mistakes** — failed approaches are as valuable as successful ones
- **Design Decisions section is gold** — "why X not Y" ages better than implementation details
- **Mysteries section is honest** — documenting unknowns prevents future sessions from wasting time on dead ends
- **One file per session** — never append to an existing log
- **Learnings go in context.md too** — novel discoveries should be in both the log (detailed) and context.md (summarized) so future sessions get them without reading every log
