# Workspace helpers for $WORKSPACES_ROOT directories
: "${WORKSPACES_ROOT:=/Users/drew/workspaces}"

# Carve-outs: names that resolve to an explicit path instead of
# $WORKSPACES_ROOT/<name>. Also offered in completion. Values expand at source
# time, so $HOME is per-machine.
typeset -gA WORKSPACE_ALIASES=(
  dotfiles "$HOME/dotfiles"
  hermes   "$HOME/.hermes"
  atlas    "$HOME/vaults/atlas"
)

# Resolve a workspace dir: carve-out name -> its path, else arg ->
# $WORKSPACES_ROOT/<arg>, no arg -> fzf picker. Prints the absolute path; fails
# on missing root, cancelled pick, or bad dir.
_workspace_dir() {
  local target

  # Explicit carve-out wins over $WORKSPACES_ROOT/<name>.
  if [[ -n "$1" && -n "${WORKSPACE_ALIASES[$1]}" ]]; then
    target="${WORKSPACE_ALIASES[$1]}"
  elif [[ ! -d "$WORKSPACES_ROOT" ]]; then
    echo "Error: workspaces root '$WORKSPACES_ROOT' not found" >&2
    return 1
  elif [[ -n "$1" ]]; then
    target="$WORKSPACES_ROOT/$1"
  else
    local pick
    local -a choices=( ${(k)WORKSPACE_ALIASES} "$WORKSPACES_ROOT"/*(N/:t) )
    pick="$(printf '%s\n' ${(u)choices} | fzf)" || return 1
    _workspace_dir "$pick"   # resolve the pick (carve-out or workspace dir)
    return $?
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
  cd "$dir" && cl "${@:2}"
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

# Workspace → sidebar color for cssh (unmapped workspaces fall back to gray).
# Values are cmux palette names or #RRGGBB hex — tweak freely.
typeset -gA CSSH_WORKSPACE_COLORS=(
  norn         Indigo
  saga         Purple
  atlas        Blue
  atlas-skills Navy
  hermes       Orange
  vard         Green
  mimir        Teal
  dbtlr.com    Rose
  dotfiles     Brown
  tooling      Amber
  periodic     Magenta
  skald        Aqua
  briefs       Olive
)
: "${CSSH_DEFAULT_COLOR:=#6B7280}"

# Known hosts cssh targets / offers for completion.
typeset -ga CSSH_HOSTS=(valhalla)

# cmux ssh into <host> as a named workspace, colored per CSSH_WORKSPACE_COLORS
# (gray if unmapped). With <workspace>, also run `tnw <workspace>` inside it once
# connected (cd $WORKSPACES_ROOT/<workspace> + create/attach its tmux session);
# without it, just open a remote shell on <host>.
# cmux's `-- <cmd>` path gets no tty, so tmux can't attach there; instead we open
# the workspace, wait for the remote shell, then `cmux send` the command into it.
cssh() {
  emulate -L zsh
  local host="${1:?usage: cssh <host> [workspace]}"
  local ws="$2"
  command -v cmux >/dev/null || { echo "cssh: cmux not found on PATH" >&2; return 1; }

  local out ref
  out="$(cmux ssh "$host" --name "${ws:-$host}")" || return
  ref="$(print -r -- "$out" | grep -oE 'workspace=[^ ]+' | head -1 | cut -d= -f2)"
  [[ -n "$ref" ]] || { echo "cssh: no workspace ref in: $out" >&2; return 1; }

  # Color the sidebar: mapped color if known, else gray.
  cmux workspace-action --action set-color --workspace "$ref" \
    --color "${CSSH_WORKSPACE_COLORS[$ws]:-$CSSH_DEFAULT_COLOR}" >/dev/null 2>&1

  # No workspace requested → done (shell is open).
  [[ -n "$ws" ]] || return 0

  local i
  for i in {1..40}; do
    if cmux rpc workspace.remote.status "{\"workspace_id\":\"$ref\"}" 2>/dev/null \
         | grep -qE '"connected" *: *true'; then
      cmux send --workspace "$ref" -- "tnw ${(q)ws}\n"
      return
    fi
    sleep 0.5
  done
  print -r -- "cssh: $ref not connected after 20s. Once it's up, run:" >&2
  print -r -- "  cmux send --workspace $ref -- \"tnw ${(q)ws}\\n\"" >&2
  return 1
}

# Completion: carve-out names + directories under $WORKSPACES_ROOT
_workspace_completion() {
  _alternative \
    "carve-outs:carve-out:(${(k)WORKSPACE_ALIASES})" \
    "workspaces:workspace:_files -W ${(q)WORKSPACES_ROOT} -/"
}

compdef _workspace_completion cdw vsw ccw cxw tnw

# Completion for cssh: hosts (arg 1) from $CSSH_HOSTS, workspaces (arg 2) from
# the keys of $CSSH_WORKSPACE_COLORS.
_cssh() {
  local -a _hosts _ws
  _hosts=( ${CSSH_HOSTS} )
  _ws=( ${(k)CSSH_WORKSPACE_COLORS} )
  case $CURRENT in
    2) _describe 'host' _hosts ;;
    3) _describe 'workspace' _ws ;;
  esac
}
compdef _cssh cssh
