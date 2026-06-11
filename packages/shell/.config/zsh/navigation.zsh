# Quick navigation to $CODE_ROOT directories
CODE_ROOT="~/src"

d() {
  if [ -z "$1" ]; then
    cd $CODE_ROOT
  else
    cd "${CODE_ROOT}/$1"
  fi
}

# Completion for d command
_d_completion() {
  _files -W $CODE_ROOT -/
}

compdef _d_completion d

# Open VS Code at $CODE_ROOT directory
unalias c 2>/dev/null

c() {
  if [ -z "$1" ]; then
    echo "Error: c command requires a directory argument"
    echo "Usage: c <directory>"
    return 1
  fi

  if ! command -v code &>/dev/null; then
    echo "Error: 'code' command not found. Please ensure VS Code is installed and the 'code' command is in your PATH."
    return 1
  fi

  if [[ -z "$VSCODE_INJECTION" && "$TERM_PROGRAM" != "vscode" ]]; then
    echo "Warning: Not running in a VS Code terminal. The 'code' command may not work as expected."
  fi

  local target_dir="${CODE_ROOT}/$1"

  if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    return 1
  fi

  code "$target_dir"
}