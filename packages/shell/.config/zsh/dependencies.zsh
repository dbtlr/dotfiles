debounce() {
  debounce_filename=$1
  debounce_text=$2

  if [ ! -e "$debounce_filename" ]; then
    lastrun=""
  else
    lastrun=$(head -n 1 $debounce_filename)
  fi

  if [ "$debounce_text" != "$lastrun" ]; then
    echo $debounce_text > $debounce_filename
    return 0
  else
    return 1
  fi
}

update_brew() {
  brew update >/dev/null 2>&1 && print_success "Homebrew updated" || print_error "Failed to update Homebrew"
  brew upgrade >/dev/null 2>&1 && print_success "Homebrew packages upgraded" || print_error "Failed to upgrade Homebrew packages"
  echo ""
}
