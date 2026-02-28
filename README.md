# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

Files live directly under the repo root, mirroring `~`. The `agents/` directory is stowed separately so it doesn't get picked up as project-level Claude config for this repo.

## Installation

### Quick Install

```bash
git clone https://github.com/USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Installs dependencies first, then stows dotfiles, Oh My Zsh, Powerlevel10k, and sets the default shell.

To install dependencies only (no dotfiles stowed):

```bash
./install.sh --deps-only
```

### Manual Install

1. Install GNU Stow:
   ```bash
   sudo apt install stow   # or: brew install stow
   ```

2. Clone and stow:
   ```bash
   git clone https://github.com/USERNAME/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow --no-folding -t ~ .        # main dotfiles
   stow --no-folding -t ~ agents   # claude config
   ```

## Syncing

After the initial install, `dotsync` / `dotunsync` (defined in `.config/zsh/stow.zsh`) restow everything:

```bash
dotsync    # restow all dotfiles
dotunsync  # remove all stow symlinks
```

## Adding New Configs

Just add files mirroring the home directory structure directly under `~/dotfiles/`:

```
~/dotfiles/.config/foo/bar.conf   →   ~/.config/foo/bar.conf
~/dotfiles/.some-tool-rc          →   ~/.some-tool-rc
```

Then run `dotsync` to pick them up.

## Dependencies

Brew packages are declared in `Brewfile` at the repo root — this is the canonical list. To install standalone:

```bash
brew bundle --file=~/dotfiles/Brewfile
```

Other dependencies:

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [fnm](https://github.com/Schniz/fnm) (Node version manager)
- [Neovim](https://neovim.io/) (0.9+)
