#!/bin/bash
# kairos-dream.sh — KAIROS autoDream memory consolidation.
# Run by Coordinator when idle or via /dream command.
#
# Steps:
#   1. Scan today's transcript for unprocessed events
#   2. Check INDEX.md consistency (missing files, stale status)
#   3. Archive old transcripts (>7 days)
#   4. Report summary
#
# Usage: kairos-dream.sh [--quiet]

set -euo pipefail
source "$HOME/agents/config.env" 2>/dev/null || true

MEMORY_DIR="$HOME/agents/memory/${PROJECT_NAME:-default}"
TODAY=$(date +%Y-%m-%d)
TRANSCRIPT="$MEMORY_DIR/transcripts/${TODAY}-session.log"
INDEX="$MEMORY_DIR/INDEX.md"
QUIET="${1:-}"

log() { [ "$QUIET" != "--quiet" ] && echo "$*"; }

log "🌙 KAIROS autoDream starting..."
log ""

# ── Step 1: Scan transcript ──
MERGES=0; ERRORS=0; DECISIONS=0
if [ -f "$TRANSCRIPT" ]; then
  MERGES=$(grep -ci "merged\|approved" "$TRANSCRIPT" 2>/dev/null || echo 0)
  ERRORS=$(grep -ci "error\|failed\|rejected\|blocked" "$TRANSCRIPT" 2>/dev/null || echo 0)
  DECISIONS=$(grep -ci "decision\|decided\|switched\|disabled\|enabled" "$TRANSCRIPT" 2>/dev/null || echo 0)
  TOTAL=$(wc -l < "$TRANSCRIPT" | tr -d ' ')
  log "📊 Today's transcript: $TOTAL events ($MERGES merges, $ERRORS errors, $DECISIONS decisions)"
else
  log "📊 No transcript for today yet."
fi

# ── Step 2: Check INDEX.md consistency ──
ISSUES=0
if [ -f "$INDEX" ]; then
  log ""
  log "🔍 Checking INDEX.md consistency..."

  # Verify topic files exist
  while IFS= read -r line; do
    TOPIC_PATH=$(echo "$line" | grep -o 'topics/[^ ]*' 2>/dev/null) || continue
    if [ -n "$TOPIC_PATH" ] && [ ! -f "$MEMORY_DIR/$TOPIC_PATH" ]; then
      log "  ⚠️ Missing: $TOPIC_PATH"
      ISSUES=$((ISSUES + 1))
    fi
  done < "$INDEX"

  # Check topic files not in INDEX
  for f in "$MEMORY_DIR"/topics/*.md; do
    [ -f "$f" ] || continue
    BASENAME=$(basename "$f" .md)
    if ! grep -q "topics/${BASENAME}.md" "$INDEX" 2>/dev/null; then
      log "  ⚠️ Orphan topic (not in INDEX): $BASENAME"
      ISSUES=$((ISSUES + 1))
    fi
  done

  if [ "$ISSUES" -eq 0 ]; then
    log "  ✅ INDEX.md consistent"
  else
    log "  ⚠️ $ISSUES issues found"
  fi
fi

# ── Step 3: Archive old transcripts ──
ARCHIVED=0
if [ -d "$MEMORY_DIR/transcripts" ]; then
  for f in "$MEMORY_DIR"/transcripts/*.log; do
    [ -f "$f" ] || continue
    FILE_DATE=$(basename "$f" -session.log)
    # Check if older than 7 days
    if [ "$(date -j -f '%Y-%m-%d' "$FILE_DATE" +%s 2>/dev/null || echo 0)" -lt "$(date -v-7d +%s 2>/dev/null || echo 999999999)" ]; then
      gzip "$f" 2>/dev/null && ARCHIVED=$((ARCHIVED + 1))
    fi
  done
  if [ "$ARCHIVED" -gt 0 ]; then
    log ""
    log "🗜️ Archived $ARCHIVED old transcript(s)"
  fi
fi

# ── Step 4: Summary ──
log ""
log "✅ KAIROS autoDream complete"

# Output JSON for programmatic use
python3 -c "
import json
print(json.dumps({
    'merges': $MERGES,
    'errors': $ERRORS,
    'decisions': $DECISIONS,
    'index_issues': $ISSUES,
    'archived': $ARCHIVED,
    'date': '$TODAY'
}))" 2>/dev/null
