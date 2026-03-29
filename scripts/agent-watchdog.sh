#!/bin/bash
# agent-watchdog.sh — Monitors tmux agent sessions and restarts them if they die.
# Sources ~/agents/config.env for WATCHDOG_INTERVAL and PROJECT_PATH.
set -euo pipefail

source "$HOME/agents/config.env"

INTERVAL="${WATCHDOG_INTERVAL:-30}"
LOG_FILE="$HOME/logs/agent-watchdog.log"
mkdir -p "$HOME/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Build channel flag for coordinator (reads active-channel.txt, same as start.sh)
build_channels() {
  local active
  active=$(cat "$HOME/agents/active-channel.txt" 2>/dev/null || echo "telegram")
  case "$active" in
    telegram) echo "plugin:telegram@claude-plugins-official" ;;
    discord)  echo "plugin:discord@claude-plugins-official" ;;
    *)        echo "plugin:telegram@claude-plugins-official" ;;
  esac
}

restart_session() {
  local session="$1"
  local cmd=""

  case "$session" in
    cc-coordinator)
      local channels
      channels="$(build_channels)"
      if [ -n "$channels" ]; then
        cmd="cd $PROJECT_PATH && claude --agent coordinator --channels $channels --dangerously-load-development-channels server:claude-peers"
      else
        cmd="cd $PROJECT_PATH && claude --agent coordinator --dangerously-load-development-channels server:claude-peers"
      fi
      ;;
    cc-coder)
      cmd="cd $PROJECT_PATH && claude --agent coder --dangerously-load-development-channels server:claude-peers"
      ;;
    cc-reviewer)
      cmd="cd $PROJECT_PATH && claude --agent senior-reviewer --dangerously-load-development-channels server:claude-peers"
      ;;
    *)
      log "ERROR: Unknown session $session"
      return 1
      ;;
  esac

  log "RESTART: $session — recreating tmux session"
  tmux new-session -d -s "$session" "$cmd"
  sleep 5
  tmux send-keys -t "$session" Enter 2>/dev/null || true
  sleep 2
  tmux send-keys -t "$session" "BOOTSTRAP: Execute your ON STARTUP instructions now. Set summary, list peers, read memory files." Enter 2>/dev/null || true
  log "RESTART: $session — done"
}

log "Watchdog started (interval: ${INTERVAL}s)"

while true; do
  for session in cc-coordinator cc-coder cc-reviewer; do
    if ! tmux has-session -t "$session" 2>/dev/null; then
      log "DEAD: $session — restarting..."
      restart_session "$session"
    fi
  done
  sleep "$INTERVAL"
done
