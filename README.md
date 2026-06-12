# Dotfiles

Self-converging dotfiles for valhalla (macOS), DB-MBP (macOS), and asgard
(Ubuntu). Configs are [GNU Stow](https://www.gnu.org/software/stow/) packages
symlinked into `~`; `bin/dot` is the single CLI; schedulers keep every host
synced with origin and upgraded without manual ceremony.

`dot` was named `dotfiles` before M6 — `bin/dotfiles` remains as a shim, so
muscle memory and old scheduler renders keep working.

## Fresh machine

```bash
git clone --recurse-submodules https://github.com/dbtlr/dotfiles.git ~/dotfiles
~/dotfiles/bin/dot install
exec zsh
```

`install` is idempotent: brew/apt manifests, mise tools, stow apply, default
shell, and — the conscious key-turn — the schedulers. From that point the
machine auto-commits and syncs every 30 minutes; don't run it until the tree
is in a state you're happy to commit.

## The `dot` CLI

| Verb | What it does |
|---|---|
| `dot install` | Bootstrap everything: packages (brew/apt), mise, stow, schedulers (idempotent) |
| `dot apply` | Stow all packages into `~`, render starship + init caches (restow-safe) |
| `dot doctor` | Offline health check: tools, symlinks, fallback, schedulers, divergence |
| `dot upgrade` | Upgrade deps; `--auto` runs only the unattended (no-sudo, no-cask) bucket |
| `dot sync` | Converge with origin (below); `--auto` skips when you edited <30 min ago |
| `dot status` | Machine status from `state/`; `--motd` is the daily shell banner |

**The converge loop (`dot sync`):** commit local changes → fetch → smoke-gate
any unpushed work (a broken local commit never propagates) → pull --rebase →
push → apply + manifest installs → interactive-zsh smoke test. If a pulled
commit breaks the shell, sync auto-reverts `main` to the pre-pull commit,
re-applies, and **quarantines** the bad origin tip: every later run refuses to
re-pull it (red MOTD re-asserts instead of revert-thrashing) until origin
moves to a fix — pushed from any host — at which point the machine
un-quarantines itself. Local commits made during quarantine stay on `main`
and push once the fix lands. Rebase conflicts abort untouched and go red for
manual resolution.

**MOTD:** `.zshrc` runs `dot status --motd` at startup — instant, it only
reads `state/` files written by background runs. All-green shows once per
day (debounced); red-class problems (failed/stale upgrade, sync
conflict/revert/broken) bypass the debounce and show every shell until fixed.

## Layout

```
bin/        dot (the CLI), dotfiles (shim), zsh-smoke-test, zsh-bench, test-sync
packages/   stow packages: shell, git, nvim, tmux, starship, mise, mise-linux (Linux only), bash, claude
manifests/  Brewfile (macOS), apt-packages.txt + 50unattended-upgrades (Ubuntu)
vendor/     zsh plugin submodules (autosuggestions, syntax-highlighting, completions)
schedulers/ launchd plist + systemd unit templates, rendered/enabled by `dot install`
state/      gitignored machine-local: last-sync/upgrade, quarantine, init caches, logs
docs/       RECOVERY.md — broken-shell runbook
```

Schedulers run `sync --auto` every 30 min and `upgrade --auto` daily at 06:30,
logging to `state/log/` (self-trimmed at 512KB). Zsh startup sources cached
tool inits (`state/init/*.zsh`, rendered by `dot apply`/`upgrade`) instead of
forking brew/mise/zoxide/starship every shell.

## Per-host config

- **Prompt:** `dot apply` renders `~/.config/starship.toml` from
  `packages/starship/.config/starship/base.toml` + `hosts/<host>.toml`. New
  host: add a `hosts/<host>.toml` palette fragment (copy an existing one,
  change the accent colors); no fragment = base config.
- **Shell:** `00-context.zsh` detects OS/host/terminal and sources
  `os/<os>.zsh`, `hosts/<host>.zsh`, `terminals/<terminal>.zsh` from
  `packages/shell/.config/zsh/` — all optional.
- **MOTD accent:** host colors live in `cmd_status` in `bin/dot`.

## Secrets

Nothing secret is tracked. `*.local.zsh` is gitignored: drop machine-local
exports in `packages/shell/.config/zsh/00-env.local.zsh`, run `dot apply` to
stow it, and the `.zshrc` glob sources it like any other module — sync's
`git add -A` never picks it up. Future seam: render it via 1Password
(`op inject`) instead of hand-copying.

## Safety tooling

```bash
bin/zsh-smoke-test    # interactive zsh starts + exits cleanly (sync's gate)
bin/zsh-bench         # hyperfine startup benchmark -> state/ (target ~95ms)
bin/test-sync         # full sync integration suite in a throwaway sandbox
```

`test-sync` builds a bare origin + two clones with fake `$HOME`s and runs the
real CLI through propagation, conflict, auto-revert, quarantine, lock, and
propagation-block scenarios. It never touches your real home directory.

## Recovery

Shell broken? See [docs/RECOVERY.md](docs/RECOVERY.md). Short version: get a
shell with `zsh -f` (or `ssh -t <host> 'bash --noprofile --norc'`), restore
from `~/.zshrc.fallback`, fix the repo, and `bin/zsh-smoke-test` must PASS
before you walk away. Refresh the fallback after any proven change:
`cp -L ~/.zshrc ~/.zshrc.fallback` (doctor nags when it's missing or stale).
