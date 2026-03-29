#!/bin/bash
# agent-keepalive.sh — Sends periodic keepalive pings to agent tmux sessions
# to prevent Claude Code from timing out due to inactivity.
# Sources ~/agents/config.env for KEEPALIVE_INTERVAL.
set -euo pipefail

source "$HOME/agents/config.env"

INTERVAL="${KEEPALIVE_INTERVAL:-60}"
SESSIONS=(cc-coordinator cc-coder cc-reviewer)

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Keepalive started (interval: ${INTERVAL}s)"

while true; do
  for session in "${SESSIONS[@]}"; do
    if tmux has-session -t "$session" 2>/dev/null; then
      tmux send-keys -t "$session" "" 2>/dev/null || true
    fi
  done
  sleep "$INTERVAL"
done
