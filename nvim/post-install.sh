set -ex
KICKSTART_PATH="${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

if [[ -e "$KICKSTART_PATH/.git" ]] ; then
  pushd $KICKSTART_PATH
  git pull --rebase
  popd
elif [[ -e "$KICKSTART_PATH" ]] ; then
  echo WARNING: Cannot clone nvim-lua/kickstart.nvim because $KICKSTART_PATH already has files
  CLONE="$KICKSTART_PATH/clone";
  mkdir "$CLONE"
  git clone https://github.com/nvim-lua/kickstart.nvim.git "$CLONE"
  mv "$CLONE/.git" "$KICKSTART_PATH";
  rm -rf "$CLONE"
  pushd "$KICKSTART_PATH";
  git checkout .
  popd
else
  git clone https://github.com/nvim-lua/kickstart.nvim.git "$KICKSTART_PATH"
fi

# Enable custom plugin loading from ~/.config/nvim/lua/custom/plugins/
sed -i '' "/^  -- { import = 'custom.plugins' }/s/-- //" "$KICKSTART_PATH/init.lua"
# Enable neo-tree
sed -i '' "/^vim.g.have_nerd_font = false/s/false/true/" "$KICKSTART_PATH/init.lua"
sed -i '' "/^  -- require 'kickstart.plugins.neo-tree/s/--//"  "$KICKSTART_PATH/init.lua"
# Enable other plugins kickstart includes
sed -i '' "/^  -- require 'kickstart.plugins.indent_line/s/--//"  "$KICKSTART_PATH/init.lua"
sed -i '' "/^  -- require 'kickstart.plugins.lint/s/--//"  "$KICKSTART_PATH/init.lua"
sed -i '' "/^  -- require 'kickstart.plugins.autopairs/s/--//"  "$KICKSTART_PATH/init.lua"

nvim --headless "+Lazy! sync" +qa

