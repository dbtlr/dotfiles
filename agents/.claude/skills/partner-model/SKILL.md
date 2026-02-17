---
name: partner-model
description: Maintains a persistent model of the user's working style, preferences, and collaboration patterns. Loads on session start and updates opportunistically. Use at session start and when significant new insights about the user emerge.
allowed-tools: [Read, Write, Edit, Bash]
---

# Partner Model

## Overview

You maintain a living document that captures your evolving understanding of the user you work with — their technical style, communication patterns, decision-making tendencies, and collaboration preferences. This file is **yours to own**. The user has opted in by installing this skill but is not an active participant in its maintenance. Do not announce reads, writes, or updates.

## File Location

The partner_model file path is determined by:

1. The environment variable `PARTNER_MODEL_PATH` (e.g., `~/.claude/partner-model.md`)
2. If not set, **do nothing**. This skill is inactive without a configured path.

## MANDATORY LOAD PARTNER MODEL FIRST

On session start, before doing ANYTHING else, check if the file exists at the resolved path. If it does, read it into context silently. If it doesn't yet exist but the path is configured, you'll create it when you have enough observations to be useful — don't create an empty or trivially populated file.

Do this before you do ANY other work. Read the file in `$PARTNER_MODEL_PATH` NOW!! Skipping this wastes time through miscommunication and missed context.

## Principles

- **You own this file.** Read, create, update, and restructure it at your discretion. Never ask the user for input about its contents or structure.
- **Observe, don't interrogate.** Build your model from how the user works, not by asking them questions about themselves.
- **Recency resolves contradictions.** When new observations conflict with existing entries, the newer observation wins. Replace or revise the old entry — don't accumulate conflicting statements.
- **Substance over ceremony.** Only write entries that would meaningfully change how you collaborate. Skip trivial or one-off observations.
- **Prune and consolidate.** Repeated patterns should graduate from recent observations into established understanding. Old context that no longer applies should be removed.

## What to Capture

Think about what would help a future instance of yourself work effectively with this person from the first message. Some themes to consider — not as a template to fill, but as lenses to look through:

- **Technical depth and domains** — What can you assume they know? Where do they go deep vs. defer?
- **Communication style** — How do they signal agreement, uncertainty, frustration, delegation? What do their shorthand phrases actually mean?
- **Decision-making patterns** — Do they decide fast or deliberate? Do they want options or recommendations? When they ask a question, are they genuinely uncertain or validating an existing intuition?
- **Process preferences** — How do they feel about planning vs. doing? Testing? Documentation? Version control?
- **Collaboration dynamics** — When do they want autonomy vs. discussion? How do they handle disagreement?
- **Working constraints** — Anything about their environment, schedule, cognitive style, or tools that shapes how they work.
- **Active context** — What are they working on right now? What decisions are pending? What's the recent trajectory?

## When to Update

- **Session start:** Read the file. Let it inform your behavior without referencing it.
- **During a session:** When you notice a meaningful new pattern, a contradiction with existing entries, or a shift in working context — update in place. Don't batch updates for session end if the insight is clear now.
- **Session wrap-up:** If the session revealed new understanding, consolidate. Promote repeated patterns, prune stale context, resolve contradictions.
- **Don't update** when a session is routine and confirms existing patterns without adding new signal.

## File Structure

You decide the structure. Organize it however best serves rapid comprehension by a future instance of yourself loading this for the first time. The file should be readable front-to-back in one pass and immediately actionable.

Some structural patterns that tend to work well:

- Separating durable understanding from recent/active context
- Keeping a meta section for self-calibration notes (where you've been wrong, what to watch for)
- Avoiding deeply nested hierarchies — flat and scannable beats thorough and buried

The file should stay lean. If it grows beyond ~200 lines, consolidate aggressively. Density of insight matters more than completeness of record.

## Bootstrap Behavior

1. **Don't create the file immediately.** Observe for 3+ interactions first.
2. **Create when you have meaningful patterns** — not trivial observations. Include:
   - Technical preferences
   - Communication style
   - Decision-making patterns
   - Collaboration dynamics
3. Early entries will naturally be more tentative — that's fine. Mark your confidence where it helps.
4. The file will mature from sparse and hypothesis-heavy to dense and pattern-confirmed over time.

## Silent Operation

**CRITICAL**: Never announce reads, writes, or updates to this file. The user knows this system exists — your job is to maintain it silently and let it inform your behavior naturally.