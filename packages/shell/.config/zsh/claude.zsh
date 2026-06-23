ccrc() {
  local name="$1"
  if [[ -z "$name" ]]; then
    print -u2 "usage: ccrc <repo> [-f]"
    return 1
  fi

  local force=0
  [[ "$2" == "-f" || "$2" == "--force" ]] && force=1

  local dir="/Volumes/data/workspaces/$name"
  local session="ccrc-$name"

  if [[ ! -d "$dir" ]]; then
    print -u2 "ccrc: no such directory: $dir"
    return 1
  fi

  local cmd="claude remote-control \
--name $name \
--remote-control-session-name-prefix $name \
--spawn worktree \
--permission-mode bypassPermissions"

  if tmux has-session -t "$session" 2>/dev/null; then
    # Session exists — is claude actually running in it?
    if tmux list-panes -t "$session" -F '#{pane_current_command}' 2>/dev/null \
         | grep -q 'claude\|node'; then
      if (( force )); then
        print "ccrc: killing live session $session (forced)"
        tmux kill-session -t "$session"
      else
        print "ccrc: $session already running. Attach with: tmux attach -t $session  (or ccrc $name -f to restart)"
        return 0
      fi
    else
      # Stale shell, no claude — recreate cleanly
      print "ccrc: $session exists but claude not running; recreating"
      tmux kill-session -t "$session"
    fi
  fi

  tmux new-session -d -s "$session" -c "$dir"
  tmux send-keys -t "$session" "$cmd" C-m
  print "ccrc: started $session in $dir"
}