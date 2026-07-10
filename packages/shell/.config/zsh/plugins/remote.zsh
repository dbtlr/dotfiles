# Restore terminal state after a remote session exits or drops.
#
# When SSH dies ungracefully (e.g. laptop lid close), the local terminal is left
# in whatever modes the remote had set — alt screen, mouse reporting, bracketed
# paste — and never receives the resets, so the shell prints stray control
# characters until `reset`. These wrappers replay the resets on return,
# regardless of how the session ended or which transport carried it. This is
# what mosh does implicitly; doing it here means plain ssh is just as safe.

_remote_term_restore() {
  # No interactive terminal to restore (cron, fully-redirected scripts) → skip.
  [[ -t 0 || -t 1 || -t 2 ]] || return 0
  # Target the controlling terminal, never stdout: a piped `ssh host cmd | …`
  # must not get these bytes injected into the pipe.
  #
  # exit alt screen (1049); disable mouse reporting (1000/1002/1003) and SGR
  # mouse (1006); disable bracketed paste (2004); show cursor (25); reset SGR.
  printf '\e[?1049l\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?2004l\e[?25h\e[0m' >/dev/tty 2>/dev/null
  stty sane </dev/tty >/dev/tty 2>/dev/null
}

ssh() {
  command ssh "$@"
  local rc=$?
  _remote_term_restore
  return $rc
}

mosh() {
  command mosh "$@"
  local rc=$?
  _remote_term_restore
  return $rc
}
