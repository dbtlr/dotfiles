# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Local paths
export LOCAL_HOME="/local/dbutler"
export PATH="$HOME/.local/bin:$HOME/.bin:$LOCAL_HOME/bin:/usr/local/bin:$PATH"
export BUN_INSTALL_CACHE_DIR="/home/data/.cache/bun"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(kubectl npm python uv bun bundler git)
source $ZSH/oh-my-zsh.sh

# Load modular configs
for config_file in ~/.config/zsh/*.zsh(.N); do
  source $config_file
done

# Run good_morning on shell start
good_morning

# Powerlevel10k theme
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh