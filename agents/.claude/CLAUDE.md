# Drew's Global Context

## Core Development Principles

**DISCUSS FIRST, CODE SECOND**: Every implementation begins with discussion. No exceptions.

### MANDATORY: Load Partner Model First

**Before doing ANYTHING else** — before reading Linear issues, before exploring code, before any task work — load `~/vaults/agents/knowledge/partner_model.md`. This file contains collaboration patterns, communication preferences, and calibration notes that make sessions more effective. Skipping this wastes time through miscommunication and missed context.

### MANDATORY: Dev-Log is Always Active

Dev-log is always on. You do not need to be asked. Write a dev log when **any** of these milestones occur:

- **Task completion** — a feature, bugfix, refactor, or investigation is finished
- **Session wrap-up** — user signals they're done ("that's all", "good session", "wrap up", "done for now")
- **Context approaching limits** — write before you lose context of what was done
- **Repo switch** — switching to a different git repo mid-session; log the previous work first
- **Explicit request** — user says "dev log", "write a log", "document this"

**Do not ask permission.** Do not wait for a prompt. When a milestone hits, run the `/dev-log` skill workflow.

Logs go to `~/vaults/agents/log/`. Use `/dev-log` or say "write a dev log" to trigger manually.

## Preferences

- Prefer simple, minimal solutions
- Use existing patterns in the codebase
- No unnecessary abstractions

## Tools I Use

- Editor: nvim
- Shell: zsh (see dotfiles for config)
- Package manager: apt on Linux, brew on macOS (check $DOTFILES_OS)
