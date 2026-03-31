---
name: til
description: Quick "Today I Learned" capture to the Life Lab vault. Use this skill when the user says "til", "TIL", "today I learned", or shares a quick learning, tip, or discovery they want to remember. This is fast personal capture — the user's words go straight to the vault inbox with minimal processing. For agent-synthesized knowledge writeups, use /capture instead.
---

# TIL — Today I Learned

Quick-capture a learning to the Life Lab vault inbox. Your words, minimal processing, into the vault.

## Why This Skill Exists

Mid-session discoveries — a useful command, a surprising behavior, a neat trick — deserve to be saved without breaking flow. TIL is the fastest path from "huh, that's interesting" to a persistent note in your knowledge system.

## Core Workflow

### Step 1: Parse Input

The user provides what they learned, usually inline:
- "til: cargo-dist init auto-generates GitHub Actions workflows"
- "til bge-m3 embeddings are 1024-dim and run great on M4"
- "til you can use `git worktree list` to see all active worktrees"

Take their words as-is. Don't rewrite or reformat their phrasing.

### Step 2: Detect Project Context

```bash
basename "$(git rev-parse --show-toplevel 2>/dev/null)" || echo "unknown"
```

### Step 3: Optional Enrichment

If the agent has relevant session context that would make the TIL more useful, propose additions using AskUserQuestion:

- Show the user's original text
- Show what the agent would add (e.g., the command that was run, config that was changed, why it matters, related context from the session)
- Present as a yes/no: "Want me to add some context from our session?"

**If yes:** Append the agent's additions below the user's text, clearly separated.

**If no:** Save the user's words only. Don't delay — write immediately.

**Skip enrichment entirely if:**
- The TIL is already detailed enough (3+ sentences)
- The agent has no meaningful context to add
- The learning is self-explanatory ("til: `cmd+shift+p` opens command palette")

### Step 4: Write to Life Lab Inbox

Create the file at `~/data/vaults/Life Lab/Inbox/TIL - [short-title].md`:

```yaml
---
type: note
created: YYYY-MM-DD
domain: Technology
project: [detected project name]
source: conversation
---

# TIL: [user's learning]

[user's text, preserved as-is]

[--- agent context below, if approved ---]
```

Generate a short title from the user's text (5-8 words max) for the filename.

### Step 5: Confirm

"TIL saved to Life Lab inbox."

One line. Don't over-report.

## Important Behaviors

- **Speed over ceremony.** This skill exists to be fast. Two seconds from invocation to confirmation.
- **Preserve the user's words.** Never rewrite what they said. Agent additions go below, clearly marked.
- **Enrichment is optional, not mandatory.** Don't always ask — only when you genuinely have useful context to add. If in doubt, skip enrichment and just save.
- **One TIL per invocation.** If they give you multiple, save multiple files.
- **Default domain to Technology.** Most TILs from coding sessions are tech.
- **No git operations.** Write the file, that's it. `/inbox` handles the rest later.
- **Don't overthink the title.** "TIL - cargo-dist generates install scripts.md" is fine. It doesn't need to be a claim or a perfect note title — `/inbox` can rename later.
