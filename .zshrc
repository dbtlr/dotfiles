# Only run interactive stuff if interactive
# [[ $- == *i* ]] || return

# Local paths
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$HOME/.bin:/usr/local/bin:$PATH"
export BUN_INSTALL_CACHE_DIR="/home/data/.cache/bun"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(kubectl npm python uv bun bundler git)
source $ZSH/oh-my-zsh.sh

# Load modular configs
for config_file in ~/.config/zsh/*.zsh(N); do
  source $config_file
done

# Run good_morning on shell start
good_morning

# Powerlevel10k theme
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="/Users/drew/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
