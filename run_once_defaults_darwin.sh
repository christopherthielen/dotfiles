#!/bin/bash
# Sensible defaults for macOS

# Show the ~/Library folder
chflags nohidden ~/Library

# Set a really fast initial and subsequent key repeat
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10

# Disable press-and-hold for keys in favor of key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Disable smart quotes
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

echo "macOS defaults configured!"
