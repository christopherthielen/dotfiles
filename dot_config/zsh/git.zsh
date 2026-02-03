# Git helper functions

# Delete branches that have been merged
function git-prune-merged() {
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d
}

# Show git status in all subdirectories
function git-status-all() {
    for d in */; do
        if [[ -d "$d/.git" ]]; then
            echo "=== $d ==="
            (cd "$d" && git status -s)
        fi
    done
}

# Checkout PR by number
function git-pr() {
    git fetch origin "pull/$1/head:pr-$1" && git checkout "pr-$1"
}

# Show commit count by author
function scorecard() {
    git log --pretty=%an | sort | uniq -c | sort -r
}

# Prune local branches tracking deleted remotes
function prunegitlocalbranches() {
    git remote prune origin && git branch -vv | grep '\[[^]]* gone\]' | awk '{ print $1 }' | xargs git branch -D
}
