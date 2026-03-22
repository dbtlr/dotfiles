#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

print_header() { echo -e "${GREEN}==> $1${NC}"; }
print_skip()   { echo -e "${YELLOW}↷  $1 (already installed)${NC}"; }
print_error()  { echo -e "${RED}✗  $1${NC}"; }
print_success() { echo -e "${GREEN}✓  $1${NC}"; }
command_exists() { command -v "$1" &>/dev/null; }

install_deps() {
  echo ""
  echo "========================================"
  echo "      Dotfiles Dependencies Installer"
  echo "========================================"
  echo ""

  # Bootstrap Homebrew
  if ! command_exists brew; then
    print_header "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && {
      print_success "Homebrew installed"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
      sudo dnf group install "development tools" -y
    } || { print_error "Failed to install Homebrew"; }
  else
    print_skip "homebrew"
  fi

  # Install all brew packages
  print_header "Installing packages via Brewfile..."
  brew bundle --file="$DOTFILES/Brewfile"

  # pnpm
  if ! command_exists pnpm; then
    if command_exists npm; then
      npm install -g pnpm && print_success "pnpm installed" || print_error "Failed to install pnpm"
    else
      print_error "pnpm requires npm — install Node first"
    fi
  else
    print_skip "pnpm"
  fi

  echo ""
  echo "========================================"
  echo "         Dependencies Installed!"
  echo "========================================"
  echo ""
}

install_dots() {
  print_header "Installing dotfiles"

  # Install stow if missing
  if ! command_exists stow; then
    print_header "Installing GNU Stow..."
    if command_exists apt; then
      sudo apt update && sudo apt install -y stow
    elif command_exists brew; then
      brew install stow
    elif command_exists pacman; then
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

  # Stow dotfiles
  cd "$DOTFILES"
  print_header "Stowing dotfiles..."
  stow --no-folding -t ~             .        # main dotfiles
  stow --no-folding -t ~ -d "$DOTFILES" agents  # claude config

  # Install Oh My Zsh if missing
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_header "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # Install Powerlevel10k if missing
  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ ! -d "$P10K_DIR" ]]; then
    print_header "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  fi

  # Ensure zsh is the default shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7 2>/dev/null || echo "$SHELL")"
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    echo "==> zsh not found; skipping default shell change"
  else
    if [[ ! "$current_shell" =~ zsh$ ]]; then
      print_header "Current shell is $current_shell; attempting to set zsh ($zsh_path) as default..."
      if command_exists chsh; then
        if chsh -s "$zsh_path" "$USER" 2>/dev/null; then
          echo "==> Default shell changed to zsh. Please log out and back in."
        else
          if command_exists sudo && sudo chsh -s "$zsh_path" "$USER"; then
            echo "==> Default shell changed to zsh (via sudo). Please log out and back in."
          else
            echo "==> Could not change default shell automatically. Run: chsh -s $zsh_path"
          fi
        fi
      else
        echo "==> chsh not available; run: chsh -s $zsh_path"
      fi
    else
      echo "==> zsh is already the default shell."
    fi
  fi

  print_success "Done! Restart your shell or run: source ~/.zshrc"
}

if [[ "$1" == "--deps-only" ]]; then
  install_deps
else
  install_deps
  install_dots
fi
