
function claude() {
  # if --yolo is passed, replace it with --dangerously-skip-permissions
  if [[ "$1" == "--yolo" ]]; then
    set -- "--dangerously-skip-permissions" "${@:2}"
  fi

  command claude "$@"
}