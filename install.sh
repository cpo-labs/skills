#!/usr/bin/env bash
# Installs all skills from this repo into ~/.claude/skills/
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"
for dir in "$SRC"/*/; do
  name="$(basename "$dir")"
  if [ -e "$DEST/$name" ]; then
    echo "skip  $name (already exists - remove it first to update)"
  else
    cp -R "$dir" "$DEST/$name"
    echo "added $name"
  fi
done
echo "Done. Restart Claude Code or start a new session to pick up the skills."
