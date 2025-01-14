set -e
# asimov excludes node_modules, etc from time machine
if brew services list | grep -q "^asimov *stopped" ; then
  sudo brew services start asimov
fi

# Install vim plugins
sudo luarocks install nvim-lspconfig
nvim -c PlugInstall -c qa --headless

# Configure "global yarn bin" directory for faster yarn plugin startup
mkdir -p ~/.yarn
[[ -e ~/.yarn/bin ]] && rm ~/.yarn/bin
ln -s "$HOMEBREW_PREFIX/bin" ~/.yarn/bin
