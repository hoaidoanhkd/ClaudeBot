#!/bin/bash
# secret-scan.sh — Scan git diff for leaked secrets before merge
# Usage: secret-scan.sh [PR_NUMBER]
set -euo pipefail
source "$HOME/agents/config.env"

PR_NUM="${1:-}"
FOUND=0

echo "=== Secret Scan ==="

# Get diff to scan
if [ -n "$PR_NUM" ]; then
  echo "Scanning PR #$PR_NUM..."
  DIFF=$(gh pr diff "$PR_NUM" --repo "$GITHUB_REPO" 2>/dev/null)
else
  echo "Scanning staged changes..."
  cd "$PROJECT_PATH"
  DIFF=$(git diff --cached 2>/dev/null || git diff 2>/dev/null)
fi

if [ -z "$DIFF" ]; then
  echo "No changes to scan."
  exit 0
fi

# Pattern checks
check_pattern() {
  local name="$1"
  local pattern="$2"
  local matches
  matches=$(echo "$DIFF" | grep -nE "^\+" | grep -E "$pattern" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    echo "  ❌ $name:"
    echo "$matches" | head -3 | sed 's/^/     /'
    FOUND=$((FOUND + 1))
  fi
}

echo ""
check_pattern "API Keys" "(api[_-]?key|apikey)\s*[=:]\s*['\"][a-zA-Z0-9]"
check_pattern "AWS Keys" "AKIA[0-9A-Z]{16}"
check_pattern "Private Keys" "-----BEGIN (RSA |EC |DSA )?PRIVATE KEY"
check_pattern "Bot Tokens" "bot[0-9]+:[A-Za-z0-9_-]{35}"
check_pattern "Discord Tokens" "[MN][A-Za-z0-9]{23,}\.[A-Za-z0-9_-]{6}\.[A-Za-z0-9_-]{27}"
check_pattern "Bearer Tokens" "bearer\s+[a-zA-Z0-9_-]{20,}"
check_pattern "Hardcoded Passwords" "(password|passwd|pwd)\s*[=:]\s*['\"][^'\"]{8,}"
check_pattern "Connection Strings" "(mongodb|postgres|mysql|redis)://[^\s]+"
check_pattern "Hardcoded IPs" "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]+"

echo ""
if [ "$FOUND" -gt 0 ]; then
  echo "⚠️  Found $FOUND potential secret(s). Review before merging!"
  exit 1
else
  echo "✅ No secrets detected."
  exit 0
fi
