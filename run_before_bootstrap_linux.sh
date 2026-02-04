#!/bin/bash
# Bootstrap Linux: apt prereqs + Linuxbrew

set -e

HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"

# Skip if Homebrew already installed
if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    exit 0
fi

echo "Bootstrapping Linux environment..."

# Non-interactive apt
export DEBIAN_FRONTEND=noninteractive

# Set timezone to avoid tzdata prompts
if [[ ! -f /etc/timezone ]]; then
    sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    echo "UTC" | sudo tee /etc/timezone > /dev/null
fi

# Install Homebrew prerequisites
sudo apt-get update -qq
sudo apt-get install -y build-essential curl git zsh locales
sudo locale-gen en_US.UTF-8 2>/dev/null || true

# Install Linuxbrew
echo "Installing Linuxbrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
