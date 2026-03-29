#!/bin/bash
# ClaudeBot Install — interactive setup + symlink files to correct locations
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

ok()   { echo -e "  ${GREEN}+${NC} $1"; }
skip() { echo -e "  ${DIM}~${NC} $1 ${DIM}(skipped)${NC}"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
err()  { echo -e "  ${RED}x${NC} $1"; }
ask()  { echo -en "${YELLOW}?${NC} $1"; }

# ── Helper: prompt with default ───────────────────────────────────────────────
# Usage: result=$(prompt "Label" "default_value")
# Note: prompt text goes to stderr so $(prompt ...) only captures the answer
prompt() {
  local label="$1"
  local default="$2"
  local input
  if [ -n "$default" ]; then
    echo -en "${YELLOW}?${NC} ${label} ${DIM}[${default}]${NC}: " >&2
  else
    echo -en "${YELLOW}?${NC} ${label}: " >&2
  fi
  read -r input
  echo "${input:-$default}"
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}  ClaudeBot Installer${NC}"
echo -e "  ${DIM}Autonomous multi-agent system for Claude Code${NC}"
echo -e "  ${DIM}Source: ${DIR}${NC}"
echo ""

# ── Dependency Check ─────────────────────────────────────────────────────────
echo -e "${BOLD}Checking dependencies...${NC}"

MISSING_REQUIRED=0

check_dep() {
  local name="$1"
  local cmd="$2"
  local required="$3"
  local hint="$4"
  local version=""

  if command -v "$cmd" &>/dev/null; then
    case "$cmd" in
      claude) version=$(claude --version 2>/dev/null | head -1 || echo "installed") ;;
      tmux)   version=$(tmux -V 2>/dev/null | sed 's/tmux //' || echo "installed") ;;
      bun)    version=$(bun --version 2>/dev/null || echo "installed") ;;
      gh)     version=$(gh --version 2>/dev/null | head -1 | sed 's/gh version //' | cut -d' ' -f1 || echo "installed") ;;
    esac
    echo -e "  ${GREEN}✓${NC} ${name} ${DIM}(${version})${NC}"
  else
    if [ "$required" = "required" ]; then
      echo -e "  ${RED}✗${NC} ${name} — ${hint}"
      MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
    else
      echo -e "  ${RED}✗${NC} ${name} — ${hint}"
    fi
  fi
}

check_dep "claude"  "claude"  "required" "install from https://docs.anthropic.com/en/docs/claude-code"
check_dep "tmux"    "tmux"    "required" "brew install tmux"
check_dep "bun"     "bun"     "required" "curl -fsSL https://bun.sh/install | bash"
check_dep "gh"      "gh"      "optional" "brew install gh"

# claude-peers-mcp: check directory existence
if [ -d "$HOME/claude-peers-mcp" ]; then
  echo -e "  ${GREEN}✓${NC} claude-peers-mcp"
else
  echo -e "  ${RED}✗${NC} claude-peers-mcp — install from https://github.com/anthropics/claude-peers-mcp"
fi

echo ""

if [ "$MISSING_REQUIRED" -gt 0 ]; then
  warn "${MISSING_REQUIRED} required dependency(ies) missing. You can continue, but agents may not work."
  ask "Continue anyway? (Y/n): "
  read -r yn
  case "$yn" in
    [nN]|[nN][oO])
      err "Aborted. Install missing dependencies and re-run."
      exit 1
      ;;
  esac
  echo ""
fi

# ── Interactive Configuration ─────────────────────────────────────────────────
RECONFIGURE=false
if [ -f ~/agents/config.env ]; then
  echo -e "${YELLOW}!${NC} Existing config found at ~/agents/config.env"
  ask "Reconfigure? (y/N): "
  read -r yn
  case "$yn" in
    [yY]|[yY][eE][sS]) RECONFIGURE=true ;;
  esac
  echo ""
fi

if [ ! -f ~/agents/config.env ] || [ "$RECONFIGURE" = true ]; then
  echo -e "${BOLD}Step 1/5: Project Configuration${NC}"
  echo ""

  # 1. Project name
  PROJECT_NAME=$(prompt "Project name (e.g. BurnRate, MyApp)" "")
  if [ -z "$PROJECT_NAME" ]; then
    err "Project name is required."
    exit 1
  fi

  # 2. Project path (smart default based on name)
  DEFAULT_PATH="$HOME/Desktop/Projects/${PROJECT_NAME}"
  PROJECT_PATH=$(prompt "Project path" "$DEFAULT_PATH")
  # Expand ~ to $HOME if user typed it
  PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"

  if [ ! -d "$PROJECT_PATH" ]; then
    warn "Directory does not exist: ${PROJECT_PATH}"
    ask "Continue anyway? (Y/n): "
    read -r yn
    case "$yn" in
      [nN]|[nN][oO])
        err "Aborted. Create the directory first and re-run."
        exit 1
        ;;
    esac
  fi

  # 3. GitHub repo (smart default from git remote or project name)
  DEFAULT_REPO=""
  if [ -d "$PROJECT_PATH/.git" ]; then
    DEFAULT_REPO=$(git -C "$PROJECT_PATH" remote get-url origin 2>/dev/null | sed -E 's|.*github\.com[:/]||;s|\.git$||' || true)
  fi
  if [ -z "$DEFAULT_REPO" ]; then
    GIT_USER=$(git config --global user.name 2>/dev/null || echo "user")
    DEFAULT_REPO="${GIT_USER}/${PROJECT_NAME}"
  fi
  GITHUB_REPO=$(prompt "GitHub repo (user/repo)" "$DEFAULT_REPO")

  # 4. Project type
  echo ""
  echo -e "  ${DIM}Project types:${NC}"
  echo -e "    ${BOLD}1${NC}) ios-swiftui    ${DIM}— SwiftUI + Swift, Xcode project${NC}"
  echo -e "    ${BOLD}2${NC}) ios-uikit      ${DIM}— UIKit + Swift, Xcode project${NC}"
  echo -e "    ${BOLD}3${NC}) web            ${DIM}— HTML/CSS/JS, Node.js, React, etc.${NC}"
  echo -e "    ${BOLD}4${NC}) python         ${DIM}— Python scripts, Django, Flask, etc.${NC}"
  echo -e "    ${BOLD}5${NC}) rust           ${DIM}— Rust + Cargo${NC}"
  echo -e "    ${BOLD}6${NC}) go             ${DIM}— Go modules${NC}"
  echo -e "    ${BOLD}7${NC}) generic        ${DIM}— Other / mixed${NC}"
  echo ""

  PROJECT_TYPES=("ios-swiftui" "ios-uikit" "web" "python" "rust" "go" "generic")
  TYPE_CHOICE=$(prompt "Choose project type (1-7)" "7")

  # Validate: accept number 1-7 or a raw type name
  if [[ "$TYPE_CHOICE" =~ ^[1-7]$ ]]; then
    PROJECT_TYPE="${PROJECT_TYPES[$((TYPE_CHOICE - 1))]}"
  else
    VALID_TYPE=false
    for t in "${PROJECT_TYPES[@]}"; do
      if [ "$TYPE_CHOICE" = "$t" ]; then
        PROJECT_TYPE="$TYPE_CHOICE"
        VALID_TYPE=true
        break
      fi
    done
    if [ "$VALID_TYPE" = false ]; then
      warn "Invalid choice '${TYPE_CHOICE}', defaulting to 'generic'"
      PROJECT_TYPE="generic"
    fi
  fi

  # 5. Communication channels
  echo ""
  echo -e "  ${DIM}Choose how to control your agents:${NC}"
  echo -e "    ${BOLD}1${NC}) Telegram only"
  echo -e "    ${BOLD}2${NC}) Discord only"
  echo -e "    ${BOLD}3${NC}) Both Telegram + Discord"
  echo ""

  CHANNEL_CHOICE=$(prompt "Channel setup (1-3)" "1")
  TELEGRAM_ENABLED="false"
  DISCORD_ENABLED="false"
  TELEGRAM_CHAT_ID="your-chat-id"

  ACTIVE_CHANNEL="telegram"
  case "$CHANNEL_CHOICE" in
    1) TELEGRAM_ENABLED="true"; ACTIVE_CHANNEL="telegram" ;;
    2) DISCORD_ENABLED="true"; ACTIVE_CHANNEL="discord" ;;
    3) TELEGRAM_ENABLED="true"; DISCORD_ENABLED="true"; ACTIVE_CHANNEL="telegram" ;;
    *) warn "Invalid choice, defaulting to Telegram only"; TELEGRAM_ENABLED="true" ;;
  esac
  mkdir -p ~/agents
  echo "$ACTIVE_CHANNEL" > ~/agents/active-channel.txt
  ok "Active channel: $ACTIVE_CHANNEL"

  # Telegram setup
  NEED_TELEGRAM_PLUGIN=false
  if [ "$TELEGRAM_ENABLED" = "true" ]; then
    echo ""
    if grep -q '"telegram@claude-plugins-official"' ~/.claude/plugins/installed_plugins.json 2>/dev/null; then
      ok "Telegram plugin already installed"
    else
      NEED_TELEGRAM_PLUGIN=true
      warn "Telegram plugin not installed (will install in next steps)"
    fi

    TELEGRAM_CHAT_ID=$(prompt "Telegram chat ID (or Enter to skip)" "")
    if [ -z "$TELEGRAM_CHAT_ID" ]; then
      TELEGRAM_CHAT_ID="your-chat-id"
    fi
    TELEGRAM_BOT_TOKEN=$(prompt "Telegram bot token (from @BotFather, or Enter to skip)" "")
    if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
      mkdir -p ~/.claude/channels/telegram
      echo "TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}" > ~/.claude/channels/telegram/.env
      ok "Saved Telegram token"
    fi
  fi

  # Discord setup
  NEED_DISCORD_PLUGIN=false
  if [ "$DISCORD_ENABLED" = "true" ]; then
    echo ""
    if grep -q '"discord@claude-plugins-official"' ~/.claude/plugins/installed_plugins.json 2>/dev/null; then
      ok "Discord plugin already installed"
    else
      NEED_DISCORD_PLUGIN=true
      warn "Discord plugin not installed (will install in next steps)"
    fi

    echo -e "  ${DIM}Discord bot token is hidden when you type (secure).${NC}"
    echo -en "${YELLOW}?${NC} Discord bot token (or Enter to skip): "
    read -rs DISCORD_BOT_TOKEN
    echo ""
    if [ -n "$DISCORD_BOT_TOKEN" ]; then
      mkdir -p ~/.claude/channels/discord
      echo "DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}" > ~/.claude/channels/discord/.env
      ok "Saved Discord token (hidden)"
    fi
  fi

  echo ""
else
  echo -e "${DIM}Using existing config at ~/agents/config.env${NC}"
  echo ""
fi

# ── Symlinks ──────────────────────────────────────────────────────────────────
echo -e "${BOLD}Installing files...${NC}"
echo ""

# Agent definitions -> ~/.claude/agents/
mkdir -p ~/.claude/agents
for f in "$DIR"/agents/*.md; do
  [ -f "$f" ] || continue
  ln -sf "$f" ~/.claude/agents/"$(basename "$f")"
  ok "Agent: $(basename "$f")"
done

# Scripts -> ~/scripts/
mkdir -p ~/scripts
for f in "$DIR"/scripts/*.sh; do
  [ -f "$f" ] || continue
  ln -sf "$f" ~/scripts/"$(basename "$f")"
  chmod +x "$f"
  ok "Script: $(basename "$f")"
done

# Commands -> ~/.claude/commands/
mkdir -p ~/.claude/commands
for f in "$DIR"/commands/*.md; do
  [ -f "$f" ] || continue
  ln -sf "$f" ~/.claude/commands/"$(basename "$f")"
  ok "Command: $(basename "$f")"
done

# ── Write config.env ──────────────────────────────────────────────────────────
mkdir -p ~/agents/memory ~/agents/hooks ~/logs

if [ ! -f ~/agents/config.env ] || [ "$RECONFIGURE" = true ]; then
  cat > ~/agents/config.env << ENVEOF
# ClaudeBot Agent Config
# Generated by install.sh on $(date '+%Y-%m-%d %H:%M:%S')

PROJECT_NAME="${PROJECT_NAME}"
PROJECT_PATH="${PROJECT_PATH}"
GITHUB_REPO="${GITHUB_REPO}"
PROJECT_TYPE="${PROJECT_TYPE}"
AGENTS="coordinator,coder,reviewer"
LOG_DIR="\$HOME/logs"

# Channels (set to "true" to enable)
TELEGRAM_ENABLED="${TELEGRAM_ENABLED}"
DISCORD_ENABLED="${DISCORD_ENABLED}"

TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}"

# Daemon intervals (used when scripts are available)
WATCHDOG_INTERVAL=30
PROACTIVE_INTERVAL=15
KEEPALIVE_INTERVAL=60
CI_MONITOR_INTERVAL=120
ENVEOF
  ok "Config: ~/agents/config.env"
else
  skip "Config exists, not overwriting"
fi

# ── Hooks ─────────────────────────────────────────────────────────────────────
if [ -f "$DIR/agents/hooks/post_failure.sh" ]; then
  ln -sf "$DIR/agents/hooks/post_failure.sh" ~/agents/hooks/
  chmod +x "$DIR/agents/hooks/post_failure.sh"
  ok "Hook: post_failure.sh"
fi

# ── Startup script ────────────────────────────────────────────────────────────
mkdir -p ~/.claude/scheduled
ln -sf "$DIR/start.sh" ~/.claude/scheduled/multi-agent-start.sh
chmod +x "$DIR/start.sh"
ok "Startup: ~/.claude/scheduled/multi-agent-start.sh"

# ── Launchd plist ─────────────────────────────────────────────────────────────
mkdir -p ~/Library/LaunchAgents
PLIST_PATH=~/Library/LaunchAgents/com.claudebot.agents.plist
PLIST_UPDATED=false

if [ ! -f "$PLIST_PATH" ] || [ "$RECONFIGURE" = true ]; then
  # Copy template and replace /Users/username with actual $HOME
  sed "s|/Users/username|${HOME}|g" "$DIR/com.claudebot.agents.plist" > "$PLIST_PATH"
  ok "Launchd: com.claudebot.agents.plist (paths set to ${HOME})"
  PLIST_UPDATED=true
else
  skip "Launchd plist exists"
fi

# ── Memory templates ──────────────────────────────────────────────────────────
if [ ! -f ~/agents/memory/lessons.md ]; then
  cat > ~/agents/memory/lessons.md << 'EOF'
# Lessons Learned

## Guiding Principles

## Cautionary Principles

## Error Tracker (count -> promote when >= 3)
EOF
  ok "Memory: lessons.md template"
else
  skip "lessons.md exists"
fi

if [ ! -f ~/agents/GOALS.md ]; then
  printf '# Project Goals\n\nRun /scan to discover goals.\n' > ~/agents/GOALS.md
  ok "Memory: GOALS.md"
else
  skip "GOALS.md exists"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}ClaudeBot installed successfully!${NC}"
echo ""

# Show config summary if we just configured
if [ -n "${PROJECT_NAME:-}" ]; then
  echo -e "${BOLD}Configuration Summary${NC}"
  echo -e "  ${DIM}--------------------------------------${NC}"
  echo -e "  Project:      ${CYAN}${PROJECT_NAME}${NC}"
  echo -e "  Path:         ${CYAN}${PROJECT_PATH}${NC}"
  echo -e "  GitHub:       ${CYAN}${GITHUB_REPO}${NC}"
  echo -e "  Type:         ${CYAN}${PROJECT_TYPE}${NC}"
  if [ "$TELEGRAM_CHAT_ID" != "your-chat-id" ]; then
    echo -e "  Telegram:     ${CYAN}${TELEGRAM_CHAT_ID}${NC}"
  else
    echo -e "  Telegram:     ${DIM}not configured${NC}"
  fi
  if [ "${DISCORD_ENABLED:-false}" = "true" ]; then
    echo -e "  Discord:      ${CYAN}enabled${NC}"
  else
    echo -e "  Discord:      ${DIM}disabled${NC}"
  fi
  echo -e "  Config:       ${DIM}~/agents/config.env${NC}"
  if [ "$PLIST_UPDATED" = true ]; then
    echo -e "  Launchd:      ${DIM}~/Library/LaunchAgents/com.claudebot.agents.plist${NC}"
  fi
  echo -e "  ${DIM}--------------------------------------${NC}"
  echo ""
fi

echo -e "${BOLD}Next steps:${NC}"
STEP=1

# Plugin installation (must be done inside Claude Code)
if [ "${NEED_TELEGRAM_PLUGIN:-false}" = true ] || [ "${NEED_DISCORD_PLUGIN:-false}" = true ]; then
  echo -e "  ${STEP}. ${YELLOW}Install channel plugins${NC} — open Claude Code and run:"
  if [ "${NEED_TELEGRAM_PLUGIN:-false}" = true ]; then
    echo -e "     ${BOLD}/plugin install telegram@claude-plugins-official${NC}"
  fi
  if [ "${NEED_DISCORD_PLUGIN:-false}" = true ]; then
    echo -e "     ${BOLD}/plugin install discord@claude-plugins-official${NC}"
  fi
  STEP=$((STEP + 1))
fi

echo -e "  ${STEP}. Start agents:  ${BOLD}~/.claude/scheduled/multi-agent-start.sh${NC}"
STEP=$((STEP + 1))

# Pairing instructions
if [ "${DISCORD_ENABLED:-false}" = "true" ]; then
  echo -e "  ${STEP}. ${YELLOW}Pair Discord${NC}:"
  echo -e "     a. DM your bot on Discord → bot replies with pairing code"
  echo -e "     b. In coordinator tmux: ${BOLD}/discord:access pair <code>${NC}"
  echo -e "     Attach to coordinator: ${DIM}tmux attach -t cc-coordinator${NC}"
  STEP=$((STEP + 1))
fi

if [ "${TELEGRAM_ENABLED:-false}" = "true" ] && [ "${TELEGRAM_CHAT_ID:-}" = "your-chat-id" ]; then
  echo -e "  ${STEP}. ${YELLOW}Pair Telegram${NC}: run ${BOLD}/telegram:access${NC} in coordinator"
  STEP=$((STEP + 1))
fi

echo -e "  ${STEP}. Send a message to your bot — it should reply!"
if [ "$PLIST_UPDATED" = true ]; then
  echo -e "  ${DIM}*${NC} Auto-start:    launchctl load ~/Library/LaunchAgents/com.claudebot.agents.plist"
fi
echo -e "  ${DIM}*${NC} Send ${BOLD}/go${NC} on Telegram to begin"
echo ""
