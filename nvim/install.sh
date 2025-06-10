#!/bin/bash

if [ "$(uname)" = "Linux" ] ; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
  chmod 755 nvim-linux-x86_64.appimage
  sudo chown root:root nvim-linux-x86_64.appimage
  sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
fi
