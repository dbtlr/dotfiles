export HOMEBREW_NO_ENV_HINTS=1

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

eval "$(/opt/homebrew/bin/brew shellenv zsh)"