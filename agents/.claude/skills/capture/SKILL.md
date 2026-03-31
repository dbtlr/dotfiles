---
name: capture
description: Synthesize and capture knowledge from the current session into the Life Lab vault. Use this skill when the user says "capture", "capture what we learned", "save this to the vault", "write up what we discovered", or asks to distill session learnings into a reusable knowledge artifact. The agent reviews session context, synthesizes key patterns, techniques, and findings, then writes a structured note to the Life Lab inbox. This is agent-generated knowledge, not raw user capture — for quick personal notes use /til instead.
---

# Capture — Agent-Synthesized Knowledge

Distill what was learned during a session into a structured knowledge note and save it to the Life Lab vault inbox for later processing.

## Why This Skill Exists

During coding sessions, valuable knowledge gets generated — how a tool works, why an approach was chosen, patterns that would apply to other projects. Without capturing it, this knowledge dies with the session. The agent has full context of what was done and can synthesize it into something reusable.

## Core Workflow

### Step 1: Understand What to Capture

The user describes what to capture. Examples:
- "capture what we learned about setting up Rust release pipelines"
- "capture the approach we used for worktree-based PR workflows"
- "capture how cargo-dist handles workspace releases"

Parse the topic from the user's message. If unclear, ask.

### Step 2: Detect Project Context

Determine which project this knowledge came from:

```bash
basename "$(git rev-parse --show-toplevel 2>/dev/null)" || echo "unknown"
```

This becomes the `project` field in frontmatter.

### Step 3: Synthesize from Session Context

Review the current session — what was done, what was learned, what worked, what didn't. Write a structured note that covers:

- **What** — the technique, pattern, or finding
- **Why** — what problem it solves, when to use it
- **How** — concrete steps, commands, configuration
- **Gotchas** — things that tripped us up, edge cases discovered
- **Context** — what project this came from, what prompted the discovery

The note should be **self-contained and reusable**. Someone reading it in 6 months (or working on a different project) should be able to follow it without the original session context.

Title the note descriptively — either as a topic ("Rust Release Pipeline with cargo-dist") or a claim ("cargo-dist eliminates manual release workflow configuration").

### Step 4: Write to Life Lab Inbox

Create the file at `~/data/vaults/Life Lab/Inbox/[descriptive-name].md`:

```yaml
---
type: note
created: YYYY-MM-DD
domain: Technology
project: [detected project name]
source: research
---
```

Follow the frontmatter with the synthesized content. Use `[[wikilinks]]` for concepts that likely connect to existing vault content (project names, tools, technologies).

### Step 5: Confirm

Report: "Captured to Life Lab inbox: [title]"

Brief summary of what was included (2-3 bullet points) so the user can verify it covers what they wanted.

## Important Behaviors

- **Synthesize, don't transcribe.** The value is in the agent's synthesis — extracting the reusable pattern from the specific session context. Don't just dump raw conversation.
- **Be comprehensive but focused.** Cover the topic thoroughly, but don't include unrelated session work.
- **Include concrete details.** Commands, config snippets, file paths — the things you'd need to replicate this.
- **Link to the project.** The frontmatter connects this knowledge to its origin project, making it findable later.
- **Default domain to Development** for coding sessions (patterns, pipelines, frameworks). Use Technology for infrastructure/tooling topics. The user can specify otherwise.
- **No git operations.** Just write the file. Life Lab's `/inbox` skill handles git when it processes the inbox later.
- **Don't ask unnecessary questions.** The user said what to capture — do it. Only ask if the topic is genuinely ambiguous.
