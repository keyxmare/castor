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

if [ ! -f Makefile ]; then
  echo "commit-gate: aucun Makefile — gates qualité NON exécutés, commit autorisé SANS filet. Voir le Makefile de référence de ce dépôt Castor." 1>&2
  exit 0
fi

target=""
if grep -qE '^check-fast[[:space:]]*:' Makefile; then
  target="check-fast"
elif grep -qE '^check[[:space:]]*:' Makefile; then
  target="check"
else
  echo "commit-gate: ni cible 'check-fast' ni 'check' dans le Makefile — gates NON exécutés. Ajoute-les (cf. le Makefile de référence)." 1>&2
  exit 0
fi

echo "commit-gate: make $target ..." 1>&2
if ! make "$target" 1>&2; then
  echo "commit-gate: 'make $target' a échoué, commit bloqué. Corrige les gates avant de committer (suite complète via 'make check' / CI au push)." 1>&2
  exit 2
fi
