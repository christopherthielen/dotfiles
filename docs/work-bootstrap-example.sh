#!/usr/bin/env bash
# Work Bootstrap Script (for GHE repo: github.netflix.net/corp/cthielen-dotfiles)
#
# This script is called automatically when a cloud workstation is provisioned.
# It decrypts the AGE key via metatron and delegates to the main chezmoi bootstrap.
#
# Prerequisites:
# 1. Create a Gandalf policy at go/gandalf (e.g., "CTHIELEN_DOTFILES")
# 2. Encrypt your AGE key: 
#    mkdir -p root/metatron/decrypted
#    cp ~/.config/chezmoi/key.txt root/metatron/decrypted/chezmoi-age-key
#    metatron encrypt -p CTHIELEN_DOTFILES chezmoi-age-key
# 3. Commit root/metatron/encrypted/chezmoi-age-key.mtb to this repo
# 4. Add root/metatron/decrypted/ to .gitignore

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Work Dotfiles Bootstrap"
echo "=========================================="
echo ""

# =============================================================================
# Decrypt AGE key via metatron
# =============================================================================
if [[ ! -f "$HOME/.config/chezmoi/key.txt" ]]; then
    echo "Decrypting AGE key via metatron..."
    
    # Decrypt the secret
    metatron -d "$SCRIPT_DIR" decrypt -i chezmoi-age-key
    
    # Move to chezmoi config location
    mkdir -p "$HOME/.config/chezmoi"
    mv "$SCRIPT_DIR/root/metatron/decrypted/chezmoi-age-key" "$HOME/.config/chezmoi/key.txt"
    chmod 600 "$HOME/.config/chezmoi/key.txt"
    
    echo "AGE key configured."
fi

# =============================================================================
# Run main chezmoi bootstrap (age key already in place, env vars set)
# =============================================================================
echo ""
echo "Running chezmoi bootstrap..."
echo ""

# WORKSPACE_OWNER_EMAIL is set by cloud workstation provisioning
# This will be picked up by .chezmoi.toml.tmpl to skip prompts
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply christopherthielen/dotfiles --branch main

echo ""
echo "=========================================="
echo "Work bootstrap complete!"
echo "=========================================="
echo ""
echo "Start a new shell: zsh"
