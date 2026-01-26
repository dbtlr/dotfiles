#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"
echo "==> Installing dotfiles"

# Install stow if missing
if ! command -v stow &>/dev/null; then
    echo "==> Installing GNU Stow..."
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y stow
    elif command -v brew &>/dev/null; then
        brew install stow
    elif command -v pacman &>/dev/null; then
        sudo pacman -S stow
    else
        echo "Error: Please install GNU Stow manually"
        exit 1
    fi
fi

# Backup existing configs
backup_if_exists() {
    if [[ -e "$1" && ! -L "$1" ]]; then
        echo "==> Backing up $1 to $1.backup"
        mv "$1" "$1.backup"
    elif [[ -L "$1" ]]; then
        rm "$1"
    fi
}

echo "==> Backing up existing configs..."
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.p10k.zsh"
backup_if_exists "$HOME/.bashrc"
backup_if_exists "$HOME/.profile"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/tmux/tmux.conf"
backup_if_exists "$HOME/.config/zsh"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.claude"

# Stow packages
cd "$DOTFILES"
for d in */; do
    echo "==> Stowing $(basename "$d")"
    stow "$(basename "$d")"
done

# Install Oh My Zsh if missing
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k if missing
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    echo "==> Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

echo "==> Done! Restart your shell or run: source ~/.zshrc"
