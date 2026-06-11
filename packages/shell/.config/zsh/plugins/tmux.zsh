# Are we inside tmux?
alias intmux='[[ -n "$TMUX" ]] && echo "yes" || echo "no"'

# Always use 256 colors
alias tmux='tmux -2'

# Reload tmux config
alias tmr='tmux source-file ~/.tmux.conf && tmux display-message "tmux reloaded"'

# Open new named session
tn() {
  tmux new-session -A -s "${1:-main}"
}

# Switch tmux session
ts() {
  tmux switch-client -t "$(tmux list-sessions -F '#S' | fzf)"
}

# Open a tmux session based on the current project
tp() {
  local name
  name="$(basename "$PWD" | tr . _)"
  tmux has-session -t "$name" 2>/dev/null \
    && tmux attach -t "$name" \
    || tmux new -s "$name"
}

tcd() {
  cd "$1" || return
  tp
}

# tmux session management
alias tl='tmux list-sessions'
alias tka='tmux kill-server'

tk() {
  tmux kill-session -t "${1:?session name required}"
}

alias tw='tmux new-window'
alias tc='tmux new-window -c "$PWD"'
alias trn='tmux rename-session'
alias twrn='tmux rename-window'

bindkey -s '^T' 'tmux new-window -c "$PWD"\n'

# Show tmux env vars
tmenv() {
  env | grep TMUX
}

# Show tmux socket
tsock() {
  tmux display-message -p '#{socket_path}'
}

exit() {
  if [ -n "$TMUX" ]; then
    tmux detach
  else
    builtin exit "$@"
  fi
}
