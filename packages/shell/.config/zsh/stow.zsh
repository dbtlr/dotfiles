dotsync() {
  echo "Syncing dotfiles..."
  stow --no-folding -d ~/dotfiles -t ~ -R . 2> >(grep -v "BUG in find_stowed_path?" 1>&2)
  stow --no-folding -d ~/dotfiles -t ~ -R agents 2> >(grep -v "BUG in find_stowed_path?" 1>&2)
}

dotunsync() {
  echo "Unsyncing dotfiles..."
  stow --no-folding -d ~/dotfiles -t ~ -D .
  stow --no-folding -d ~/dotfiles -t ~ -D agents
}
