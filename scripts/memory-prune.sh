#!/bin/bash
# memory-prune.sh — Remove outdated lessons older than 30 days
# Run periodically to prevent memory bloat
set -euo pipefail

MEMORY_DIR="$HOME/agents/memory"
SHARED_DIR="$MEMORY_DIR/shared"
MAX_AGE_DAYS="${1:-30}"

echo "=== Memory Pruning ==="
echo "Removing entries older than $MAX_AGE_DAYS days"
echo ""

prune_file() {
  local file="$1"
  if [ ! -f "$file" ]; then return; fi

  local lines_before
  lines_before=$(wc -l < "$file" | tr -d ' ')

  # Remove entries with dates older than MAX_AGE_DAYS
  local cutoff
  cutoff=$(date -v-${MAX_AGE_DAYS}d +%Y-%m-%d 2>/dev/null || date -d "$MAX_AGE_DAYS days ago" +%Y-%m-%d)

  # Create temp file with only recent entries
  local temp
  temp=$(mktemp)
  local keep=true
  local section_date=""

  while IFS= read -r line; do
    # Detect date headers like "## 2026-03-28 —" or "- [2026-03-28]"
    if echo "$line" | grep -qE '^\#\# [0-9]{4}-[0-9]{2}-[0-9]{2}'; then
      section_date=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
      if [[ "$section_date" < "$cutoff" ]]; then
        keep=false
      else
        keep=true
      fi
    fi
    if [ "$keep" = true ]; then
      echo "$line" >> "$temp"
    fi
  done < "$file"

  local lines_after
  lines_after=$(wc -l < "$temp" | tr -d ' ')
  local removed=$((lines_before - lines_after))

  if [ "$removed" -gt 0 ]; then
    mv "$temp" "$file"
    echo "  $(basename "$file"): removed $removed lines"
  else
    rm "$temp"
    echo "  $(basename "$file"): no old entries"
  fi
}

# Prune all memory files
for f in "$MEMORY_DIR"/*.md "$SHARED_DIR"/*.md; do
  [ -f "$f" ] || continue
  prune_file "$f"
done

echo ""
echo "Done."
