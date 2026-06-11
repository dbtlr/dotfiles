
eval "$(zoxide init zsh)"

cd() {
  if [[ "$CLAUDECODE" == "1" ]]; then
    builtin cd "$@"
    exit "$?"
  fi

  if command -v z > /dev/null; then
    z "$@"
  else
    builtin cd "$@"
  fi
}