#!/bin/bash
# secret-scan.sh — Scan git diff for leaked secrets and security violations before merge.
# Covers: API keys, tokens, private keys, connection strings, injection patterns,
#         exfiltration vectors, and dangerous shell patterns.
#
# Usage: secret-scan.sh [PR_NUMBER]
# Exit 0 = clean, Exit 1 = findings
set -euo pipefail
source "$HOME/agents/config.env"

PR_NUM="${1:-}"
FOUND=0
WARNINGS=0

echo "=== Secret & Security Scan ==="

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

# Only scan added lines (lines starting with +, excluding +++ headers)
ADDED=$(echo "$DIFF" | grep -E '^\+[^+]' || true)

if [ -z "$ADDED" ]; then
  echo "No added lines to scan."
  exit 0
fi

check_critical() {
  local name="$1"
  local pattern="$2"
  local matches
  matches=$(echo "$ADDED" | grep -nE "$pattern" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    echo "  ❌ [CRITICAL] $name:"
    echo "$matches" | head -3 | sed 's/^/     /'
    FOUND=$((FOUND + 1))
  fi
}

check_high() {
  local name="$1"
  local pattern="$2"
  local matches
  matches=$(echo "$ADDED" | grep -nE "$pattern" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    echo "  ⚠️  [HIGH] $name:"
    echo "$matches" | head -3 | sed 's/^/     /'
    FOUND=$((FOUND + 1))
  fi
}

check_warn() {
  local name="$1"
  local pattern="$2"
  local matches
  matches=$(echo "$ADDED" | grep -nE "$pattern" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    echo "  🔶 [WARN] $name:"
    echo "$matches" | head -2 | sed 's/^/     /'
    WARNINGS=$((WARNINGS + 1))
  fi
}

echo ""
echo "--- Secrets & Credentials ---"
check_critical "Anthropic API Key"     "sk-ant-[a-zA-Z0-9_-]{20,}"
check_critical "OpenAI API Key"        "sk-[a-zA-Z0-9]{20,}"
check_critical "AWS Access Key"        "AKIA[0-9A-Z]{16}"
check_critical "AWS Secret Key"        "aws.{0,10}secret.{0,10}['\"][A-Za-z0-9/+=]{40}['\"]"
check_critical "Google API Key"        "AIza[0-9A-Za-z_-]{35}"
check_critical "Google OAuth"          "[0-9]+-[a-z0-9]+\.apps\.googleusercontent\.com"
check_critical "Stripe Key"            "(sk|pk)_(test|live)_[A-Za-z0-9]{20,}"
check_critical "Private Key"           "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY"
check_critical "Telegram Bot Token"    "bot[0-9]{8,}:[A-Za-z0-9_-]{35}"
check_critical "Discord Token"         "[MN][A-Za-z0-9]{23,}\.[A-Za-z0-9_-]{6}\.[A-Za-z0-9_-]{27}"
check_critical "Slack Webhook"         "hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[A-Za-z0-9]+"
check_critical "GitHub PAT"            "(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}"
check_critical "JWT Token"             "eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"

echo ""
echo "--- Connection Strings & Credentials ---"
check_critical "DB Connection String"  "(mongodb|postgres|mysql|redis|amqp)://[^\s'\"]+"
check_critical "URL with Credentials"  "https?://[^@\s]+:[^@\s]+@[^\s]+"
check_high     "Hardcoded Password"    "(password|passwd|pwd|secret)\s*[=:]\s*['\"][^'\"]{8,}"
check_high     "API Key Assignment"    "(api[_-]?key|apikey|api_secret)\s*[=:]\s*['\"][a-zA-Z0-9]{10,}"
check_high     "Bearer Token"          "[Bb]earer\s+[a-zA-Z0-9_.-]{20,}"
check_warn     "Base64 Blob (>50 chars)" "['\"][A-Za-z0-9+/]{50,}={0,2}['\"]"
check_warn     "Hardcoded IP:Port"     "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{2,5}"

echo ""
echo "--- Injection & Shell Safety ---"
check_critical "Reverse Shell"         "(nc\s+-e|bash\s+-i|/dev/tcp/|python.*import\s+socket.*connect)"
check_critical "Remote Code Exec"      "(curl|wget).*\|\s*(bash|sh|zsh|python)"
check_high     "Unquoted Variable in Shell" '\$\{?[A-Z_]+\}?\s' # loose check for unquoted vars
check_high     "Eval/Exec"             "(eval|exec)\s*\("
check_warn     "npx without pin"       "npx\s+-y\s+[^@]*$"

echo ""
echo "--- Exfiltration & Persistence ---"
check_critical "DNS Exfiltration"      "(nslookup|dig)\s+.*\\\$"
check_high     "Cron Install"          "(crontab|/etc/cron)"
check_high     "Systemd Unit"          "/etc/systemd|systemctl\s+(enable|start)"
check_high     "Bashrc/Profile Edit"   "(>>|>)\s*~/?\.(bashrc|zshrc|profile|bash_profile)"
check_high     "Git Hook Install"      "\.git/hooks/"
check_warn     "Clipboard Access"      "(pbcopy|pbpaste|xclip|xsel|clip\.exe)"
check_warn     "Silent Error Suppress" "2>/dev/null\s*$"

echo ""
echo "--- Credential Files ---"
check_high     ".env File Reference"   "\.(env|env\.local|env\.prod)"
check_high     "SSH Key Reference"     "~/.ssh/(id_|known_hosts|authorized_keys)"
check_high     "AWS Config Reference"  "~/.aws/(credentials|config)"
check_warn     "Keychain/Keystore"     "(keystore|keychain|\.p12|\.pfx|\.jks)"

echo ""
echo "=========================="
if [ "$FOUND" -gt 0 ]; then
  echo "❌ BLOCKED: $FOUND critical/high finding(s). Fix before merging!"
  [ "$WARNINGS" -gt 0 ] && echo "🔶 Plus $WARNINGS warning(s) to review."
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo "⚠️  PASS with $WARNINGS warning(s). Review recommended."
  exit 0
else
  echo "✅ Clean — no secrets or security issues detected."
  exit 0
fi
