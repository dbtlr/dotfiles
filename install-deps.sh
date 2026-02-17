#!/usr/bin/env bash
set -e

# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# Helper functions
print_header() {
  echo -e "${GREEN}==> $1${NC}"
}

print_skip() {
  echo -e "${YELLOW}↷  $1 (already installed)${NC}"
}

print_error() {
  echo -e "${RED}✗  $1${NC}"
}

print_success() {
  echo -e "${GREEN}✓  $1${NC}"
}

command_exists() {
  command -v "$1" &>/dev/null
}

install_brew() {
  local pkg_name="$1"
  local alt_name="${2:-$1}"

  if command_exists "$alt_name"; then
    print_skip "$pkg_name"
    return 0
  fi

  brew install "$pkg_name" || {
    print_error "Failed to install $pkg_name"
    return 1
  }

  print_success "$pkg_name installed"
}

main() {
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
    } || {
      print_error "Failed to install Homebrew"
    }
  else
    print_skip "homebrew"
  fi

  # === ESSENTIAL TOOLS ===
  echo -e "${GREEN}Installing Essential Tools...${NC}"
  install_brew "bundler-completion"
  install_brew "stow"
  install_brew "git"
  install_brew "curl"
  install_brew "wget"
  install_brew "perl"
  install_brew "openssl"
  install_brew "pkg-config"
  echo ""

  # === CORE SYSTEM TOOLS ===
  echo -e "${GREEN}Installing Core System Tools...${NC}"
  install_brew "zsh"
  install_brew "neovim" "nvim"
  install_brew "tree"
  install_brew "jq"
  install_brew "htop"
  install_brew "postgresql@15" "psql"
  install_brew "bat"
  install_brew "fd"
  install_brew "fzf"
  install_brew "zoxide" "z"
  install_brew "gh"
  install_brew "rust"
  echo ""

  # === NODEJS & JS TOOLS ===
  echo -e "${GREEN}Installing Node.js & JavaScript Tools...${NC}"
  install_brew "fnm"

  if command_exists fnm; then
    fnm install --lts --log-level=quiet && \
    fnm alias default lts && \
    print_success "Node.js LTS installed" || \
    print_error "Failed to install Node.js LTS"
  else
    print_error "Cannot install LTS node, fnm not installed"
  fi

  # pnpm
  if ! command_exists pnpm; then
    print_header "Installing pnpm"
    if command_exists npm; then
      npm install -g pnpm && \
      print_success "pnpm installed" || \
      print_error "Failed to install pnpm"
    else
      print_error "pnpm requires npm. Install Node.js first."
    fi
  else
    print_skip "pnpm"
  fi
  echo ""

  # bun
  brew tap oven-sh/bun
  install_brew "bun"
  echo ""

  # === PYTHON TOOLS ===
  echo -e "${GREEN}Installing Python Tools...${NC}"
  install_brew "python3"
  install_brew "uv"
  echo ""

  # === OPTIONAL DEV TOOLS ===
  echo -e "${GREEN}Installing Optional Development Tools...${NC}"
  install_brew "tmux"
  install_brew "zellij"
  install_brew "agent-browser"
  install_brew "powerlevel10k"
  echo ""


  # === OPTIONAL AI TOOLS ===
  echo -e "${GREEN}Installing AI Tools...${NC}"
  install_brew "codex"
  install_brew "gemini-cli" "gemini"
  install_brew "anomalyco/tap/opencode" "opencode"

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
  echo "         Installation Complete!"
  echo "========================================"
  echo ""
  echo "Next steps:"
  echo "  1. Run ./install.sh      # Stow dotfiles"
  echo "  2. Restart your shell or run: zsh"
  echo ""
  echo "Optional setup:"
  echo "  - fnm: Add to ~/.zshrc if needed"
  echo "  - zellij: Run 'zellij --setup' to configure"
  echo "  - kubectl: Run 'kubectl config view' to check clusters"
  echo ""
}

main "$@"