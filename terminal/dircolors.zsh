# Colors/GNU ls
if [ "$(uname)" = "Darwin" ] ; then
  eval `gdircolors $HOME/.dircolors-solarized/dircolors.256dark`
else
  eval `dircolors $HOME/.dircolors-solarized/dircolors.256dark`
fi

# Grep highlight color
export GREP_COLOR='1;31'
