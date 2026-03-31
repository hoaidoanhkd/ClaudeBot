#!/bin/bash
# memory-log.sh — Append to daily transcript log (Layer 3).
# Usage: memory-log.sh "AGENT" "message"

set -euo pipefail
source "$HOME/agents/config.env" 2>/dev/null || true

AGENT="${1:?Usage: memory-log.sh AGENT message}"
MESSAGE="${2:?Usage: memory-log.sh AGENT message}"
TRANSCRIPT_DIR="$HOME/agents/memory/${PROJECT_NAME:-default}/transcripts"
TODAY=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

mkdir -p "$TRANSCRIPT_DIR"
echo "[$TIME] $AGENT: $MESSAGE" >> "$TRANSCRIPT_DIR/${TODAY}-session.log"
