# Install homebrew cask
brew install caskroom/cask/brew-cask

# Tap development versions
brew tap caskroom/versions

apps=(
    google-chrome
    homebrew/cask-versions/firefox-developer-edition
    transmit
    spotify
    flux
    dash
    adobe-creative-cloud
    rescuetime
    virtualbox
    vagrant
    sequel-pro
    bartender
    skype
    wordpresscom
    alfred
    zoom
    micro-snitch
    little-snitch
    duet
    hyper
    ngrok
    now
    jetbrains-toolbox
    visual-studio-code
    homebrew/cask-fonts/font-fira-code
    private-internet-access
    postico
    postgres
    gas-mask
    alfred
    sketch
    vlc
    backblaze
    gitify
    cyberduck
    graphql-playground
)

echo "Installing apps..."
brew cask install --appdir="/Applications" ${apps[@]}
