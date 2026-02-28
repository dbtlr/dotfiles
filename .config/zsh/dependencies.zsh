npm_latest_version() {
  npm view $1 version
}

npm_current_installed_version() {
  npm ls --depth 0 -g $1 | grep $1 | awk -F@ '{print $NF}'
}

npm_package_installed() {
  npm ls --depth 0 -g $1 | grep $1 >/dev/null 2>&1
}

npm_install_latest_version() {
  local pkg_name="$1"

  local installed_version=$(npm_current_installed_version $pkg_name)
  local latest_version=$(npm_latest_version $pkg_name)

  if [ -z "$latest_version" ]; then
    print_error "Could not find a latest version of $pkg_name"
    return 1
  fi

  if [ -z "$installed_version" ]; then
    npm install -g $pkg_name@latest >/dev/null 2>&1 && {
      print_success "Installed $pkg_name@$latest_version"
      return 0
    } || {
      print_error "Failed to install $pkg_name"
      return 1
    }
  fi

  if [[ "$installed_version" != "$latest_version" ]]; then
    npm install -g $pkg_name@latest >/dev/null 2>&1 && {
      print_success "Updated $pkg_name from $installed_version to $latest_version"
      return 0
    } || {
      print_error "Failed to update $pkg_name to $latest_version"
      return 1
    }
  else
    print_skip "$pkg_name already at latest"
    return 0
  fi
}

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

update_npm_packages() {
  print_header "Updating NPM Packages"

  local packages=("typescript" "typescript-language-server" "serve" "pnpm")

  for package in "${packages[@]}"; do
    npm_install_latest_version $package
  done

  echo ""
}

update_node() {
  current_node=$(fnm current)
  latest_node=$(fnm list-remote --latest --lts)

  if [[ "$current_node" != "$latest_node" ]]; then
    print_info "Updating Node from $current_node to $latest_node"
    fnm install --lts >/dev/null 2>&1 && \
    fnm default lts
  else
    print_info "Nothing to do, $latest_node is already the latest..."
  fi

  echo ""
}

update_dev_tools() {
  print_header "Updating Claude Code"

  if [ "$WSL_DISTRO_NAME" = "linux" ]; then
    claude update
  else
    npm install -g @anthropic-ai/claude-code@latest >/dev/null 2>&1
  fi

  echo ""
}

update_brew() {
  brew update >/dev/null 2>&1 && print_success "Homebrew updated" || print_error "Failed to update Homebrew"
  brew upgrade >/dev/null 2>&1 && print_success "Homebrew packages upgraded" || print_error "Failed to upgrade Homebrew packages"
  echo ""
}
