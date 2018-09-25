# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

# Doctor
brew doctor

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

# Install ZSH and Oh-My-Zsh
brew install zsh zsh-completions

curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

brew tap mas-cli/tap
brew tap-pin mas-cli/tap

# Install more recent versions of some OS X tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep

chsh -s /usr/local/bin/zsh

# Install brew services
brew tap homebrew/boneyard