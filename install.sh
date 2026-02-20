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

# Ensure zsh is the default shell
current_shell="$(getent passwd "$USER" | cut -d: -f7 2>/dev/null || echo "$SHELL")"
zsh_path="$(command -v zsh || true)"
if [[ -z "$zsh_path" ]]; then
    echo "==> zsh not found; skipping default shell change"
else
    if [[ ! "$current_shell" =~ zsh$ ]]; then
        echo "==> Current shell is $current_shell; attempting to set zsh ($zsh_path) as default..."
        if command -v chsh &>/dev/null; then
            if chsh -s "$zsh_path" "$USER" 2>/dev/null; then
                echo "==> Default shell changed to zsh. Please log out and back in."
            else
                if command -v sudo &>/dev/null && sudo chsh -s "$zsh_path" "$USER"; then
                    echo "==> Default shell changed to zsh (via sudo). Please log out and back in."
                else
                    echo "==> Could not change default shell automatically. Run:"
                    echo "    chsh -s $zsh_path"
                fi
            fi
        else
            echo "==> chsh not available; run: chsh -s $zsh_path"
        fi
    else
        echo "==> zsh is already the default shell."
    fi
fi

echo "==> Done! Restart your shell or run: source ~/.zshrc"
