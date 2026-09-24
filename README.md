# Dotfiles

> **Archived.** The [fleet](https://github.com/dbtlr/fleet) repository now manages
> every configuration domain this repository managed. Nothing here is applied to any machine.

Self-converging dotfiles for valhalla and DB-MBP (macOS); `dot install` also
supports Ubuntu hosts through apt. Configs are
[GNU Stow](https://www.gnu.org/software/stow/) packages symlinked into `~`;
`bin/dot` is the single CLI; a scheduler keeps every host synced with origin
without manual ceremony.

`dot` was named `dotfiles` before M6 — `bin/dotfiles` remains as a shim, so
muscle memory and old scheduler renders keep working.

Homebrew formulae, casks, and mise tools are owned by the fleet repository
(`fleet packages <system> ...`, `fleet upgrade`), not by dotfiles. The shell
domain (zsh, bash, `.profile`, and the prompt) is owned by the fleet
repository too.

## Fresh machine

```bash
git clone https://github.com/dbtlr/dotfiles.git ~/dotfiles
~/dotfiles/bin/dot install
```

`install` is idempotent: Homebrew and stow bootstrap (macOS) or apt manifests
(Linux), stow apply, and — the conscious key-turn — the sync scheduler. From
that point the machine auto-commits and syncs every 30 minutes; don't run it
until the tree is in a state you're happy to commit.

## The `dot` CLI

| Verb | What it does |
|---|---|
| `dot install` | Bootstrap Homebrew/stow (macOS) or apt (Linux), stow, scheduler (idempotent) |
| `dot apply` | Stow all packages into `~` (restow-safe) |
| `dot doctor` | Offline health check: tools, symlinks, scheduler, divergence |
| `dot sync` | Converge with origin (below); `--auto` skips when you edited <30 min ago |
| `dot status` | Last sync result from `state/` |

**The converge loop (`dot sync`):** commit local changes → fetch →
pull --rebase → push → apply if the pull moved `HEAD`. Rebase conflicts abort
untouched and go red for manual resolution; an unreachable origin is a yellow
note and the next run retries.

## Layout

```
bin/        dot (the CLI), dotfiles (shim), test-sync
packages/   stow packages: ccstatusline, git, homebrew, nvim, tmux, worktrunk
manifests/  apt-packages.txt + 50unattended-upgrades (Ubuntu)
schedulers/ launchd plist + systemd unit templates, rendered/enabled by `dot install`
state/      gitignored machine-local: last-sync, run lock, logs
```

The scheduler runs `sync --auto` every 30 min, logging to `state/log/`
(self-trimmed at 512KB).

## Per-host packages

`packages_for_host` in `bin/dot` selects the packages to stow. Every package
applies everywhere except `homebrew`, which is macOS-only.

## Secrets

Nothing secret is tracked.

## Tests

```bash
bin/test-sync         # full sync integration suite in a throwaway sandbox
```

`test-sync` builds a bare origin + two clones with fake `$HOME`s and runs the
real CLI through propagation, quiet-period, conflict, offline, and lock
scenarios. It never touches your real home directory.
