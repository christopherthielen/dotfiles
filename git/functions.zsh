# gitignore.io - http://www.gitignore.io/cli
# function gi() { curl http://www.gitignore.io/api/$@ ;}

function scorecard() {
  git log --pretty=%an | sort | uniq -c | sort -r
}

function prunegitlocalbranches() {
  git remote prune origin && git branch -vv | grep '\[[^]]* gone\]' | awk '{ print \$1 }' | xargs git branch -D
}