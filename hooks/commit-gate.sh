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

case "$invoked" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

if [ ! -f Makefile ] || ! grep -qE '^check[[:space:]]*:' Makefile; then
  exit 0
fi

if ! make check 1>&2; then
  echo "commit-gate: 'make check' failed, commit blocked. Fix the gates before committing." 1>&2
  exit 2
fi
