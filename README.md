# ClaudeBot

Autonomous multi-agent system for Claude Code. Control your agents via Telegram or Discord — they implement features, review code, and manage PRs for you.

## Quick Start

```bash
git clone https://github.com/hoaidoanhkd/ClaudeBot.git
cd ClaudeBot
./install.sh    # Interactive setup — handles everything
./start.sh      # Launch agents
```

The installer checks dependencies, configures your project, sets up channels, and symlinks everything into place. To remove: `./uninstall.sh`

## Prerequisites

- **macOS** (Apple Silicon)
- **Claude Code CLI** + Claude Max subscription
- **Bun** runtime
- **tmux**
- **gh** CLI (GitHub)
- **claude-peers-mcp** (inter-agent communication)

> `install.sh` verifies all of these, tells you what's missing, and auto-installs Telegram/Discord plugins.

## Agents

| Agent | Role | Mode |
|-------|------|------|
| Coordinator | Receives messages, delegates tasks, reports results | Always-on |
| Coder | Implements features, creates branches + PRs | Always-on |
| Senior Reviewer | Reviews code, approves + merges PRs | Always-on |
| Researcher | Web search, deep research | On-demand |

## Channel Setup

During setup, you choose your communication channel:

| Option | What you get |
|--------|-------------|
| 1 | Telegram only |
| 2 | Discord only |
| 3 | Both |

**Before running `install.sh`**, create your bot:

- **Telegram** — Create via [@BotFather](https://t.me/BotFather), copy the token
- **Discord** — Create at [Developer Portal](https://discord.com/developers/applications), enable **Message Content Intent**, invite to server with bot permissions

The installer will ask for the token and save it. After install, pair your account:
- Telegram: `/telegram:access` in Claude Code
- Discord: DM the bot, then `/discord:access pair <code>` in Claude Code

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
