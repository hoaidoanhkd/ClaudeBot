#!/bin/bash
# ClaudeBot Uninstall — remove symlinks and config created by install.sh
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
# shellcheck disable=SC2034
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}+${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
err()  { echo -e "  ${RED}x${NC} $1"; }

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${RED}  ClaudeBot Uninstaller${NC}"
echo -e "  ${DIM}This will remove files created by install.sh${NC}"
echo ""

# ── Collect items to remove ──────────────────────────────────────────────────
ITEMS=()

# Agent symlinks in ~/.claude/agents/
for f in "$DIR"/agents/*.md; do
  [ -f "$f" ] || continue
  target=~/.claude/agents/"$(basename "$f")"
  [ -L "$target" ] && ITEMS+=("$target")
done

# Script symlinks in ~/scripts/
for f in "$DIR"/scripts/*.sh; do
  [ -f "$f" ] || continue
  target=~/scripts/"$(basename "$f")"
  [ -L "$target" ] && ITEMS+=("$target")
done

# Command symlinks in ~/.claude/commands/
for f in "$DIR"/commands/*.md; do
  [ -f "$f" ] || continue
  target=~/.claude/commands/"$(basename "$f")"
  [ -L "$target" ] && ITEMS+=("$target")
done

# Hook symlinks
[ -L ~/agents/hooks/post_failure.sh ] && ITEMS+=(~/agents/hooks/post_failure.sh)

# Startup symlink
[ -L ~/.claude/scheduled/multi-agent-start.sh ] && ITEMS+=(~/.claude/scheduled/multi-agent-start.sh)

# Config file
[ -f ~/agents/config.env ] && ITEMS+=(~/agents/config.env)

# Launchd plist
PLIST=~/Library/LaunchAgents/com.claudebot.agents.plist
[ -f "$PLIST" ] && ITEMS+=("$PLIST")

# ── Show what will be removed ────────────────────────────────────────────────
if [ ${#ITEMS[@]} -eq 0 ]; then
  echo -e "  ${DIM}Nothing to remove. ClaudeBot is not installed (or was already uninstalled).${NC}"
  echo ""
  exit 0
fi

echo -e "${BOLD}The following will be removed:${NC}"
echo ""
for item in "${ITEMS[@]}"; do
  echo -e "  ${RED}-${NC} ${item/#$HOME/~}"
done
echo ""

echo -e "  ${DIM}NOTE: ~/.claude/channels/ is NOT removed (contains tokens — remove manually if needed).${NC}"
echo ""

# ── Confirm ──────────────────────────────────────────────────────────────────
echo -en "${YELLOW}?${NC} Proceed with uninstall? (y/N): "
read -r yn
case "$yn" in
  [yY]|[yY][eE][sS]) ;;
  *)
    echo ""
    echo -e "  ${DIM}Aborted.${NC}"
    echo ""
    exit 0
    ;;
esac

echo ""

# ── Unload launchd if plist exists ───────────────────────────────────────────
if [ -f "$PLIST" ]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  ok "Unloaded launchd agent"
fi

# ── Remove items ─────────────────────────────────────────────────────────────
for item in "${ITEMS[@]}"; do
  rm -f "$item"
  ok "Removed ${item/#$HOME/~}"
done

echo ""
echo -e "${GREEN}${BOLD}ClaudeBot uninstalled.${NC}"
echo ""
echo -e "  ${DIM}To fully clean up, you may also want to remove:${NC}"
echo -e "  ${DIM}  rm -rf ~/agents/memory/              # agent memory files${NC}"
echo -e "  ${DIM}  rm -rf ~/.claude/channels/            # bot tokens${NC}"
echo -e "  ${DIM}  rm -rf ~/logs/                        # agent logs${NC}"
echo ""
