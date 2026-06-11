
eval "$(zoxide init zsh)"

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