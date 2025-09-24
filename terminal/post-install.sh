#!/usr/bin/env bash
set -e
TARGET="$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode"
[ -e "$TARGET" ] || ln -s "$HOME/.zsh-vi-mode" $TARGET

