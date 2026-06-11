# Local paths
export PATH="$HOME/dotfiles/bin:$HOME/.bun/bin:$HOME/.local/bin:$HOME/.bin:/usr/local/bin:$PATH"

# Load modular configs (00-context → … → tools, alphabetical)
for config_file in ~/.config/zsh/*.zsh(-N); do
  source $config_file
done

# Plugins (vendored; syntax-highlighting must be sourced last)
source "$HOME/dotfiles/vendor/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/dotfiles/vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Daily checks (replaced by dotfiles status --motd in M4)
good_morning

# Prompt (cached init rendered by dotfiles apply/upgrade; eval only when missing)
if [[ -r "$HOME/dotfiles/state/init/starship.zsh" ]]; then
  source "$HOME/dotfiles/state/init/starship.zsh"
else
  eval "$(starship init zsh)"
fi
