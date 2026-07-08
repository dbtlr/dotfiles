# Workspace helpers for $WORKSPACES_ROOT directories
: "${WORKSPACES_ROOT:=/Users/drew/workspaces}"

# Resolve a workspace dir: arg -> $WORKSPACES_ROOT/<arg>, no arg -> fzf picker.
# Prints the absolute path; fails on missing root, cancelled pick, or bad dir.
_workspace_dir() {
  if [[ ! -d "$WORKSPACES_ROOT" ]]; then
    echo "Error: workspaces root '$WORKSPACES_ROOT' not found" >&2
    return 1
  fi

  local target
  if [[ -n "$1" ]]; then
    target="$WORKSPACES_ROOT/$1"
  else
    local pick
    pick="$(printf '%s\n' "$WORKSPACES_ROOT"/*(N/:t) | fzf)" || return 1
    target="$WORKSPACES_ROOT/$pick"
  fi

  if [[ ! -d "$target" ]]; then
    echo "Error: directory '$target' does not exist" >&2
    return 1
  fi

  echo "$target"
}

# cd to a workspace
cdw() {
  local dir
  dir="$(_workspace_dir "$1")" || return
  cd "$dir"
}

# Open a workspace in VS Code
vsw() {
  local dir
  dir="$(_workspace_dir "$1")" || return
  code "$dir"
}

# cd to a workspace and run claude (extra args pass through)
ccw() {
  local dir
  dir="$(_workspace_dir "$1")" || return
  cd "$dir" && claude "${@:2}"
}

# cd to a workspace and run codex (extra args pass through)
cxw() {
  local dir
  dir="$(_workspace_dir "$1")" || return
  cd "$dir" && codex "${@:2}"
}

# cd to a workspace and open a tmux session named after it
tnw() {
  local dir
  dir="$(_workspace_dir "$1")" || return
  cd "$dir" && tn "${dir:t}"
}

# Completion: directories under $WORKSPACES_ROOT
_workspace_completion() {
  _files -W "$WORKSPACES_ROOT" -/
}

compdef _workspace_completion cdw vsw ccw cxw tnw
