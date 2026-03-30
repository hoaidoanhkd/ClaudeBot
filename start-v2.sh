#!/bin/bash
# ClaudeBot v2.0 — Start using Agent Teams
# Starts 1 lead (Coordinator) with Discord channel
# Lead spawns teammates: Coder, Reviewer
# QA + Researcher spawned on-demand
set -uo pipefail

source "$HOME/agents/config.env"

# Load active channel
ACTIVE_CHANNEL=$(cat ~/agents/active-channel.txt 2>/dev/null || echo "telegram")
CHANNEL=""
case "$ACTIVE_CHANNEL" in
  telegram) CHANNEL="plugin:telegram@claude-plugins-official" ;;
  discord)  CHANNEL="plugin:discord@claude-plugins-official" ;;
  *)        CHANNEL="plugin:telegram@claude-plugins-official" ;;
esac

echo "🚀 ClaudeBot v2.0 — Agent Teams"
echo "   Project:  $PROJECT_PATH"
echo "   Channel:  $ACTIVE_CHANNEL"
echo ""

# Generate repo map
if [ -f ~/scripts/repo-map.sh ]; then
  echo "🗺️ Generating repo map..."
  bash ~/scripts/repo-map.sh "$PROJECT_PATH" ~/agents/repo-map.md 2>/dev/null || true
fi

# Save session state
if [ -f ~/scripts/session-save.sh ]; then
  bash ~/scripts/session-save.sh 2>/dev/null || true
fi

echo ""
echo "📡 Starting Lead (Coordinator) with Agent Teams..."
echo "   Lead will spawn Coder + Reviewer teammates automatically."
echo ""
echo "   Commands: /go, /status, /progress, /brainstorm, /evolve, /qa"
echo "   Stop: /stop or Ctrl+C"
echo ""

# Start Claude Code as lead with Agent Teams + Discord channel
cd "$PROJECT_PATH" && claude \
  --enable-auto-mode \
  --agent coordinator \
  --channels "$CHANNEL" \
  --dangerously-load-development-channels server:claude-peers
