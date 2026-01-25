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

# --- Context Loader ---
_load_if_exists() { [[ -f "$1" ]] && source "$1"; }

_load_if_exists "$HOME/.config/zsh/os/${DOTFILES_OS}.zsh"
_load_if_exists "$HOME/.config/zsh/hosts/${DOTFILES_HOST}.zsh"
_load_if_exists "$HOME/.config/zsh/terminals/${DOTFILES_TERMINAL}.zsh"
