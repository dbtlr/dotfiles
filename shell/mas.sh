#!/usr/bin/env bash

apps=(
	692867256 # Simplenote
	409183694 # Keynote
	682658836 # GarageBand
	926036361 # LastPass Password Manager
	497799835 # Xcode
	409201541 # Pages
	409203825 # Numbers
	408981434 # iMovie
	803453959 # Slack
  975937182 # Fantastical 2
	568494494 # Pocket
	414554506 # Clocks
	1278508951 # Trello
	1039633667 # Irvue
)

echo "Installing MAS apps..."
mas install ${apps[@]}