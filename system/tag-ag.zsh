if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=ag
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias ag=tag
fi
