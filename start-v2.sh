#!/bin/bash
# ClaudeBot v2.0 — Start using Agent Teams
# Starts 1 lead (Coordinator) with Discord channel
# Lead spawns teammates: Coder, Reviewer
# QA + Researcher spawned on-demand
set -uo pipefail

source "$HOME/agents/config.env"

# Update additionalDirectories in settings.json with current project path
python3 -c "
import json, os, sys
settings_path = os.path.expanduser('~/.claude/settings.json')
project_path = os.path.expandvars(sys.argv[1])
with open(settings_path, 'r') as f:
    s = json.load(f)
dirs = s.setdefault('permissions', {}).setdefault('additionalDirectories', [])
base = [os.path.expanduser('~/agents')]
if project_path not in base:
    base.append(project_path)
s['permissions']['additionalDirectories'] = base
with open(settings_path, 'w') as f:
    json.dump(s, f, indent=2)
" "$PROJECT_PATH" 2>/dev/null || true

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
