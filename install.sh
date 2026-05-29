#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

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
  link "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
fi

echo
echo "Standards and workflow installed. Open any project and run /feature."
