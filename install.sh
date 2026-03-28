#!/bin/bash
# ClaudeBot Install — symlink files to correct locations
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "🚀 Installing ClaudeBot from $DIR"

# Agent definitions → ~/.claude/agents/
mkdir -p ~/.claude/agents
for f in "$DIR"/agents/*.md; do
  ln -sf "$f" ~/.claude/agents/"$(basename $f)"
  echo "  ✅ Agent: $(basename $f)"
done

# Scripts → ~/scripts/
mkdir -p ~/scripts
for f in "$DIR"/scripts/*.sh; do
  ln -sf "$f" ~/scripts/"$(basename $f)"
  chmod +x "$f"
  echo "  ✅ Script: $(basename $f)"
done

# Commands → ~/.claude/commands/
mkdir -p ~/.claude/commands
for f in "$DIR"/commands/*.md; do
  ln -sf "$f" ~/.claude/commands/"$(basename $f)"
  echo "  ✅ Command: $(basename $f)"
done

# Config
mkdir -p ~/agents/memory ~/agents/hooks ~/logs
if [ ! -f ~/agents/config.env ]; then
  cp "$DIR/config.env" ~/agents/config.env
  echo "  ✅ Config: ~/agents/config.env (EDIT THIS)"
else
  echo "  ⏭️ Config exists, skipping"
fi

# Hooks
ln -sf "$DIR/agents/hooks/post_failure.sh" ~/agents/hooks/
chmod +x "$DIR/agents/hooks/post_failure.sh"

# Startup script
ln -sf "$DIR/start.sh" ~/.claude/scheduled/multi-agent-start.sh
chmod +x "$DIR/start.sh"

# Launchd (optional)
if [ ! -f ~/Library/LaunchAgents/com.claudebot.agents.plist ]; then
  cp "$DIR/com.claudebot.agents.plist" ~/Library/LaunchAgents/
  echo "  ✅ Launchd: auto-start on boot"
  echo "     Run: launchctl load ~/Library/LaunchAgents/com.claudebot.agents.plist"
else
  echo "  ⏭️ Launchd exists, skipping"
fi

# Memory templates
if [ ! -f ~/agents/memory/lessons.md ]; then
  cat > ~/agents/memory/lessons.md << 'EOF'
# Lessons Learned

## Guiding Principles (từ success)

## Cautionary Principles (từ failure)

## Error Tracker (count → promote khi >= 3)
EOF
  echo "  ✅ Memory templates created"
fi

if [ ! -f ~/agents/GOALS.md ]; then
  echo "# Project Goals\n\nChạy /scan để phát hiện goals." > ~/agents/GOALS.md
  echo "  ✅ GOALS.md created"
fi

echo ""
echo "🎉 ClaudeBot installed!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/agents/config.env (project path + GitHub repo)"
echo "  2. Setup Telegram: ~/.claude/channels/telegram/.env"
echo "  3. Run: ~/.claude/scheduled/multi-agent-start.sh"
echo "  4. Send /go on Telegram"
