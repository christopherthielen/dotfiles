#!/bin/bash
# Install Linux tools not available via apt or Linuxbrew
# Most tools now come from Linuxbrew (with bottles) - see packages.toml
# hash:v4 - added OS guard and brew PATH

set -e

# Only run on Linux
[[ "$(uname -s)" != "Linux" ]] && exit 0

# Ensure Homebrew is in PATH
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "Installing Linux extras..."

# tag (requires go)
if command -v go &>/dev/null && ! command -v tag &>/dev/null; then
    echo "Installing tag via go install..."
    go install github.com/christopherthielen/tag@latest
fi

echo "Linux extras complete!"
