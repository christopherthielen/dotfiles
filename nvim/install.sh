KICKSTART_PATH="${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

if [[ -e "$KICKSTART_PATH/.git ]] ; then
  pushd $KICKSTART_PATH
  git pull --rebase
  popd
elif [[ -e "$KICKSTART_PATH ]] ; then
  WARNING: Cannot install nvim-lua/kickstart.nvim because $KICKSTART_PATH already has files
else
  git clone https://github.com/nvim-lua/kickstart.nvim.git "$KICKSTART_PATH"
fi

# Enable custom plugin loading from ~/.config/nvim/lua/custom/plugins/
sed -i '' -e "s/^  -- { import = 'custom.plugins' },/  { import = 'custom.plugins' },/" "$KICKSTART_PATH/init.lua"
nvim --headless "+Lazy! sync" +qa

