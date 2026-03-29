# ClaudeBot

Autonomous multi-agent system for Claude Code. Control your agents via Telegram or Discord — they implement features, review code, and manage PRs for you.

## Quick Start

```bash
git clone https://github.com/hoaidoanhkd/ClaudeBot.git
cd ClaudeBot
./install.sh
```

That's it for installation. But there are a few more steps to get everything running — see the full setup guide below.

To remove: `./uninstall.sh`

## Prerequisites

- **macOS** (Apple Silicon)
- **Claude Code CLI** + Claude Max subscription
- **Bun** runtime
- **tmux**
- **gh** CLI (GitHub)
- **claude-peers-mcp** (inter-agent communication)

> `install.sh` verifies all of these and tells you what's missing.

## Agents

| Agent | Role | Mode |
|-------|------|------|
| Coordinator | Receives messages, delegates tasks, reports results | Always-on |
| Coder | Implements features, creates branches + PRs | Always-on |
| Senior Reviewer | Reviews code, approves + merges PRs | Always-on |
| Researcher | Web search, deep research | On-demand |

## Full Setup Guide

### Step 1 — Create your bot (before running install.sh)

**If using Telegram:**
1. Message [@BotFather](https://t.me/BotFather) on Telegram → `/newbot` → copy the token

**If using Discord:**
1. Go to [Discord Developer Portal](https://discord.com/developers/applications) → New Application
2. Tab **Bot** → enable **Message Content Intent**
3. Tab **OAuth2 → URL Generator** → scope `bot` → permissions: View Channels, Send Messages, Read Message History, Add Reactions, Attach Files
4. Open the generated URL → select your server → Authorize
5. Tab **Bot** → **Reset Token** → copy the token

### Step 2 — Run install.sh

```bash
./install.sh
```

The installer asks for: project name, path, GitHub repo, channel choice (Telegram/Discord/both), and bot tokens. Discord tokens are entered securely (hidden input).

### Step 3 — Install channel plugins

Plugins **must** be installed from inside Claude Code (not from bash). Open Claude Code and run:

```
/plugin install telegram@claude-plugins-official    # if using Telegram
/plugin install discord@claude-plugins-official      # if using Discord
```

You only need to do this once.

### Step 4 — Start agents

```bash
./start.sh
# or: ~/.claude/scheduled/multi-agent-start.sh
```

### Step 5 — Pair your account

**Telegram:** Run `/telegram:access` inside the coordinator session:
```bash
tmux attach -t cc-coordinator
# then type: /telegram:access
```

**Discord:**
1. DM your bot on Discord → bot replies with a **pairing code**
2. In the coordinator session, run: `/discord:access pair <code>`
```bash
tmux attach -t cc-coordinator
# then type: /discord:access pair <the-code>
```

### Step 6 — Test!

Send a message to your bot. It should reply. Try `/status` or `/help`.

## Commands

Send these from Telegram or Discord:

| Command | Action |
|---------|--------|
| /go | Auto-run — ship tasks continuously |
| /scan | Scan project, suggest goals |
| /stop | Stop all agents |
| /stats | Show metrics |
| /status | Show goals progress |
| /help | List all commands |
| /digest | Weekly summary |

Slash commands in Claude Code:

| Command | Action |
|---------|--------|
| /agents | Manage agent system status |
| /nudge | Trigger proactive goal check |
| /parallel | Spawn parallel coders |
| /sync-goals | Sync GOALS.md with GitHub Issues |
| /switch-project | Switch to a different project |
| /digest-run | Generate digest now |
| /digest-status | Check digest schedule |

## Architecture

```
Telegram ──┐
            ├──> Coordinator ──> Coder ──> Senior Reviewer ──> Auto-merge
Discord  ──┘       |    \          |              |
               Ask First  \    Branch+PR     Review+Merge
                    |       \       |              |
               Goal Scan     \  Self-learn    Build verify
                              \
                               ──> Researcher (on-demand)
```

## Project Structure

```
ClaudeBot/
├── agents/          # Agent definitions + memory
├── commands/        # Slash commands
├── plugins/         # Plugin configs
├── scripts/         # Utility scripts
├── install.sh       # Interactive installer
├── uninstall.sh     # Clean removal
├── start.sh         # Launch agents in tmux
├── config.env       # Config template
└── com.claudebot.agents.plist
```
