# Dotfiles management — thin wrappers over the dotfiles CLI (bin/dotfiles).
dotsync() { "$HOME/dotfiles/bin/dotfiles" apply; }

dotunsync() {
  local pkgdir="$HOME/dotfiles/packages" pkg
  for pkg in "$pkgdir"/*/; do
    stow --no-folding -d "$pkgdir" -t "$HOME" -D "$(basename "$pkg")"
  done
}
