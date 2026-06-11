# Completion system — native compinit with a 24h-cached dump.
fpath=("$HOME/dotfiles/vendor/zsh-completions/src" $fpath)

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit          # dump older than 24h (or missing): full rescan
else
  compinit -C       # fresh dump: skip the expensive security scan
fi

zmodload zsh/complist
zstyle ':completion:*' menu select
# Case-insensitive (and partial-word) matching, like OMZ's default
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
