set -ex
KICKSTART_PATH="${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

if [[ -e "$KICKSTART_PATH/.git" ]] ; then
  pushd $KICKSTART_PATH
  git pull --rebase
  popd
elif [[ -e "$KICKSTART_PATH" ]] ; then
  echo WARNING: Cannot clone nvim-lua/kickstart.nvim because $KICKSTART_PATH already has files
else
  ln -s "$HOME/.kickstart.nvim" "$KICKSTART_PATH"
fi

nvim --headless "+Lazy! sync" +qa
