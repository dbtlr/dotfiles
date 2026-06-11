# Cached `mise activate` (rendered by dotfiles apply/upgrade); eval only when missing
if [[ -r "$HOME/dotfiles/state/init/mise.zsh" ]]; then
  source "$HOME/dotfiles/state/init/mise.zsh"
elif command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi