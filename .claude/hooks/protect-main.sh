#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"

invoked=""
if command -v jq >/dev/null 2>&1; then
  invoked="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
fi
if [ -z "$invoked" ]; then
  invoked="$payload"
fi

is_git_commit() {
  printf '%s' "$1" | grep -Eq '(^|[^[:alnum:]_])git[[:space:]]+([^[:space:]]+[[:space:]]+)*commit([[:space:]]|$)'
}

if ! is_git_commit "$invoked"; then
  exit 0
fi

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
case "$branch" in
  main|master)
    echo "protect-main: commit direct sur '$branch' interdit (workflow trunk-based, CLAUDE.md §4)." 1>&2
    echo "Crée une branche de feature courte : git switch -c feat/<sujet>" 1>&2
    exit 2
    ;;
esac
exit 0
