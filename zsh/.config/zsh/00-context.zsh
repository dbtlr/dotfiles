# ~/dotfiles/zsh/.config/zsh/context.zsh
# Context-aware configuration loader
# Detects OS, host, and terminal to source appropriate configs

# --- OS Detection ---
case "$OSTYPE" in
  darwin*)  export DOTFILES_OS="macos" ;;
  linux*)   export DOTFILES_OS="linux" ;;
  *)        export DOTFILES_OS="unknown" ;;
esac

# --- Host Detection ---
export DOTFILES_HOST="${HOST%%.*}"

# --- Terminal Detection ---
export DOTFILES_TERMINAL="unknown"
case "${TERM_PROGRAM:-}" in
  vscode)         DOTFILES_TERMINAL="vscode" ;;
  Apple_Terminal) DOTFILES_TERMINAL="apple" ;;
  ghostty)        DOTFILES_TERMINAL="ghostty" ;;
  iTerm.app)      DOTFILES_TERMINAL="iterm" ;;
esac
[[ "$LC_TERMINAL" == "Blink" ]] && DOTFILES_TERMINAL="blink"
[[ -n "${TERMINUS_SUBLIME:-}" ]] && DOTFILES_TERMINAL="terminus"

# --- SSH/Remote Detection ---
export DOTFILES_REMOTE=""
[[ -n "$SSH_CONNECTION" ]] && DOTFILES_REMOTE="ssh"

# --- Multiplexer Detection ---
export DOTFILES_MULTIPLEXER=""
[[ -n "$TMUX" ]] && DOTFILES_MULTIPLEXER="tmux"
[[ -n "$STY" ]] && DOTFILES_MULTIPLEXER="screen"

# --- Context Loader ---
# Set DOTFILES_DEBUG=1 before sourcing to trace loaded configs
_load_if_exists() {
  if [[ -f "$1" ]]; then
    [[ -n "${DOTFILES_DEBUG:-}" ]] && echo "Loading: $1"
    source "$1"
  fi
}

_load_if_exists "$HOME/.config/zsh/os/${DOTFILES_OS}.zsh"
_load_if_exists "$HOME/.config/zsh/hosts/${DOTFILES_HOST}.zsh"
_load_if_exists "$HOME/.config/zsh/terminals/${DOTFILES_TERMINAL}.zsh"
