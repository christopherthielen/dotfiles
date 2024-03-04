# Stuff here loads before oh-my-zsh

FZF_BIN=/opt/homebrew/bin/fzf
FZF_REALPATH=$(realpath $FZF_BIN)
export FZF_BASE=$(dirname $FZF_REALPATH)/..

# Reduce startup time of nvm plugin
zstyle ':omz:plugins:nvm' lazy yes
