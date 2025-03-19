set -ex
KICKSTART_PATH="${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

if [[ ! -e "$KICKSTART_PATH/.git" ]] ; then
  ln -s "$HOME/.kickstart.nvim" "$KICKSTART_PATH"
fi

pushd $KICKSTART_PATH
git remote add upstream https://github.com/nvim-lua/kickstart.nvim.git || true
git fetch
git pull --rebase
git rebase upstream/master
popd

nvim --headless "+Lazy! sync" +qa
