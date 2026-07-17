# Restore terminal state after a remote session exits or drops.
#
# When SSH dies ungracefully (e.g. laptop lid close), the local terminal is left
# in whatever modes the remote had set — alt screen, mouse reporting, bracketed
# paste — and never receives the resets, so the shell prints stray control
# characters until `reset`. These wrappers replay the resets on return,
# regardless of how the session ended or which transport carried it. This is
# what mosh does implicitly; doing it here means plain ssh is just as safe.

# exit alt screen (1049); disable mouse reporting (1000/1002/1003) and SGR
# mouse (1006); disable bracketed paste (2004); show cursor (25); reset SGR.
_REMOTE_TERM_RESET=$'\e[?1049l\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?2004l\e[?25h\e[0m'

_remote_term_emit_reset() {
  # No interactive terminal to restore (cron, fully-redirected scripts) → skip.
  [[ -t 0 || -t 1 || -t 2 ]] || return 1
  # Target the controlling terminal, never stdout: a piped `ssh host cmd | …`
  # must not get these bytes injected into the pipe.
  printf '%s' "$_REMOTE_TERM_RESET" 2>/dev/null >/dev/tty
}

_remote_term_restore() {
  _remote_term_emit_reset || return 0
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

# The wrappers above only cover ssh/mosh launched from this shell. Clients
# that spawn their own ssh (cmux remote workspaces) reattach after a drop
# without replaying resets, so the client terminal keeps whatever modes the
# old session had latched — mouse reporting in particular then floods the
# prompt with SGR sequences. Cover that path from the remote end: re-emit the
# resets so they travel back and clear the client terminal regardless of
# transport. Skipped inside tmux/screen, where the pane's modes belong to the
# multiplexer, and zle re-enables bracketed paste on its own.
if [[ -o interactive && -n $SSH_CONNECTION && -z $TMUX && -z $STY ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _remote_term_emit_reset
  # A reattach can land on an idle prompt where precmd won't fire until the
  # next command. Clients re-sync the window size on attach, so WINCH is the
  # earliest reattach signal. zsh runs this trap immediately at an idle zle
  # prompt but defers it while a foreground job runs, so it cannot corrupt a
  # running full-screen app.
  TRAPWINCH() { _remote_term_emit_reset }
fi
