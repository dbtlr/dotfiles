# Drew's Global Context

## Preferences

- Prefer simple, minimal solutions
- Use existing patterns in the codebase
- No unnecessary abstractions

## Tools I Use

- Editor: nvim, vs code
- Shell: zsh (see dotfiles for config)
- Package manager: apt on Linux, brew on macOS (check $DOTFILES_OS)
- Worktree manager: `wt` (Worktrunk) - use the `/worktrunk` skill when working with git worktrees

## How We Work

- **Never push to main.** All work should be done in a branch or worktree and
  pushed as a PR.
- **Small meaningful commits.** Create useful checkpoints on long tasks, that indicate a working point in time.
- **Discuss first, code second.** Align on package boundaries and user-facing
  behavior before large implementation changes.
- **No broken windows.** Fix errors and warnings encountered while working.
- **Not complete until it is verified.** All tasks should have a verification run by an adversarial agent and be presented to a human as a PR before a task is filed as completed.
- **Main agent orchestrates.** The main agent's job is to orchestrate work with other models. This is done both to control costs, as well as to preserve context.

## Authoring Guidelines

- **MANDATORY: DO NOT REFERENCE CLAUDE**: When creating commits or pull requests, do not reference Claude, Claude Code, or links to Claude remote control sessions
- **IMPORTANT: DO NOT REFERENCE ATLAS WORKSPACE**: When creating or editting files in a repository, do not reference files or state in the Atlas repository. Similarly, do not reference Atlas files or state in git commits or pull requests.
- **MANDATORY: DO NOT REFERENCE THE USER**: When writing repository files, do not write prose that references the user. Your job is to not write prose about what the user wants, thought, or said, instead you should talk about the durable facts and results in a concise manner.
- **MANDATORY: DO NOT REFERENCE LOCAL PATHS**: When writing code and test harnesses, do not include links it local paths. Assume these to be configurable instead and use mock paths in tests.

## Model Orchestration

**Route by verifiability, escalate on failure.** Cheaply verifiable (tests exist, diff
reviewable in a minute) → cheapest model that can do it. Model must guarantee quality
itself → route up. Never start at the top tier; escalate when a cheaper tier
demonstrably fails. On Max, tokens are rate-limit budget: Fable burns ~5x Sonnet.

| Role | Model | Default effort |
|---|---|---|
| Orchestrate: shape, decompose, delegate, judge summaries | Fable 5 or Opus 4.8 | high |
| Execute autonomously from a plan; deep debugging; substantive review | Opus 4.8 | high |
| Scoped, mechanical, verifiable tasks; exploration for the orchestrator | Sonnet 5 | medium |

Hard rules (always apply):
- Protect the orchestrator's context: subagents explore and return summaries — never
  transcripts or file dumps.
- Every delegation ships scope, acceptance criteria, and a return format. Can't state
  the acceptance criteria → not scoped enough to delegate; groom it first.
- A diff is never a Fable input. Fable reviews designs and architecture; Opus reviews code.
- Security-adjacent work goes straight to Opus (Fable reroutes it anyway).
- Escalation: Sonnet fails twice → Opus with failure notes → re-scope. A well-scoped
  task failing at Opus means the scoping is wrong, not the model.
- Effort moves cost more than model choice. Don't crank Sonnet to max — move up a tier.
  Don't start high "to be safe."

## Code Reviews

**INPORTANT**: The built in code review workflow pins to the current model. Never run code reviews with the `fable` model. Instead, **explicitly pin the code-review workflow to either an `opus` model, or lower if the task is more mechanical**.

- Before any task completes and it is pushed as a PR, run an adversarial review against it.