
function cl() {
  # if --yolo is passed as any parameter, replace it with --dangerously-skip-permissions
  if [[ "$@" == *"--yolo"* ]]; then
    set -- "${@/--yolo/--dangerously-skip-permissions}"
  fi

  command claude "$@"
}
