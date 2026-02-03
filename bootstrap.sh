#!/usr/bin/env bash
# INSTALL:
#
# curl -fsSL https://raw.githubusercontent.com/christopherthielen/dotfiles/main/bootstrap.sh -o bootstrap.sh && bash ./bootstrap.sh
#
# Bootstrap script for chezmoi dotfiles
# Works on macOS (Intel/ARM) and Linux (x86_64/ARM)

set -e

# =============================================================================
# Detect environment
# =============================================================================
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "=========================================="
echo "Chezmoi Dotfiles Bootstrap"
echo "=========================================="
echo "Detected: $OS / $ARCH"
echo ""

# =============================================================================
# Collect user input upfront (before long-running installs)
# =============================================================================

# Age key for secrets decryption
AGE_KEY=""
if [[ ! -f "$HOME/.config/chezmoi/key.txt" ]]; then
    echo "Your dotfiles contain encrypted secrets (npm tokens, etc.)"
    echo "Paste your age key from Bitwarden (3 lines), then press Ctrl+D:"
    echo ""
    if [[ -t 0 ]]; then
        stty -echo
        trap 'stty echo' EXIT
        AGE_KEY=$(cat)
        stty echo
        trap - EXIT
        echo ""
        echo "Age key captured."
    else
        echo "ERROR: No TTY available. Run this script interactively:"
        echo "  curl -fsSL <url>/bootstrap.sh -o bootstrap.sh && bash ./bootstrap.sh"
        exit 1
    fi
fi

# Timezone for Linux (avoids tzdata prompts during apt install)
TIMEZONE=""
if [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/timezone ]]; then
        TIMEZONE=$(cat /etc/timezone)
        echo "Using system timezone: $TIMEZONE"
    else
        echo ""
        echo "Enter your timezone (e.g., America/Los_Angeles, Pacific/Honolulu, UTC):"
        read -p "Timezone: " TIMEZONE
        TIMEZONE=${TIMEZONE:-UTC}
    fi
fi

echo ""
echo "=========================================="
echo "Starting installation..."
echo "=========================================="

# =============================================================================
# Linux: Pre-configure apt to be non-interactive
# =============================================================================
if [[ "$OS" == "Linux" ]]; then
    export DEBIAN_FRONTEND=noninteractive
    
    # Pre-configure timezone to avoid tzdata prompts
    if [[ -n "$TIMEZONE" ]]; then
        sudo ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
        echo "$TIMEZONE" | sudo tee /etc/timezone > /dev/null
    fi
    
    # Install essential packages before Homebrew
    echo "Installing essential apt packages..."
    sudo apt-get update -qq
    sudo apt-get install -y build-essential curl git zsh locales
    
    # Ensure locale is set
    sudo locale-gen en_US.UTF-8 2>/dev/null || true
fi

# =============================================================================
# Install Homebrew (non-interactive)
# =============================================================================
if [[ "$OS" == "Darwin" ]]; then
    if [[ "$ARCH" == "arm64" ]]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    else
        HOMEBREW_PREFIX="/usr/local"
    fi
elif [[ "$OS" == "Linux" ]]; then
    HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

if [[ ! -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    echo ""
    echo "Installing Homebrew..."
    # NONINTERACTIVE=1 skips the "Press RETURN" prompt
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to current session
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
export HOMEBREW_NO_ENV_HINTS=1

# Add to shell profile if not already there
SHELL_RC="$HOME/.zshrc"
if ! grep -q 'brew shellenv' "$SHELL_RC" 2>/dev/null; then
    echo "Adding Homebrew to $SHELL_RC..."
    echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >> "$SHELL_RC"
fi

# =============================================================================
# Install chezmoi
# =============================================================================
echo ""
echo "Installing chezmoi and diff-so-fancy..."
brew install chezmoi diff-so-fancy

# =============================================================================
# Save age key (collected earlier)
# =============================================================================
if [[ -n "$AGE_KEY" ]]; then
    mkdir -p "$HOME/.config/chezmoi"
    echo "$AGE_KEY" > "$HOME/.config/chezmoi/key.txt"
    chmod 600 "$HOME/.config/chezmoi/key.txt"
    echo "Age key saved to ~/.config/chezmoi/key.txt"
fi

# =============================================================================
# Initialize and apply chezmoi
# =============================================================================
echo ""
echo "Initializing chezmoi..."
chezmoi init christopherthielen/dotfiles --branch main

echo ""
echo "Applying dotfiles..."
chezmoi apply

echo ""
echo "=========================================="
echo "Bootstrap complete!"
echo "=========================================="
echo ""
echo "Start a new shell or run: source ~/.zshrc"
