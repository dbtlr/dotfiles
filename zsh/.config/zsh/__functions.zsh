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