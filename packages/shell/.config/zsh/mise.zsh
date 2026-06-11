if command -v mise &> /dev/null; then
  eval "$(/Users/${USER}/.local/bin/mise activate zsh)"
fi

update_mise() {
  print_header "Updating Mise"
  if command -v mise &> /dev/null; then
    local output
    output=$(mise self-update -y 2>&1)
    if [[ $? -ne 0 ]]; then
      print_error "Failed to update Mise: $output"
    elif [[ "$output" == *"Updated mise to"* ]]; then
      print_success "$(echo "$output" | grep 'Updated mise to')"
    else
      print_skip "mise is already up to date"
    fi

    mise upgrade
  else
    print_error "mise is not installed. Please install it to use this function."
  fi


}