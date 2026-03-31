#!/bin/bash
# agent-watchdog.sh — 3-tier health monitoring for agent sessions.
#
# Tier 0: Process liveness — is tmux session alive? (every check)
# Tier 1: Activity check — is agent actually responding? (every 3 checks)
#         Captures tmux pane, compares with previous. If identical for 3 cycles → frozen.
# Tier 2: Auto-restart + notification (when Tier 0 or Tier 1 fails)
#
# Sources ~/agents/config.env for WATCHDOG_INTERVAL and PROJECT_PATH.

set -euo pipefail

source "$HOME/agents/config.env"

INTERVAL="${WATCHDOG_INTERVAL:-30}"
LOG_FILE="$HOME/logs/agent-watchdog.log"
PANE_CACHE_DIR="/tmp/claudebot-watchdog"
FROZEN_THRESHOLD=3  # cycles with no activity → frozen

mkdir -p "$HOME/logs" "$PANE_CACHE_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

notify() {
  local msg="$1"
  # macOS notification
  terminal-notifier -title "ClaudeBot Watchdog" -message "$msg" -sound Basso 2>/dev/null || true
  # Also log event for dashboard
  ~/Desktop/Projects/ClaudeBot/scripts/event-logger.sh status watchdog "$msg" 2>/dev/null || true
}

# Build channel flag for coordinator
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
  local reason="$2"
  local cmd=""

  case "$session" in
    cc-coordinator)
      local channels
      channels="$(build_channels)"
      if [ -n "$channels" ]; then
        cmd="cd $PROJECT_PATH && claude --enable-auto-mode --agent coordinator --channels $channels --dangerously-load-development-channels server:claude-peers"
      else
        cmd="cd $PROJECT_PATH && claude --enable-auto-mode --agent coordinator --dangerously-load-development-channels server:claude-peers"
      fi
      ;;
    cc-coder)
      cmd="cd $PROJECT_PATH && claude --enable-auto-mode --agent coder --dangerously-load-development-channels server:claude-peers"
      ;;
    cc-reviewer)
      cmd="cd $PROJECT_PATH && claude --enable-auto-mode --agent senior-reviewer --dangerously-load-development-channels server:claude-peers"
      ;;
    *)
      log "ERROR: Unknown session $session"
      return 1
      ;;
  esac

  log "RESTART: $session — $reason"
  notify "$session restarted: $reason"

  # Kill old session if exists (frozen case)
  tmux kill-session -t "$session" 2>/dev/null || true
  sleep 2

  tmux new-session -d -s "$session" "$cmd"
  sleep 5
  tmux send-keys -t "$session" Enter 2>/dev/null || true
  sleep 2
  tmux send-keys -t "$session" "BOOTSTRAP: Execute your ON STARTUP instructions now. Set summary, list peers, read memory files." Enter 2>/dev/null || true

  # Reset frozen counter
  rm -f "$PANE_CACHE_DIR/${session}.hash" "$PANE_CACHE_DIR/${session}.frozen"

  log "RESTART: $session — done"
}

# Tier 1: Check if agent pane output has changed
check_activity() {
  local session="$1"
  local hash_file="$PANE_CACHE_DIR/${session}.hash"
  local frozen_file="$PANE_CACHE_DIR/${session}.frozen"

  # Capture last 20 lines of pane
  local pane_content
  pane_content=$(tmux capture-pane -t "$session" -p 2>/dev/null | tail -20) || return 0

  # Hash current content
  local current_hash
  current_hash=$(echo "$pane_content" | md5 -q 2>/dev/null || echo "$pane_content" | md5sum 2>/dev/null | cut -d' ' -f1)

  # Compare with previous
  local prev_hash=""
  if [ -f "$hash_file" ]; then
    prev_hash=$(cat "$hash_file")
  fi

  echo "$current_hash" > "$hash_file"

  if [ "$current_hash" = "$prev_hash" ]; then
    # No change — increment frozen counter
    local frozen_count=0
    if [ -f "$frozen_file" ]; then
      frozen_count=$(cat "$frozen_file")
    fi
    frozen_count=$((frozen_count + 1))
    echo "$frozen_count" > "$frozen_file"

    if [ "$frozen_count" -ge "$FROZEN_THRESHOLD" ]; then
      log "FROZEN: $session — no activity for $frozen_count cycles ($(( frozen_count * INTERVAL ))s)"
      return 1  # frozen
    else
      log "IDLE: $session — no activity for $frozen_count cycle(s)"
    fi
  else
    # Activity detected — reset counter
    rm -f "$frozen_file"
  fi

  return 0  # OK
}

log "Watchdog started — 3-tier monitoring (interval: ${INTERVAL}s, frozen threshold: ${FROZEN_THRESHOLD} cycles)"

cycle=0
while true; do
  cycle=$((cycle + 1))

  for session in cc-coordinator cc-coder cc-reviewer; do
    # ── Tier 0: Process liveness ──
    if ! tmux has-session -t "$session" 2>/dev/null; then
      log "DEAD: $session — session not found"
      restart_session "$session" "session dead (Tier 0)"
      continue
    fi

    # ── Tier 1: Activity check (every 3 cycles to avoid false positives) ──
    if [ $((cycle % 3)) -eq 0 ]; then
      if ! check_activity "$session"; then
        # Tier 1 failed — check if agent prompt is waiting for input (not frozen)
        local pane_last
        pane_last=$(tmux capture-pane -t "$session" -p 2>/dev/null | tail -3)
        if echo "$pane_last" | grep -qE "^❯|^\? for shortcuts|^Esc to cancel"; then
          # Agent is at prompt — idle, not frozen. Send Enter to wake up.
          log "WAKE: $session — at idle prompt, sending nudge"
          tmux send-keys -t "$session" "" Enter 2>/dev/null || true
          rm -f "$PANE_CACHE_DIR/${session}.frozen"
        else
          # Actually frozen — Tier 2: restart
          restart_session "$session" "frozen for $((FROZEN_THRESHOLD * INTERVAL))s (Tier 1→2)"
        fi
      fi
    fi
  done

  sleep "$INTERVAL"
done
