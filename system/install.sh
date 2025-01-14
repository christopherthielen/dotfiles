#!/bin/sh
if [ "$(uname)" = "Linux" ] ; then
  # https://fx.wtf/install
  curl https://fx.wtf/install.sh | sudo sh

  # https://github.com/christopherthielen/tag?tab=readme-ov-file#installation
  go install github.com/christopherthielen/tag@latest

  # add yubikey to apt sources
  sudo apt-add-repository ppa:yubico/stable
  sudo apt update
fi
