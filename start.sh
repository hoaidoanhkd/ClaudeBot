#!/bin/bash
# ClaudeBot Multi-Agent Startup
# Starts 1 coordinator (channel + peers) + 2 workers (peers only)
# Config from ~/agents/config.env

set -euo pipefail

# Load config
source "$HOME/agents/config.env"

# Load active channel (only 1 channel at a time)
ACTIVE_CHANNEL=$(cat ~/agents/active-channel.txt 2>/dev/null || echo "telegram")
CHANNELS=""
case "$ACTIVE_CHANNEL" in
  telegram) CHANNELS="plugin:telegram@claude-plugins-official" ;;
  discord)  CHANNELS="plugin:discord@claude-plugins-official" ;;
  *)        CHANNELS="plugin:telegram@claude-plugins-official" ;;
esac

echo "🚀 Starting ClaudeBot for $PROJECT_NAME..."
echo "   Project:  $PROJECT_PATH"
echo "   GitHub:   $GITHUB_REPO"
echo "   Channels: ${CHANNELS:-none}"

# Save session state before killing
if [ -f ~/scripts/session-save.sh ]; then
  bash ~/scripts/session-save.sh 2>/dev/null || true
fi

# Kill old sessions if exist
tmux kill-session -t cc-coordinator 2>/dev/null || true
tmux kill-session -t cc-coder 2>/dev/null || true
tmux kill-session -t cc-reviewer 2>/dev/null || true

# Kill old daemons
pkill -f "agent-watchdog.sh" 2>/dev/null || true
pkill -f "agent-keepalive.sh" 2>/dev/null || true
pkill -f "ci-monitor.sh" 2>/dev/null || true

# Kill old broker (claude-peers-mcp location may vary)
if [ -d ~/claude-peers-mcp ]; then
  cd ~/claude-peers-mcp && bun cli.ts kill-broker 2>/dev/null || true
else
  echo "Skipping broker kill — ~/claude-peers-mcp not found"
fi
sleep 2

echo "📡 Starting Coordinator [model: opus]..."
if [ -n "$CHANNELS" ]; then
  COORDINATOR_CMD="cd $PROJECT_PATH && claude --enable-auto-mode --agent coordinator --channels $CHANNELS --dangerously-load-development-channels server:claude-peers"
else
  COORDINATOR_CMD="cd $PROJECT_PATH && claude --enable-auto-mode --agent coordinator --dangerously-load-development-channels server:claude-peers"
fi
tmux new-session -d -s cc-coordinator "$COORDINATOR_CMD"

sleep 5
echo "⏳ Confirming channel prompts..."
tmux send-keys -t cc-coordinator Enter
sleep 1
echo "✅ Coordinator started"

echo "💻 Starting Coder Agent [model: opus]..."
tmux new-session -d -s cc-coder \
  "cd $PROJECT_PATH && claude --enable-auto-mode --agent coder --dangerously-load-development-channels server:claude-peers"

sleep 5
tmux send-keys -t cc-coder Enter
sleep 2
echo "✅ Coder started"

echo "🔍 Starting Senior Reviewer [model: opus]..."
tmux new-session -d -s cc-reviewer \
  "cd $PROJECT_PATH && claude --enable-auto-mode --agent senior-reviewer --dangerously-load-development-channels server:claude-peers"

sleep 5
tmux send-keys -t cc-reviewer Enter
sleep 1
echo "✅ Reviewer started"

# Check all peers
echo ""
echo "📊 Checking peers status..."
if [ -d ~/claude-peers-mcp ]; then
  cd ~/claude-peers-mcp && bun cli.ts status
fi

echo ""
if [ -f ~/scripts/agent-watchdog.sh ]; then
  echo "Starting Watchdog (${WATCHDOG_INTERVAL}s)..."
  nohup ~/scripts/agent-watchdog.sh >> ~/logs/agent-watchdog.log 2>&1 &
  echo "Watchdog PID: $!"
else
  echo "Skipping watchdog — ~/scripts/agent-watchdog.sh not found"
fi


if [ -f ~/scripts/agent-keepalive.sh ]; then
  echo "Starting Keepalive (${KEEPALIVE_INTERVAL}s)..."
  nohup ~/scripts/agent-keepalive.sh >> ~/logs/agent-keepalive.log 2>&1 &
  echo "Keepalive PID: $!"
else
  echo "Skipping keepalive — ~/scripts/agent-keepalive.sh not found"
fi

if [ -f ~/scripts/ci-monitor.sh ]; then
  echo "Starting CI Monitor (${CI_MONITOR_INTERVAL}s)..."
  nohup ~/scripts/ci-monitor.sh >> ~/logs/ci-monitor.log 2>&1 &
  echo "CI Monitor PID: $!"
else
  echo "Skipping CI monitor — ~/scripts/ci-monitor.sh not found"
fi

# Generate repo map for agents
echo ""
if [ -f ~/scripts/repo-map.sh ]; then
  echo "🗺️ Generating repo map..."
  bash ~/scripts/repo-map.sh "$PROJECT_PATH" ~/agents/repo-map.md 2>/dev/null && \
    echo "Repo map: ~/agents/repo-map.md" || echo "Skipping repo map"
fi

echo ""
echo "⏳ Auto-bootstrap via tmux input..."
sleep 5
for s in cc-coordinator cc-coder cc-reviewer; do
  tmux send-keys -t $s "BOOTSTRAP: Execute your ON STARTUP instructions now. Set summary, list peers, read memory files, read lessons.md." Enter
  sleep 2
done
echo "✅ Bootstrap triggered"

echo "⏳ Waiting for bootstrap completion (15s)..."
sleep 15

echo ""
echo "📋 Syncing Goals → GitHub Issues..."
if [ -f ~/scripts/goals-sync.sh ]; then
  ~/scripts/goals-sync.sh --push 2>&1 | tail -3
else
  echo "Skipping goals sync — ~/scripts/goals-sync.sh not found"
fi

echo ""
echo "🎉 Multi-Agent System Ready! [$PROJECT_NAME]"
echo ""
echo "Management:"
echo "  tmux attach -t cc-coordinator"
echo "  tmux attach -t cc-coder"
echo "  tmux attach -t cc-reviewer"
echo "  ~/scripts/agent-health.sh"
echo ""
echo "Switch project: edit ~/agents/config.env"
