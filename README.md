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

## Recovery

If your shell is broken, see [docs/RECOVERY.md](docs/RECOVERY.md).
