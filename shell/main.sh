#!/usr/bin/env bash

export SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Set up brew
$SCRIPT_DIR/brew.sh

# Set up brew binaries
$SCRIPT_DIR/brew_binaries.sh

# Set up brew casks
$SCRIPT_DIR/brew_casks.sh

# Set up mac app store
$SCRIPT_DIR/mas.sh

# Non-mackup dotfiles
$SCRIPT_DIR/dotfiles.sh

# Mackup stuff
$SCRIPT_DIR/mackup.sh

# Node stuff
$SCRIPT_DIR/node.sh

# Run OS X settings
$SCRIPT_DIR/osx.sh

echo "Done provisioning!"