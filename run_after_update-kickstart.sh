#!/bin/bash
# Sync kickstart.nvim with upstream (runs on every chezmoi apply)

KICKSTART_REPO="$HOME/.kickstart.nvim"

if [[ -d "$KICKSTART_REPO/.git" ]]; then
    echo "Syncing kickstart.nvim with upstream..."
    cd "$KICKSTART_REPO"
    git remote add upstream https://github.com/nvim-lua/kickstart.nvim.git 2>/dev/null || true
    git fetch upstream --quiet 2>/dev/null || true
    git pull --rebase --quiet 2>/dev/null || true
fi
