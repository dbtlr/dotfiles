---
name: devlog
description: "Two subcommands: 'init' bootstraps a workspace's atlas integration (context, permissions, gitignore) and loads workspace context every session. 'write' creates a comprehensive dev log entry and updates shared knowledge files. Run as /devlog init <workspace-slug> or /devlog write."
---

# Dev-Log Skill

Two subcommands for atlas vault integration:
- **`/devlog init <workspace-slug>`** — Bootstrap and load workspace context
- **`/devlog write`** — Write a session log and update knowledge files

All artifacts live in the atlas vault at `~/vaults/atlas/`.

---

## `/devlog init <workspace-slug>`

**MANDATORY on every session start for bootstrapped workspaces.** This command is called from `CLAUDE.local.md` before any other work. It ensures the workspace is correctly wired to atlas and loads all workspace context into the session.

### Step 1 — Resolve Workspace Slug

The `<workspace name>` argument is the atlas workspace slug. Match it against `~/vaults/atlas/Workspaces/`:

1. **Exact match** → use it
2. **Case-insensitive or substring match** → ask user: "Did you mean {X}?"
3. **No match** → ask user: "Create new workspace '{name}' in atlas, or no workspace for this repo?"
   - If creating new: `mkdir -p ~/vaults/atlas/Workspaces/{name}/{tasks,notes,agent-artifacts}` and create `{name}.md` from the `_workspace.md` template / workspace-structure standard.
   - If no workspace: use `vault_workspace: none` — log-only mode

### Step 2 — Ensure Workspace Directories

For a resolved workspace, ensure the mini-vault directories exist:
```text
~/vaults/atlas/Workspaces/{WorkspaceSlug}/tasks/
~/vaults/atlas/Workspaces/{WorkspaceSlug}/notes/
~/vaults/atlas/Workspaces/{WorkspaceSlug}/agent-artifacts/
```

Create missing directories silently. Do not move existing files during init.

### Step 3 — Write/Repair CLAUDE.local.md

Check if `CLAUDE.local.md` exists in the repo root with correct content. If missing or incomplete, write it. This is **self-healing** — it runs every time and repairs silently.

Write the following content (replace `{WorkspaceSlug}` and `{WorkspacePath}`):

```markdown
# Workspace: {WorkspaceSlug}

## MANDATORY: atlas Integration

vault_workspace: {WorkspaceSlug}

**Subagent exclusion:** If you were dispatched as a subagent (via the Agent tool) with a specific task, **skip all mandatory sections in this file.** Do not run `/devlog init`, do not load context, do not write devlogs, do not update the atlas vault. Focus only on your assigned task. The controller session handles all vault integration.

**Before doing ANYTHING else in this session**, run: `/devlog init {WorkspaceSlug}`

This loads workspace context, ensures permissions, and prepares the session for logging.

## MANDATORY: Load Workspace Context

After init completes, immediately read:
```
~/vaults/atlas/Workspaces/{WorkspaceSlug}/{WorkspaceSlug}.md
```

This is the canonical workspace note. Content above the horizontal rule is the durable manifest (tech stack, key paths, conventions); content below is session-tracked state (current state, what's next, open questions, learnings, recent sessions). **Do not skip this.** Working without context wastes time rediscovering things previous sessions already learned.

## Workspace Artifact Paths

Write all workspace content to the atlas vault under the mini-vault contract — **not** to this repo:
- Tasks: `~/vaults/atlas/Workspaces/{WorkspaceSlug}/tasks/`
- Notes (canonical workspace knowledge: human-authored/summarized plans, specs, decisions, research, learnings, user-stories, brainstorms — differentiated by `kind:` frontmatter): `~/vaults/atlas/Workspaces/{WorkspaceSlug}/notes/`
- Agent artifacts (generated execution reference from Claude Code/Superpowers or other coding agents): `~/vaults/atlas/Workspaces/{WorkspaceSlug}/agent-artifacts/`

Generated coding-agent plans/specs/reviews/log-like run artifacts are **not** canonical notes. Route them to `agent-artifacts/` with `type: agent-artifact`. Only write to `notes/` when durable knowledge has been explicitly rewritten or summarized as a normal `type: note`.

## Agent Artifact Frontmatter

When writing generated plans/specs/reviews into `agent-artifacts/`, use minimal frontmatter:
```yaml
---
type: agent-artifact
artifact_kind: plan # plan | spec | review | log | summary
source: claude-code-superpowers
created: YYYY-MM-DDTHH:mm
modified: YYYY-MM-DDTHH:mm
workspace: "[[{WorkspaceSlug}]]"
related_task: "[[task-note-name]]" # optional; omit or leave blank if not obvious
---
```

Do not add `kind:` to agent artifacts; `kind:` is reserved for `type: note`. Fill `related_task` only when the current work clearly maps to an Atlas task.

## Dev Log Frontmatter

When writing dev logs for this workspace, use this frontmatter:
```yaml
---
type: log
workspace: "[[{WorkspaceSlug}]]"
date: YYYY-MM-DD
---
```

## MANDATORY: Dev-Log is Always Active

**Subagent exclusion:** These devlog and context-loading instructions apply ONLY to the primary interactive session. If you were dispatched as a subagent with a specific task description (via the Agent tool), **skip all of this** — do not run `/devlog init`, do not run `/devlog write`, do not read or update `{WorkspaceSlug}.md`, do not update `partner_model.md`, do not write to the atlas vault. Your job is implementation only. The controller session handles all logging and knowledge updates.

Dev-log is always on for the primary session. You do not need to be asked. Write a dev log (`/devlog write`) when **any** of these milestones occur:

- **Task completion** — a feature, bugfix, refactor, or investigation is finished
- **Session wrap-up** — user signals they're done ("that's all", "good session", "wrap up", "done for now")
- **Context approaching limits** — write before you lose context of what was done
- **Repo switch** — switching to a different git repo mid-session; log the previous work first
- **Explicit request** — user says "dev log", "write a log", "document this"

**Do not ask permission.** Do not wait for a prompt. When a milestone hits, run `/devlog write`.
```

If `vault_workspace: none`, omit the workspace context loading, artifact paths, and frontmatter sections — keep only the dev-log trigger conditions with log-only instructions.

### Step 4 — Write/Repair .claude/settings.local.json

Check if `.claude/settings.local.json` exists with the required permissions. If missing or incomplete, write/merge them.

**Required permissions:**
```json
{
  "permissions": {
    "allow": [
      "Read(~/vaults/atlas/Log/**)",
      "Write(~/vaults/atlas/Log/**)",
      "Edit(~/vaults/atlas/Log/**)",
      "Read(~/vaults/atlas/Workspaces/{WorkspaceSlug}/**)",
      "Write(~/vaults/atlas/Workspaces/{WorkspaceSlug}/**)",
      "Edit(~/vaults/atlas/Workspaces/{WorkspaceSlug}/**)",
      "Read(~/vaults/atlas/System/**)",
      "Write(~/vaults/atlas/System/logs/**)",
      "Edit(~/vaults/atlas/System/logs/**)"
    ]
  }
}
```

If `vault_workspace: none`, only include the `Log/` permissions.

If the file already exists with other permissions, **merge** — add the atlas entries without removing existing ones.

### Step 5 — Ensure Gitignore

Check `.gitignore` for `CLAUDE.local.md` and `.claude/settings.local.json`. Add them if missing. Do not duplicate existing entries.

### Step 6 — Load Context (Already Initialized)

If the workspace was already initialized (CLAUDE.local.md existed and was correct), output the following into context so the agent has it immediately:

```
✓ atlas workspace: {WorkspaceSlug}
  Workspace note: ~/vaults/atlas/Workspaces/{WorkspaceSlug}/{WorkspaceSlug}.md
  Tasks:          ~/vaults/atlas/Workspaces/{WorkspaceSlug}/tasks/
  Notes:          ~/vaults/atlas/Workspaces/{WorkspaceSlug}/notes/
  Agent artifacts: ~/vaults/atlas/Workspaces/{WorkspaceSlug}/agent-artifacts/
  Task board:     ~/vaults/atlas/task-board.base
  Logs:         ~/vaults/atlas/Log/

Now read the workspace note to load workspace state.
```

Then **immediately read** `~/vaults/atlas/Workspaces/{WorkspaceSlug}/{WorkspaceSlug}.md`.

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
- `WORKSPACE_NAME` — from CLAUDE.local.md (may be `(none)`)
- `WORKSPACE_CONTEXT_PATH` — path to workspace root note (may be `(none)`)
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
workspace: "[[WORKSPACE_NAME]]"
date: FILE_DATE
---
```

If `WORKSPACE_NAME` is `(none)`, omit `workspace:` or derive a workspace slug from repo context only when obvious.

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

**`~/vaults/atlas/System/partner_model.md`** — do NOT edit from devlog. Partner-model maintenance is owned by the separate `partner-model` skill, which appends observations to `System/logs/partner_model_log.jsonl` and regenerates `partner_model.md` by consolidation. That file is generated output — never hand-edit it, and do not announce partner-model activity. Leave collaboration/calibration observations to the `partner-model` skill's own session-end pass; the devlog updates only the session log and the workspace note below.

**`WORKSPACE_CONTEXT_PATH`** (points at `{WorkspaceSlug}.md`, if not `(none)`) — update every session with that workspace.

**CRITICAL BOUNDARY:** The workspace note has a horizontal rule (`---`) separating two zones:
- **Above the rule** — human-authored, durable manifest (tech stack, key paths, conventions, navigation). `/devlog write` MUST NOT modify this content.
- **Below the rule** — agent-maintained session state. `/devlog write` updates only these sections:
  - **Current State** — what was just built, what's merged, what's in-flight
  - **What's Next** — immediate next step
  - **Open Questions** — things that need decisions
  - **Learnings** — novel discoveries (library quirks, patterns, debugging approaches)
  - **Recent Sessions** — keep last 3 session summaries, linked to full logs

If the workspace note does not yet exist, create it from `~/vaults/atlas/System/Templates/_workspace.md` and `~/vaults/atlas/System/Standards/workspace-structure.md`. Fill the above-the-rule sections from the session's discoveries about the repo (tech stack, key paths, conventions) and seed below-the-rule sections from the current session.

### Step 7 — Commit

```text
Bash(command: "git -C \"$HOME/vaults/atlas\" add Log/ System/ Workspaces/ && git -C \"$HOME/vaults/atlas\" commit -m 'vault(dev-log): [GIT_REPO] brief-description' && git -C \"$HOME/vaults/atlas\" push", description: "Commit and push dev log and knowledge updates to atlas vault")
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
- **Learnings go in the workspace note too** — novel discoveries should be in both the log (detailed) and below-the-rule `## Learnings` in `{WorkspaceSlug}.md` (summarized) so future sessions get them without reading every log. Above-the-rule content is off-limits.
