# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Configs live as stow packages under `packages/`, and `bin/dotfiles` is the CLI that installs, applies, and checks them. A full rewrite of these configs comes in M6 — for now this is the same setup, restructured.

## Installation

```bash
git clone --recurse-submodules https://github.com/dbtlr/dotfiles.git ~/dotfiles
~/dotfiles/bin/dotfiles install
```

## Day-to-day

```bash
dotfiles apply    # restow all packages into ~ (or use the dotsync alias)
dotfiles doctor   # check tools, symlinks, and default shell
```

## asgard catch-up (when it's back online)

asgard went down before M1 landed, so it's still on the pre-rebuild layout.
Bring it current in one sitting — order matters: the unstow needs the OLD
layout, which `git pull` destroys.

```bash
cd ~/dotfiles
bin/zsh-smoke-test                       # confirm healthy starting point
stow --no-folding -t ~ -D .              # unstow the old layout
stow --no-folding -t ~ -D agents
git pull
[ -f .config/zsh/00-env.local.zsh ] && mv .config/zsh/00-env.local.zsh packages/shell/.config/zsh/
[ -f .config/nvim/lazy-lock.json ] && mv .config/nvim/lazy-lock.json packages/nvim/.config/nvim/
find .config -type d -empty -delete 2>/dev/null || true
git submodule update --init --depth 1
bin/dotfiles install                     # apt manifest + unattended-upgrades + mise + schedulers
bin/dotfiles doctor
bin/zsh-smoke-test
rm -rf ~/.oh-my-zsh
cp -L ~/.zshrc ~/.zshrc.fallback         # refresh the escape hatch
```

Note: `install` enables the systemd user timers (`dotfiles-sync.timer`,
`dotfiles-upgrade.timer`). Sync auto-commits the working tree every 30
minutes from that point — make sure the tree is in a state you're happy to
commit before walking away.

## Recovery

If your shell is broken, see [docs/RECOVERY.md](docs/RECOVERY.md).
