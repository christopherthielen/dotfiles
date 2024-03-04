set -e

JENV="$HOME/.jenv"
JENV_VERSIONS="$JENV/versions"
mkdir -p "$JENV"

# cleanup to avoid intermittent failures from rehashing

find "$JENV" -type f -name '*.time' -delete
rm -rf "$JENV_VERSIONS" && mkdir -p "$JENV_VERSIONS"

for java in $(find /Library/Java/JavaVirtualMachines -mindepth 1 -maxdepth 1 ! -type l); do yes | (jenv add "$java/Contents/Home" > /dev/null); done
(jenv rehash &) 2> /dev/null

# asimov excludes node_modules, etc from time machine
if brew services list | grep -q "^asimov *stopped" ; then
  sudo brew services start asimov
fi

# Install vim plugins
luarocks install nvim-lspconfig
nvim -c PlugInstall -c qa --headless

# Configure "global yarn bin" directory for faster yarn plugin startup
mkdir -p ~/.yarn
[[ -e ~/.yarn/bin ]] && rm ~/.yarn/bin
ln -s /opt/homebrew/bin ~/.yarn/bin
