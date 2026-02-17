dotsync() {
  for d in ~/dotfiles/*/; do
    echo "Syncing $(basename "$d")..."
    stow -d ~/dotfiles -t ~ -R "$(basename "$d")" 2> >(grep -v "BUG in find_stowed_path? Absolute/relative mismatch" 1>&2)
  done
}

dotunsync() {
  for d in ~/dotfiles/*/; do
    echo "Unsyncing $(basename "$d")..."
    stow -d ~/dotfiles -t ~ -D "$(basename "$d")"
  done
}