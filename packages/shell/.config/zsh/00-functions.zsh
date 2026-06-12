print_header() {
  echo -e "${C_BLUE}==> ${C_WHITE}$1...${NC}"
}

print_info() {
  echo -e "${C_LIGHTGRAY}→  $1${NC}"
}

print_error() {
  echo -e "${C_RED}✗  $1${NC}"
}

print_success() {
  echo -e "${C_GREEN}✓  $1${NC}"
}

print_skip() {
  echo -e "${C_YELLOW}↷  $1${NC}"
}

clip() {
  if [[ -z "$1" ]]; then
    print_error "Usage: clip <url> [filename]"
    return 1
  fi

  if ! command -v defuddle >/dev/null 2>&1; then
    print_error "defuddle not installed (npm install -g defuddle-cli)"
    return 1
  fi

  local url="$1"
  local filename="$2"
  local inbox="$HOME/vaults/atlas/Inbox"

  if [[ -z "$filename" ]]; then
    filename="${url%%\?*}"
    filename="${filename%%#*}"
    filename="${filename%/}"
    filename="${filename##*/}"
  fi

  [[ "$filename" != *.md ]] && filename="${filename}.md"

  local output="$inbox/$filename"

  if [[ -e "$output" ]]; then
    print_error "File already exists: $output"
    return 1
  fi

  print_header "Clipping $url"
  if defuddle parse "$url" --md -o "$output"; then
    print_success "Saved to $output"
  else
    print_error "Failed to clip $url"
    return 1
  fi
}
