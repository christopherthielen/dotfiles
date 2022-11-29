# overrides for ls
alias ls="gls -F --color=auto"
alias l="ls -lAh --color=auto"
alias ll="ls -l --color=auto"
alias la="ls -A --color=auto"

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
