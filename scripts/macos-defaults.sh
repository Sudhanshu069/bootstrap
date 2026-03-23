#!/usr/bin/env bash

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "macos-defaults.sh only applies to macOS."
  exit 0
fi

# Keep this list short and easy to audit. These are baseline workstation
# preferences rather than a giant dump of every tweak on one machine.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

echo "Applied macOS defaults."
echo "Some changes may require restarting apps or logging out to fully take effect."
