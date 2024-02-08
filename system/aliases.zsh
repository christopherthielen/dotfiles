# overrides for ls
alias ls="exa -F --group-directories-first --icons"
alias l="ll -aa"
alias la="ll -a"
alias ll="ls -l --git --no-permissions --no-user --time-style=iso"

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
