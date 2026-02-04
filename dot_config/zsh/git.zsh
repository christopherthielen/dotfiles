# Git helper functions

# Show git status in all subdirectories
function git-status-all() {
    for d in */; do
        if [[ -d "$d/.git" ]]; then
            echo "=== $d ==="
            (cd "$d" && git status -s)
        fi
    done
}

# Show commit count by author
function scorecard() {
    git log --pretty=%an | sort | uniq -c | sort -r
}
