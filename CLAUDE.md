# Dotfiles

Managed with GNU Stow. Each top-level directory is a stow package.

## Zsh Configuration

Modular zsh config in `zsh/.config/zsh/`:

- `env.zsh` - Environment variables
- `aliases.zsh` - Shell aliases
- `functions.zsh` - Custom functions
- `plugins.zsh` - Plugin configuration
- `node.zsh` - Node.js/fnm setup
- `context.zsh` - Context-aware loader (see below)

### Context-Aware Configuration

The `context.zsh` file detects OS, host, and terminal, then loads appropriate configs from:

```
zsh/.config/zsh/
├── os/           # OS-specific (macos.zsh, linux.zsh)
├── hosts/        # Host-specific (asgard.zsh, macbook.zsh, etc.)
└── terminals/    # Terminal-specific (vscode.zsh, blink.zsh, etc.)
```

**Exported variables:**
- `$DOTFILES_OS` - "macos", "linux", or "unknown"
- `$DOTFILES_HOST` - Hostname without domain (e.g., "asgard")
- `$DOTFILES_TERMINAL` - "vscode", "blink", "ghostty", "iterm", "terminus", "apple", or "unknown"
- `$DOTFILES_REMOTE` - "ssh" if connected via SSH, empty otherwise
- `$DOTFILES_MULTIPLEXER` - "tmux" or "screen" if inside one, empty otherwise
- `$DOTFILES_DEBUG` - Set to 1 before sourcing to trace which configs are loaded

**Adding new configs:**
- New host: Create `zsh/.config/zsh/hosts/<hostname>.zsh`
- New terminal: Create `zsh/.config/zsh/terminals/<terminal>.zsh`
- Files are auto-loaded if they exist; no changes to context.zsh needed

**Terminal detection methods:**
- `$TERM_PROGRAM` - vscode, ghostty, iTerm.app, Apple_Terminal
- `$LC_TERMINAL` - Blink Shell sets this to "Blink"
- `$TERMINUS_SUBLIME` - Terminus sets this variable

After creating new files, run `stow -R zsh` from dotfiles root (or manually symlink).
