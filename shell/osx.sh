#!/usr/bin/env bash

###############################################################################
# Dock, Dashboard, and hot corners
###############################################################################

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove all icons from dock
dockutil --remove all
dockutil --add "/Applications/Firefox Developer Edition.app"
dockutil --add "/Applications/Safari.app"
dockutil --add "/Applications/Slack.app"
dockutil --add "/Applications/Messages.app"
dockutil --add "/Applications/Hyper.app"
dockutil --add "/Applications/Notion.app"
dockutil --add "/Applications/Visual Studio Code.app"
dockutil --add "/Applications/Hyper.app"

# Add Downloads folder to other section and view as fan sorted by date modified
dockutil --add ~/Downloads --section others --view fan --sort dateadded --display stack


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################

# Enable “natural” scrolling
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Increase sound quality for Bluetooth headphones/headsets
# defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

###############################################################################
# SSD-specific tweaks
###############################################################################

# Disable local Time Machine snapshots
# sudo tmutil disablelocal

# Disable hibernation (speeds up entering sleep mode)
# sudo pmset -a hibernatemode 3

# Remove the sleep image file to save disk space
# sudo rm /Private/var/vm/sleepimage
# Create a zero-byte file instead…
# sudo touch /Private/var/vm/sleepimage
# …and make sure it can’t be rewritten
# sudo chflags uchg /Private/var/vm/sleepimage

# Disable the sudden motion sensor as it’s not useful for SSDs
sudo pmset -a sms 0

###############################################################################
# Terminal
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.Terminal StringEncodings -array 4

# Install Terminal Font
open "supporting/fonts/Meslo LG S DZ Regular for Powerline.otf"
open "supporting/fonts/FiraCodeiScript-Regular.ttf"
open "supporting/fonts/FiraCodeiScript-Bold.ttf"
open "supporting/fonts/FiraCodeiScript-Italic.ttf"

# Install Terminal Theme
open supporting/Flatland.terminal

# Use the Pro theme by default in Terminal.app
defaults write com.apple.Terminal 'Default Window Settings' -string "Flatland";
defaults write com.apple.Terminal 'Startup Window Settings' -string "Flatland";

###############################################################################
# Finder
###############################################################################

# Show all files (NOPE)
defaults write com.apple.finder AppleShowAllFiles 0

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Automatically open a new Finder window when a read only volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool false

# New window points to home
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Don't show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathBar -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Default List View
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"



###############################################################################
# QuickTime
###############################################################################

# Disable recent items in Quicktime
defaults write com.apple.QuickTimePlayerX NSRecentDocumentsLimit 0
defaults delete com.apple.QuickTimePlayerX.LSSharedFileList RecentDocuments
defaults write com.apple.QuickTimePlayerX.LSSharedFileList RecentDocuments -dict-add MaxAmount 0

###############################################################################
# Menu bar
###############################################################################


###############################################################################
# Security settings
###############################################################################

# Allow opening apps from anywhere
sudo spctl --master-disable


###############################################################################
# Other App Settings
###############################################################################

mkdir ~/tmp
mkdir ~/tmp/Screenshots
mkdir ~/tmp/SQL\ Dumps

# Screen capture location
defaults write com.apple.screencapture location ~/tmp/Screenshots

# Safari debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1


###############################################################################
# Default applications
###############################################################################


###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" "Dock" "Finder" "SystemUIServer"; do
  killall "${app}" > /dev/null 2>&1
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
