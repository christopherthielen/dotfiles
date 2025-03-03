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

INITLUA="$KICKSTART_PATH/init.lua";
# Enable custom plugin loading from ~/.config/nvim/lua/custom/plugins/
perl -pi -e "s/-- // if /^  -- { import = 'custom.plugins' }/" "$INITLUA"
# Enable neo-tree
perl -pi -e "s/false/true/ if /^vim.g.have_nerd_font = false/" "$INITLUA"
perl -pi -e "s/-- // if /^  -- require 'kickstart.plugins.neo-tree/" "$INITLUA"
# Enable other plugins kickstart includes
perl -pi -e "s/-- // if /^  -- require 'kickstart.plugins.indent_line/" "$INITLUA"
perl -pi -e "s/-- // if /^  -- require 'kickstart.plugins.lint/" "$INITLUA"
perl -pi -e "s/-- // if /^  -- require 'kickstart.plugins.autopairs/" "$INITLUA"

nvim --headless "+Lazy! sync" +qa

