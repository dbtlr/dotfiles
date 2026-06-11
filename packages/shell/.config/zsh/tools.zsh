
# Cached `zoxide init` (rendered by dotfiles apply/upgrade); eval only when missing
if [[ -r "$HOME/dotfiles/state/init/zoxide.zsh" ]]; then
  source "$HOME/dotfiles/state/init/zoxide.zsh"
elif command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

cd() {
  if [[ "$CLAUDECODE" == "1" ]]; then
    builtin cd "$@"
    return $?
  fi

  if command -v z > /dev/null; then
    z "$@"
  else
    builtin cd "$@"
  fi
}