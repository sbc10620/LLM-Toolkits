#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.claude"

# --- CLAUDE.md symlink ---
SOURCE_MD="$SCRIPT_DIR/CLAUDE.md"
TARGET_MD="$HOME/.claude/CLAUDE.md"

if [ -e "$TARGET_MD" ] && [ ! -L "$TARGET_MD" ]; then
  echo "Error: $TARGET_MD already exists and is not a symlink. Please remove it manually."
  exit 1
fi

ln -sf "$SOURCE_MD" "$TARGET_MD"
echo "Symlink created: $TARGET_MD -> $SOURCE_MD"

# --- statusline-command.sh symlink ---
SOURCE_SL="$SCRIPT_DIR/statusline-command.sh"
TARGET_SL="$HOME/.claude/statusline-command.sh"

if [ -e "$TARGET_SL" ] && [ ! -L "$TARGET_SL" ]; then
  echo "Error: $TARGET_SL already exists and is not a symlink. Please remove it manually."
  exit 1
fi

ln -sf "$SOURCE_SL" "$TARGET_SL"
echo "Symlink created: $TARGET_SL -> $SOURCE_SL"

# --- settings.json: add statusLine entry if missing ---
SETTINGS="$HOME/.claude/settings.json"
STATUS_LINE_COMMAND="sh $HOME/.claude/statusline-command.sh"

if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

if ! jq -e '.statusLine' "$SETTINGS" > /dev/null 2>&1; then
  tmp=$(mktemp)
  jq --arg cmd "$STATUS_LINE_COMMAND" \
    '.statusLine = {"type": "command", "command": $cmd}' \
    "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "settings.json updated: statusLine added"
else
  echo "settings.json: statusLine already present, skipping"
fi
