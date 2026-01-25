# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Description |
|---------|-------------|
| `zsh`   | Zsh config with Oh My Zsh and Powerlevel10k |
| `bash`  | Bash config |
| `nvim`  | Neovim config with lazy.nvim |
| `tmux`  | Tmux config |
| `git`   | Git config |

## Installation

### Quick Install

```bash
git clone https://github.com/USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Manual Install

1. Install GNU Stow:
   ```bash
   sudo apt install stow
   ```

2. Clone and stow:
   ```bash
   git clone https://github.com/USERNAME/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow zsh bash nvim tmux git
   ```

## Adding New Configs

1. Create package directory: `mkdir -p ~/dotfiles/package`
2. Mirror home directory structure inside package
3. Move config files to package
4. Run `stow package`

## Dependencies

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [fnm](https://github.com/Schniz/fnm) (Node version manager)
- [Neovim](https://neovim.io/) (0.9+)
