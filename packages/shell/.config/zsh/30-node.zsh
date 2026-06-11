# Node ecosystem: pnpm, bun, and rust/cargo env

# pnpm
if [[ "$DOTFILES_OS" == "macos" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
[[ "$DOTFILES_OS" == "linux" && -d "/home/data/.cache" ]] && export BUN_INSTALL_CACHE_DIR="/home/data/.cache/bun"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
