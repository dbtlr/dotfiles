# Drew's Global Context

## Preferences

- Prefer simple, minimal solutions
- Use existing patterns in the codebase
- No unnecessary abstractions

## Tools I Use

- Editor: nvim, vs code
- Shell: zsh (see dotfiles for config)
- Package manager: apt on Linux, brew on macOS (check $DOTFILES_OS)

## How We Work

- **Never push to main.** All work should be done in a branch or worktree and
  pushed as a PR.
- **Small meaningful commits.** Create useful checkpoints on long tasks, that indicate a working point in time.
- **Discuss first, code second.** Align on package boundaries and user-facing
  behavior before large implementation changes.
- **No broken windows.** Fix errors and warnings encountered while working.
- **Not complete until it is verified.** All tasks should have a verification run by an adversarial agent and be presented to a human before it is declared done.

## When Using The Superpowers Plugin / Skills

- **MANDATORY: DO NOT INVOKE SUPERPOWERS AUTOMATICALLY**: Do not load the `use-superpowers` skill unless the user explicit triggers it OR they say something like "Using Superpowers, ...".
- **MANDATORY: DO NOT COMMIT SUPERPOWERS DOCUMENTS**: Superpowers **brainstorm** and **writing-plans** skills create `spec` and `plan` documents. These should be added to the Atlas vault, rather than the direct repo. This helps with viewing the documents and avoids extra documents in the code that go out of date. They should be added to `/Volumes/data/vaults/atlas/artifacts/scratch/`.

## Authoring Guidelines

- **MANDATORY: DO NOT REFERENCE CLAUDE**: When creating commits or pull requests, do not reference Claude, Claude Code, or links to Claude remote control sessions
- **IMPORTANT: DO NOT REFERENCE ATLAS WORKSPACE**: When creating or editting files in a repository, do not reference files or state in the Atlas repository. Similarly, do not reference Atlas files or state in git commits or pull requests.
- **MANDATORY: DO NOT REFERENCE THE USER**: When writing repository files, do not write prose that references the user. Your job is to not write prose about what the user wants, thought, or said, instead you should talk about the durable facts and results in a concise manner.
