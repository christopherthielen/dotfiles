#!/bin/bash
# Bootstrap macOS: Install Homebrew

set -e

# Only run on macOS
[[ "$(uname -s)" != "Darwin" ]] && exit 0

if [[ "$(uname -m)" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

# Skip if Homebrew already installed
if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    exit 0
fi

echo "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
