# overrides for ls
alias ls="lsd"
alias l="ls -l"
alias la="ls -a"
alias ll="ls -l"
alias lt="ls --tree"

# allow for common cd typo
alias cd..="cd .."

# sort top by CPU by default
alias top="top -o cpu"

alias less="bat"
alias json="fx"
alias df="duf"

function brew2() {
    HOMEBREW_NO_AUTO_UPDATE=1 brew "$@" && brew update
}
