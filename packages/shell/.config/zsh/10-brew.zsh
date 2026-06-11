export HOMEBREW_NO_ENV_HINTS=1

# Cached `brew shellenv` (rendered by dotfiles apply/upgrade); eval only when missing
if [[ -r "$HOME/dotfiles/state/init/brew.zsh" ]]; then
  source "$HOME/dotfiles/state/init/brew.zsh"
elif [[ -d "/opt/homebrew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"
fi
