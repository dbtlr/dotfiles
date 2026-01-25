# Drew's Global Context

## Environment

I use context-aware dotfiles. Check these variables for current environment:
- `$DOTFILES_OS` - "macos" or "linux"
- `$DOTFILES_HOST` - hostname (e.g., "asgard")
- `$DOTFILES_REMOTE` - "ssh" if remote session
- `$DOTFILES_MULTIPLEXER` - "tmux" or "screen" if applicable
- `$DOTFILES_TERMINAL` - "vscode", "blink", "ghostty", "iterm", "terminus", "apple", or "unknown"

## Machine-Specific

@~/.claude/CLAUDE.local.md

## Preferences

- Prefer simple, minimal solutions
- Use existing patterns in the codebase
- No unnecessary abstractions

## Tools I Use

- Editor: nvim
- Shell: zsh (see dotfiles for config)
- Package manager: apt on Linux, brew on macOS (check $DOTFILES_OS)
