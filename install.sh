#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"

mkdir -p "$CLAUDE_DIR" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks"

link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "backup: $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -sfn "$src" "$dest"
  echo "linked: $dest -> $src"
}

prune() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  for ln_path in "$dir"/*; do
    [ -L "$ln_path" ] || continue
    target="$(readlink "$ln_path")"
    case "$target" in
      "$REPO_DIR"/*)
        if [ ! -e "$ln_path" ]; then
          echo "prune (lien orphelin): $ln_path"
          rm -f "$ln_path"
        fi
        ;;
    esac
  done
}

prune "$CLAUDE_DIR/skills"
prune "$CLAUDE_DIR/agents"
prune "$CLAUDE_DIR/hooks"

link "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
link "$REPO_DIR/workflow.json" "$CLAUDE_DIR/workflow.json"

for skill in "$REPO_DIR/skills"/*/; do
  link "${skill%/}" "$CLAUDE_DIR/skills/$(basename "$skill")"
done

for agent in "$REPO_DIR/agents"/*.md; do
  link "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
done

for hook in "$REPO_DIR/hooks"/*.sh; do
  chmod +x "$hook"
  link "$hook" "$CLAUDE_DIR/hooks/$(basename "$hook")"
done

if [ "${LINK_SETTINGS:-0}" = "1" ]; then
  echo
  echo "/!\\ LINK_SETTINGS=1 : $CLAUDE_DIR/settings.json va etre REMPLACE par celui du depot"
  echo "    (symlink, pas de merge). Tes reglages perso non-symlink sont sauvegardes en .bak."
  echo "    Sans ecrasement : copie plutot le contenu dans .claude/settings.json du projet."
  link "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
fi

echo
echo "Standards and workflow installed. Open any project and run /feature."
