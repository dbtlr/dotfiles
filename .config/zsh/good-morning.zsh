good_morning() {
  force=$1
  good_morning_filename=~/.goodmorning
  today=$(date "+%A, %B %d, %Y")

  if debounce $good_morning_filename $today || [ "$force" = "force" ]; then
    printf "\n"
    printf "${C_LIGHTGRAY}Good Morning ${C_PURPLE}$USER${NC}\n"
    printf "${C_LIGHTGRAY}Today is ${C_GREEN}$today${NC}\n"
    printf "${C_LIGHTGRAY}Let's run some checks to make sure everything is up to date.${NC}\n"
    echo ""

    update_brew
    update_npm_packages

    echo $today > $good_morning_filename
    printf "\n"
  fi
}