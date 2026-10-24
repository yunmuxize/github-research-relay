#!/usr/bin/env bash
set -euo pipefail
# Optional opt-in: adds a SHORT global instruction to all OpenCode sessions.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/opencode/AGENTS.md"
mkdir -p "$(dirname "$TARGET")"
if [ -f "$TARGET" ] && grep -qF '<!-- research-relay global rule: BEGIN -->' "$TARGET"; then
  echo 'Research Relay global rule already present; skipping.'
  exit 0
fi
if [ -f "$TARGET" ]; then
  cp "$TARGET" "$TARGET.research-relay.bak"
  echo "Backed up previous instructions to $TARGET.research-relay.bak"
  printf '\n\n' >> "$TARGET"
fi
cat "$SCRIPT_DIR/AGENTS.global.fragment.md" >> "$TARGET"
echo "Installed global OpenCode rules at $TARGET"
