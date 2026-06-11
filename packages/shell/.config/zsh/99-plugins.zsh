# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ----- Plugins -----
for file in ~/.config/zsh/plugins/*.zsh; do
  source "$file"
done
