#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"

# Detect target directory
if [ -n "${1:-}" ]; then
    TARGET="$1"
elif [ -d "$HOME/.config/opencode/skills" ]; then
    TARGET="$HOME/.config/opencode/skills"
elif [ -d "$HOME/.claude/skills" ]; then
    TARGET="$HOME/.claude/skills"
else
    # Default to OpenCode location
    TARGET="$HOME/.config/opencode/skills"
fi

echo "Installing EvoPrompt skills to: $TARGET"

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    dest="$TARGET/$skill_name"
    mkdir -p "$dest"
    cp "$skill_dir"SKILL.md "$dest/SKILL.md"
    echo "  Installed: $skill_name"
done

echo "Done. $( ls -1d "$SKILLS_SRC"/*/ | wc -l | tr -d ' ' ) skills installed."
