#!/usr/bin/env bash
set -euo pipefail
# Installs the worker Skill into a global OpenCode skill directory.
# This script changes ONLY ~/.config/opencode/skills/research-relay-worker.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HOME}/.config/opencode/skills/research-relay-worker"
mkdir -p "$DEST"
if [[ -e "$DEST/SKILL.md" ]]; then
    echo "Existing skill detected at $DEST/SKILL.md; no overwrite. Review it manually." >&2
    exit 1
fi
cp "$SCRIPT_DIR/.opencode/skills/research-relay-worker/SKILL.md" "$DEST/SKILL.md"
echo "Installed OpenCode skill: $DEST/SKILL.md"
echo "Restart OpenCode, then ask it to load 'research-relay-worker'."
