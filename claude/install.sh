#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/CLAUDE.md"
TARGET="$HOME/.claude/CLAUDE.md"

mkdir -p "$HOME/.claude"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  echo "Error: $TARGET already exists and is not a symlink. Please remove it manually."
  exit 1
fi

ln -sf "$SOURCE" "$TARGET"
echo "Symlink created: $TARGET -> $SOURCE"
