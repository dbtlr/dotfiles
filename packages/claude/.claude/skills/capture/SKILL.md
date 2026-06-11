---
name: capture
description: Synthesize and capture knowledge from the current session into the atlas vault. Use this skill when the user says "capture", "capture what we learned", "save this to the vault", "write up what we discovered", or asks to distill session learnings into a reusable knowledge artifact. The agent reviews session context, synthesizes key patterns, techniques, and findings, then writes a structured note to the atlas inbox. This is agent-generated knowledge, not raw user capture — for quick personal notes use /til instead.
---

# Capture — Agent-Synthesized Knowledge

Distill what was learned during a session into a structured knowledge note and save it to the atlas vault inbox for later processing.

## Why This Skill Exists

During coding sessions, valuable knowledge gets generated — how a tool works, why an approach was chosen, patterns that would apply to other projects. Without capturing it, this knowledge dies with the session. The agent has full context of what was done and can synthesize it into something reusable.

## Core Workflow

### Step 1: Understand What to Capture

The user describes what to capture. Examples:
- "capture what we learned about setting up Rust release pipelines"
- "capture the approach we used for worktree-based PR workflows"
- "capture how cargo-dist handles workspace releases"

Parse the topic from the user's message. If unclear, ask.

### Step 2: Detect Workspace Context

Determine which Atlas workspace this knowledge came from:

```bash
basename "$(git rev-parse --show-toplevel 2>/dev/null)" || echo "unknown"
```

This becomes the `workspace` relationship field in frontmatter. Normalize to the Atlas workspace slug when obvious (for example `tyr`, `skald`, `vault-memory`, `vault-plugin`, `norn`).

### Step 3: Synthesize from Session Context

Review the current session — what was done, what was learned, what worked, what didn't. Write a structured note that covers:

- **What** — the technique, pattern, or finding
- **Why** — what problem it solves, when to use it
- **How** — concrete steps, commands, configuration
- **Gotchas** — things that tripped us up, edge cases discovered
- **Context** — what workspace this came from, what prompted the discovery

The note should be **self-contained and reusable**. Someone reading it in 6 months (or working on a different project) should be able to follow it without the original session context.

Title the note descriptively — either as a topic ("Rust Release Pipeline with cargo-dist") or a claim ("cargo-dist eliminates manual release workflow configuration").

### Step 4: Write to atlas Inbox

Create the file at `~/vaults/atlas/Inbox/[descriptive-name].md`:

```yaml
---
type: note
created: YYYY-MM-DDTHH:mm
modified: YYYY-MM-DDTHH:mm
domain: Technology
workspace: "[[detected-workspace-slug]]"
source: research
---
```

Use the current timestamp (ISO 8601 with minute precision) for both `created:` and `modified:`. Get it via `date +%Y-%m-%dT%H:%M` — both fields take the same value at creation time.

Follow the frontmatter with the synthesized content. Use `[[wikilinks]]` for concepts that likely connect to existing vault content (workspace names, tools, technologies).

### Step 5: Confirm

Report: "Captured to atlas inbox: [title]"

Brief summary of what was included (2-3 bullet points) so the user can verify it covers what they wanted.

## Important Behaviors

- **Synthesize, don't transcribe.** The value is in the agent's synthesis — extracting the reusable pattern from the specific session context. Don't just dump raw conversation.
- **Be comprehensive but focused.** Cover the topic thoroughly, but don't include unrelated session work.
- **Include concrete details.** Commands, config snippets, file paths — the things you'd need to replicate this.
- **Link to the workspace.** The frontmatter connects this knowledge to its origin workspace, making it findable later. Use `workspace: "[[slug]]"`; if no workspace is clear, omit the field rather than inventing one.
- **Default domain to Development** for coding sessions (patterns, pipelines, frameworks). Use Technology for infrastructure/tooling topics. The user can specify otherwise.
- **No git operations.** Just write the file. atlas's `/inbox` skill handles git when it processes the inbox later.
- **Don't ask unnecessary questions.** The user said what to capture — do it. Only ask if the topic is genuinely ambiguous.
