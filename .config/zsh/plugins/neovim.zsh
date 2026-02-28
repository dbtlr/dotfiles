alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias svim='sudo -E nvim'

alias vd='nvim .'
alias vl='nvim -c "normal! `0"'

vp() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  nvim "$root"
}

vf() {
  local file
  file=$(fzf --height 40% --reverse) || return
  nvim "$file"
}

vfg() {
  local result
  result=$(rg --line-number . | fzf) || return
  nvim +"${result#*:}" "${result%%:*}"
}

vn() {
  tmux new-window -c "$PWD" 'nvim'
}

vs() {
  tmux split-window -h -c "$PWD" "nvim ${1:-.}"
}

vsv() {
  tmux split-window -v -c "$PWD" "nvim ${1:-.}"
}

alias nvs='nvim --listen /tmp/nvim.sock'
alias nvo='nvim --server /tmp/nvim.sock --remote'
alias nvt='nvim --server /tmp/nvim.sock --remote-tab'
alias nvsplit='nvim --server /tmp/nvim.sock --remote-split'

vg() {
  git diff --name-only | uniq | xargs nvim
}

vconflicts() {
  git diff --name-only --diff-filter=U | xargs nvim
}