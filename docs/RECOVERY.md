# Shell Recovery Runbook

What to do when a zsh config change breaks new shells. The currently running
shell keeps working — don't close it until you've verified a new one starts
(`bin/zsh-smoke-test`).

## Getting a usable shell

- Local terminal: `zsh -f` (no rc files) or `bash --noprofile --norc`.
- Over SSH (e.g. into valhalla) when zsh is broken at login:

      ssh -t <host> 'bash --noprofile --norc'

  If even that fails: `ssh -t <host> '/bin/sh'`.

## Restoring a known-good zshrc

Every host keeps a dereferenced copy of the last known-good zshrc at
`~/.zshrc.fallback` (refresh it after any *proven* shell change):

    cp -L ~/.zshrc ~/.zshrc.fallback     # refresh (only when shell is healthy)

To recover with it:

    zsh -f
    cp ~/.zshrc.fallback ~/.zshrc.recovered
    ZDOTDIR=$(mktemp -d); cp ~/.zshrc.fallback "$ZDOTDIR/.zshrc"; ZDOTDIR=$ZDOTDIR zsh -i

Note: `~/.zshrc` is normally a stow symlink into `~/dotfiles`. Prefer fixing
the repo (below) over overwriting the symlink.

## Fixing the repo

    cd ~/dotfiles
    git log --oneline -5            # find the last good commit
    git checkout <good-sha>         # or: git revert <bad-sha>
    bin/zsh-smoke-test              # must PASS before you walk away

If stow links are in a bad state, re-apply them (M1+: `bin/dotfiles apply`;
pre-M1: `stow --no-folding -t ~ .` from the repo root).

## Verify before closing your session

    bin/zsh-smoke-test    # PASS required
    zsh -i                # actually open one and look at it
