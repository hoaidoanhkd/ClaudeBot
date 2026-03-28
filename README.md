# ClaudeBot — Autonomous Multi-Agent System for Claude Code

Multi-agent system controlled via Telegram and Discord. Three always-on agents (Coordinator, Coder, Senior Reviewer) plus an on-demand Researcher collaborate through claude-peers to implement features, review code, and manage PRs.

## Prerequisites

- **macOS** (Apple Silicon, uses launchd for daemon management)
- **Bun** runtime
- **Claude Code CLI** + Claude Max subscription
- **claude-peers-mcp** (inter-agent communication)
- **tmux**
- **gh** CLI (GitHub)

## Quick Start

```bash
git clone https://github.com/hoaidoanhkd/ClaudeBot.git
cd ClaudeBot
./install.sh   # Interactive setup — configures project, GitHub repo, agents
./start.sh
```

## Features

- **4 agents**: Coordinator + Coder + Senior Reviewer (always-on) + Researcher (on-demand)
- **Telegram + Discord**: control agents from either platform
- **GitHub PR workflow**: branch, implement, PR, review, auto-merge
- **Goal Discovery**: scan codebase, generate GOALS.md, sync to GitHub Issues
- **Self-learning**: post-task reflection, guiding/cautionary principles
- **Slash commands**: /scan, /digest, /nudge, /stats, /sync-goals, /switch-project
- **1 config file** (`config.env`) to switch between projects

## Telegram Setup

1. Create a bot via [@BotFather](https://t.me/BotFather)
2. Save your bot token in `~/.claude/channels/telegram/.env`
3. Pair your chat via the `/telegram:access` skill in Claude Code

## Discord Setup

1. Create a bot at [Discord Developer Portal](https://discord.com/developers/applications)
2. Enable **Message Content Intent** under Bot > Privileged Gateway Intents
3. Invite bot to server (OAuth2 > URL Generator > scope `bot` + Send Messages, Read History, Attach Files, Add Reactions)
4. In Claude Code: `/discord:configure <bot-token>`
5. DM the bot on Discord, then pair: `/discord:access pair <code>`
6. Set `DISCORD_ENABLED="true"` in config.env

## Commands (Telegram / Discord)

| Command | Action |
|---------|--------|
| /go | Auto-run loop — ship tasks continuously |
| /scan | Scan project + suggest goals |
| /stop | Stop all agents |
| /stats | Show metrics |
| /status | Show goals progress |
| /help | List all commands |
| /digest | Weekly summary |

## Slash Commands (Claude Code)

| Command | Description |
|---------|-------------|
| /scan | Goal Discovery — scan project, detect issues, generate GOALS.md |
| /stats | Show agent metrics and performance (goals, PRs, uptime, CI) |
| /agents | Manage multi-agent system (check peers, tmux sessions, start/stop) |
| /nudge | Trigger a proactive nudge — Coordinator checks goals and suggests tasks |
| /parallel | Guide for spawning parallel Coder agents for independent subtasks |
| /sync-goals | Sync GOALS.md with GitHub Issues (push/pull/both) |
| /switch-project | Switch the multi-agent system to a different project |
| /digest-run | Run the Daily Digest immediately |
| /digest-status | Check Daily Digest status, schedule, logs, and topic rotation |

## Architecture

```
Telegram ──┐
            ├──> Coordinator --> Coder ---------> Senior Reviewer --> Auto-merge
Discord  ──┘         |    \          |                    |
                Ask First  \    Branch+PR           Review+Merge
                     |      \        |                    |
                Goal Scan    \  Self-learning        Build verify
                              \
                               --> Researcher
                                      |
                                  Web search
                                      |
                                 Deep research
```

## Project Structure

```
ClaudeBot/
├── agents/          # Agent persona definitions + memory
├── commands/        # Slash command definitions (.md)
├── plugins/         # Plugin configs
├── scripts/         # Utility scripts
├── install.sh       # Interactive installer
├── start.sh         # Launch all agents in tmux
├── config.env       # Template config (installed to ~/agents/)
└── com.claudebot.agents.plist  # macOS launchd service
```
