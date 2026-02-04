#!/usr/bin/env bash
# INSTALL:
#
# curl -fsSL https://raw.githubusercontent.com/christopherthielen/dotfiles/main/bootstrap.sh | bash
#
# Or to review first:
# curl -fsSL https://raw.githubusercontent.com/christopherthielen/dotfiles/main/bootstrap.sh -o bootstrap.sh && bash ./bootstrap.sh

set -e

echo "=========================================="
echo "Chezmoi Dotfiles Bootstrap"
echo "=========================================="
echo ""

# =============================================================================
# Collect age key for secrets decryption
# =============================================================================
if [[ ! -f "$HOME/.config/chezmoi/key.txt" ]]; then
    echo "Your dotfiles contain encrypted secrets."
    echo "Paste your age key from Bitwarden (3 lines), then press Ctrl+D:"
    echo ""
    
    if [[ -t 0 ]]; then
        mkdir -p "$HOME/.config/chezmoi"
        cat > "$HOME/.config/chezmoi/key.txt"
        chmod 600 "$HOME/.config/chezmoi/key.txt"
        echo ""
        echo "Age key saved."
    else
        echo "ERROR: No TTY available. Run this script interactively."
        exit 1
    fi
fi

# =============================================================================
# Download chezmoi and apply dotfiles
# chezmoi's run_before_ scripts will install Homebrew and prerequisites
# =============================================================================
echo ""
echo "Downloading chezmoi and applying dotfiles..."
echo "(This will install Homebrew if needed)"
echo ""

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply christopherthielen/dotfiles --branch main

echo ""
echo "=========================================="
echo "Bootstrap complete!"
echo "=========================================="
echo ""
echo "Start a new shell or run: source ~/.zshrc"
