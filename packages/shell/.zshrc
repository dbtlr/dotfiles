# Local paths
export PATH="$HOME/dotfiles/bin:$HOME/.bun/bin:$HOME/.local/bin:$HOME/.bin:/usr/local/bin:$PATH"

# Load modular configs (00-context → … → tools, alphabetical)
for config_file in ~/.config/zsh/*.zsh(-N); do
  source $config_file
done

# mise shims outrank package-manager prefixes (e.g. /opt/homebrew/bin) so mise-managed
# tool versions resolve first. Sits after the modular configs, which is where the
# homebrew prefix and mise activation add their PATH entries.
mise_shims="$HOME/.local/share/mise/shims"
[[ -d $mise_shims ]] && path=($mise_shims ${path:#$mise_shims})
unset mise_shims

# Plugins (vendored; syntax-highlighting must be sourced last)
source "$HOME/dotfiles/vendor/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/dotfiles/vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Daily status banner (instant; reads state/ written by background jobs)
command -v dot >/dev/null && dot status --motd

# Prompt (cached init rendered by dot apply/upgrade; eval only when missing)
if [[ -r "$HOME/dotfiles/state/init/starship.zsh" ]]; then
  source "$HOME/dotfiles/state/init/starship.zsh"
else
  eval "$(starship init zsh)"
fi
