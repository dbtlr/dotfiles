alias ll="ls -lah"
alias gs="git status"
alias gd="git diff"
alias gc="git commit"
alias gp="git push"

# Dotfiles management
alias dotsync='for d in ~/dotfiles/*/; do stow -d ~/dotfiles -t ~ -R "$(basename "$d")"; done'
