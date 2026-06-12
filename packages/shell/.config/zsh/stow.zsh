# Dotfiles management — thin wrappers over the dot CLI (bin/dot).
dotsync() { "$HOME/dotfiles/bin/dot" apply; }

dotunsync() {
  local pkgdir="$HOME/dotfiles/packages" pkg
  for pkg in "$pkgdir"/*/; do
    stow --no-folding -d "$pkgdir" -t "$HOME" -D "$(basename "$pkg")"
  done
}
