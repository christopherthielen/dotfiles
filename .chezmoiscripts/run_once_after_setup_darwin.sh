#!/bin/bash
# macOS-specific one-time setup

# Only run on macOS
[[ "$(uname -s)" != "Darwin" ]] && exit 0

set -e

# =============================================================================
# macOS defaults
# =============================================================================

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

# =============================================================================
# asimov (excludes node_modules, etc from Time Machine)
# =============================================================================

# Ensure Homebrew is in PATH
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v brew &>/dev/null && brew services list | grep -q "^asimov *stopped"; then
    echo "Starting asimov service..."
    sudo brew services start asimov
fi
