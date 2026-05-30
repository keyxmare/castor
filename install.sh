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

link "$REPO_DIR/.claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
link "$REPO_DIR/.claude/workflow.json" "$CLAUDE_DIR/workflow.json"

for skill in "$REPO_DIR/.claude/skills"/*/; do
  link "${skill%/}" "$CLAUDE_DIR/skills/$(basename "$skill")"
done

for agent in "$REPO_DIR/.claude/agents"/*.md; do
  link "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
done

for hook in "$REPO_DIR/.claude/hooks"/*.sh; do
  chmod +x "$hook"
  link "$hook" "$CLAUDE_DIR/hooks/$(basename "$hook")"
done

echo
echo "/!\\ settings.json n'est PAS lie globalement : ses hooks sont desormais projet-relatifs"
echo "    (\$CLAUDE_PROJECT_DIR/.claude/hooks/...). Un lien global les ferait echouer hors d'un"
echo "    projet conforme. Le settings.json + hooks vivent dans .claude/ et se chargent tout"
echo "    seuls a l'ouverture du projet. Pour des hooks globaux, adapte les chemins a la main."

echo
echo "Standards and workflow installed. Open any project and run /feature."
