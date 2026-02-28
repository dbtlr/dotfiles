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

install_brew_pkg() {
  local pkg_name="$1"
  local alt_name="${2:-$1}"
  if command_exists "$alt_name"; then
    print_skip "$pkg_name"
    return 0
  fi
  brew install "$pkg_name" || { print_error "Failed to install $pkg_name"; return 1; }
  print_success "$pkg_name installed"
}

install_deps() {
  echo ""
  echo "========================================"
  echo "      Dotfiles Dependencies Installer"
  echo "========================================"
  echo ""

  if ! command_exists brew; then
    print_header "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && {
      print_success "Homebrew installed"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
      sudo dnf group install "development tools" -y
    } || { print_error "Failed to install Homebrew"; }
  else
    print_skip "homebrew"
  fi

  echo -e "${GREEN}Installing Essential Tools...${NC}"
  install_brew_pkg "bundler-completion"
  install_brew_pkg "stow"
  install_brew_pkg "git"
  install_brew_pkg "curl"
  install_brew_pkg "wget"
  install_brew_pkg "perl"
  install_brew_pkg "openssl"
  install_brew_pkg "pkg-config"
  echo ""

  echo -e "${GREEN}Installing Core System Tools...${NC}"
  install_brew_pkg "zsh"
  install_brew_pkg "neovim" "nvim"
  install_brew_pkg "tree"
  install_brew_pkg "jq"
  install_brew_pkg "htop"
  install_brew_pkg "postgresql@15" "psql"
  install_brew_pkg "bat"
  install_brew_pkg "fd"
  install_brew_pkg "fzf"
  install_brew_pkg "zoxide" "z"
  install_brew_pkg "gh"
  install_brew_pkg "rust"
  echo ""

  echo -e "${GREEN}Installing Node.js & JavaScript Tools...${NC}"
  install_brew_pkg "fnm"
  if command_exists fnm; then
    fnm install --lts --log-level=quiet && \
      fnm alias default lts && \
      print_success "Node.js LTS installed" || \
      print_error "Failed to install Node.js LTS"
  else
    print_error "Cannot install LTS node, fnm not installed"
  fi
  if ! command_exists pnpm; then
    print_header "Installing pnpm"
    if command_exists npm; then
      npm install -g pnpm && print_success "pnpm installed" || print_error "Failed to install pnpm"
    else
      print_error "pnpm requires npm. Install Node.js first."
    fi
  else
    print_skip "pnpm"
  fi
  echo ""

  brew tap oven-sh/bun
  install_brew_pkg "bun"
  echo ""

  echo -e "${GREEN}Installing Python Tools...${NC}"
  install_brew_pkg "python3"
  install_brew_pkg "uv"
  echo ""

  echo -e "${GREEN}Installing Optional Development Tools...${NC}"
  install_brew_pkg "mosh"
  install_brew_pkg "tmux"
  install_brew_pkg "zellij"
  install_brew_pkg "agent-browser"
  install_brew_pkg "powerlevel10k"
  echo ""

  echo -e "${GREEN}Installing AI Tools...${NC}"
  install_brew_pkg "codex"
  install_brew_pkg "gemini-cli" "gemini"
  install_brew_pkg "anomalyco/tap/opencode" "opencode"
  if ! command_exists claude; then
    print_header "Installing Claude"
    curl -fsSL https://claude.ai/install.sh | bash && \
      print_success "Claude Code installed" || \
      print_error "Failed to install Claude Code"
  else
    print_skip "claude"
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

  print_header "Backing up existing configs..."
  backup_if_exists "$HOME/.zshrc"
  backup_if_exists "$HOME/.p10k.zsh"
  backup_if_exists "$HOME/.bashrc"
  backup_if_exists "$HOME/.profile"
  backup_if_exists "$HOME/.config/nvim"
  backup_if_exists "$HOME/.config/tmux"
  backup_if_exists "$HOME/.config/zsh"
  backup_if_exists "$HOME/.gitconfig"
  backup_if_exists "$HOME/.claude"

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
