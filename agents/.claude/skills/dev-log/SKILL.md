---
name: devlog
description: "Two subcommands: 'init' bootstraps a project's atlas integration (context, permissions, gitignore) and loads project context every session. 'write' creates a comprehensive dev log entry and updates shared knowledge files. Run as /devlog init <name> or /devlog write."
---

# Dev-Log Skill

Two subcommands for atlas vault integration:
- **`/devlog init <project name>`** — Bootstrap and load project context
- **`/devlog write`** — Write a session log and update knowledge files

All artifacts live in the atlas vault at `~/vaults/atlas/`.

---

## `/devlog init <project name>`

**MANDATORY on every session start for bootstrapped projects.** This command is called from `CLAUDE.local.md` before any other work. It ensures the project is correctly wired to atlas and loads all project context into the session.

### Step 1 — Resolve Project Name

The `<project name>` argument is the atlas project name. Match it against `~/vaults/atlas/Projects/`:

1. **Exact match** → use it
2. **Case-insensitive or substring match** → ask user: "Did you mean {X}?"
3. **No match** → ask user: "Create new project '{name}' in atlas, or no project for this repo?"
   - If creating new: `mkdir -p ~/vaults/atlas/Projects/{name}/{epics,tasks,notes}` and create `{name}.md` from the `_project.md` template (canonical entity note with above/below horizontal-rule split). Optionally seed an empty `task-board.md`.
   - If no project: use `vault_project: none` — log-only mode

### Step 2 — Write/Repair CLAUDE.local.md

Check if `CLAUDE.local.md` exists in the repo root with correct content. If missing or incomplete, write it. This is **self-healing** — it runs every time and repairs silently.

Write the following content (replace `{ProjectName}` and `{ProjectPath}`):

```markdown
# Project: {ProjectName}

## MANDATORY: atlas Integration

vault_project: {ProjectName}

**Subagent exclusion:** If you were dispatched as a subagent (via the Agent tool) with a specific task, **skip all mandatory sections in this file.** Do not run `/devlog init`, do not load context, do not write devlogs, do not update the atlas vault. Focus only on your assigned task. The controller session handles all vault integration.

**Before doing ANYTHING else in this session**, run: `/devlog init {ProjectName}`

This loads project context, ensures permissions, and prepares the session for logging.

## MANDATORY: Load Project Context

After init completes, immediately read:
```
~/vaults/atlas/Projects/{ProjectName}/{ProjectName}.md
```

This is the canonical project note. Content above the horizontal rule is the durable manifest (tech stack, key paths, conventions); content below is session-tracked state (current state, what's next, open questions, learnings, recent sessions). **Do not skip this.** Working without context wastes time rediscovering things previous sessions already learned.

## Project Artifact Paths

Write all project content to the atlas vault under the mini-vault contract — **not** to this repo:
- Epics: `~/vaults/atlas/Projects/{ProjectName}/epics/`
- Tasks: `~/vaults/atlas/Projects/{ProjectName}/tasks/`
- Notes (plans, specs, decisions, research, learnings, user-stories, brainstorms — differentiated by `source:` frontmatter): `~/vaults/atlas/Projects/{ProjectName}/notes/`

## Dev Log Frontmatter

When writing dev logs for this project, use this frontmatter:
```yaml
---
type: log
projects: "[[{ProjectName}]]"
date: YYYY-MM-DD
---
```

## MANDATORY: Dev-Log is Always Active

**Subagent exclusion:** These devlog and context-loading instructions apply ONLY to the primary interactive session. If you were dispatched as a subagent with a specific task description (via the Agent tool), **skip all of this** — do not run `/devlog init`, do not run `/devlog write`, do not read or update `{ProjectName}.md`, do not update `partner_model.md`, do not write to the atlas vault. Your job is implementation only. The controller session handles all logging and knowledge updates.

Dev-log is always on for the primary session. You do not need to be asked. Write a dev log (`/devlog write`) when **any** of these milestones occur:

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
      "Read(~/vaults/atlas/Log/**)",
      "Write(~/vaults/atlas/Log/**)",
      "Edit(~/vaults/atlas/Log/**)",
      "Read(~/vaults/atlas/Projects/{ProjectName}/**)",
      "Write(~/vaults/atlas/Projects/{ProjectName}/**)",
      "Edit(~/vaults/atlas/Projects/{ProjectName}/**)",
      "Read(~/vaults/atlas/System/**)",
      "Write(~/vaults/atlas/System/logs/**)",
      "Edit(~/vaults/atlas/System/logs/**)"
    ]
  }
}
```

If `vault_project: none`, only include the `Log/` permissions.

If the file already exists with other permissions, **merge** — add the atlas entries without removing existing ones.

### Step 4 — Ensure Gitignore

Check `.gitignore` for `CLAUDE.local.md` and `.claude/settings.local.json`. Add them if missing. Do not duplicate existing entries.

### Step 5 — Load Context (Already Initialized)

If the project was already initialized (CLAUDE.local.md existed and was correct), output the following into context so the agent has it immediately:

```
✓ atlas project: {ProjectName}
  Project note: ~/vaults/atlas/Projects/{ProjectName}/{ProjectName}.md
  Epics:        ~/vaults/atlas/Projects/{ProjectName}/epics/
  Tasks:        ~/vaults/atlas/Projects/{ProjectName}/tasks/
  Notes:        ~/vaults/atlas/Projects/{ProjectName}/notes/
  Task board:   ~/vaults/atlas/Projects/{ProjectName}/task-board.md
  Logs:         ~/vaults/atlas/Log/

Now read the project note to load project state.
```

Then **immediately read** `~/vaults/atlas/Projects/{ProjectName}/{ProjectName}.md`.

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
Bash(command: "grep -rl 'ISSUE-ID' ~/vaults/atlas/Log/ 2>/dev/null", description: "Find sessions for this issue")
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
projects: "[[PROJECT_NAME]]"
date: FILE_DATE
---
```

If `PROJECT_NAME` is `(none)`, use `projects: "[[unlinked]]"` or derive from repo context.

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

**`~/vaults/atlas/System/partner_model.md`** — update every session:
- New observations about collaboration patterns and preferences
- Calibration notes from this session
- Communication style discoveries

**`PROJECT_CONTEXT_PATH`** (points at `{ProjectName}.md`, if not `(none)`) — update every session with that project.

**CRITICAL BOUNDARY:** The project note has a horizontal rule (`---`) separating two zones:
- **Above the rule** — human-authored, durable manifest (tech stack, key paths, conventions, navigation). `/devlog write` MUST NOT modify this content.
- **Below the rule** — agent-maintained session state. `/devlog write` updates only these sections:
  - **Current State** — what was just built, what's merged, what's in-flight
  - **What's Next** — immediate next step
  - **Open Questions** — things that need decisions
  - **Learnings** — novel discoveries (library quirks, patterns, debugging approaches)
  - **Recent Sessions** — keep last 3 session summaries, linked to full logs

If the project note does not yet exist, create it from `~/vaults/atlas/System/Templates/_project.md`. Fill the above-the-rule sections from the session's discoveries about the repo (tech stack, key paths, conventions) and seed below-the-rule sections from the current session.

### Step 7 — Commit

```text
Bash(command: "git -C \"$HOME/vaults/atlas\" add Log/ System/ Projects/ && git -C \"$HOME/vaults/atlas\" commit -m 'vault(dev-log): [GIT_REPO] brief-description' && git -C \"$HOME/vaults/atlas\" push", description: "Commit and push dev log and knowledge updates to atlas vault")
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
- **Learnings go in the project note too** — novel discoveries should be in both the log (detailed) and below-the-rule `## Learnings` in `{ProjectName}.md` (summarized) so future sessions get them without reading every log. Above-the-rule content is off-limits.
