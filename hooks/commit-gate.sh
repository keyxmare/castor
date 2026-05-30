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

if [ ! -f Makefile ]; then
  echo "commit-gate: aucun Makefile — gates qualité NON exécutés, commit autorisé SANS filet. Voir templates/Makefile du dépôt de standards." 1>&2
  exit 0
fi

target=""
if grep -qE '^check-fast[[:space:]]*:' Makefile; then
  target="check-fast"
elif grep -qE '^check[[:space:]]*:' Makefile; then
  target="check"
else
  echo "commit-gate: ni cible 'check-fast' ni 'check' dans le Makefile — gates NON exécutés. Ajoute-les (cf. templates/Makefile)." 1>&2
  exit 0
fi

echo "commit-gate: make $target ..." 1>&2
if ! make "$target" 1>&2; then
  echo "commit-gate: 'make $target' a échoué, commit bloqué. Corrige les gates avant de committer (suite complète via 'make check' / CI au push)." 1>&2
  exit 2
fi
