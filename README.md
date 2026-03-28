# ClaudeBot — Autonomous Multi-Agent System for Claude Code

Multi-agent system controlled via Telegram. Three Claude Code instances (Coordinator, Coder, Senior Reviewer) collaborate through claude-peers to implement features, review code, and manage PRs.

## Features

- **3 agents**: Coordinator + Coder + Senior Reviewer (all Claude Opus)
- **Telegram control**: /go /scan /stop /stats /help + inline buttons
- **GitHub PR workflow**: branch, implement, PR, auto-merge
- **Self-learning**: post-task reflection, guiding/cautionary principles
- **Goal Discovery**: scan codebase, generate GOALS.md, sync to GitHub Issues
- **Slash commands**: /scan, /digest, /nudge, /stats, /sync-goals, /switch-project, and more

### Not yet included (planned)

The following are referenced in `start.sh` but the scripts are not in this repo yet:

- Watchdog (auto-restart crashed agents)
- Proactive loop (periodic goal check + nudge)
- Keepalive (prevent idle timeout)
- CI monitor (watch GitHub Actions)

## Prerequisites

- **macOS** (uses launchd plist for daemon management)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) + Claude Max subscription
- [Bun](https://bun.sh) runtime
- [claude-peers-mcp](https://github.com/anthropics/claude-peers-mcp) (inter-agent communication)
- tmux
- gh CLI (GitHub)

## Quick Start

```bash
git clone https://github.com/hoaidoanhkd/ClaudeBot.git
cd ClaudeBot
./install.sh   # Interactive — asks for project name, path, GitHub repo, etc.
./start.sh
```

## Telegram Setup

1. Create a bot via [@BotFather](https://t.me/BotFather)
2. Save your bot token in `~/.claude/channels/telegram/.env`
3. Pair via the `/telegram:access` skill in Claude Code

## Commands (Telegram)

| Command | Action |
|---------|--------|
| /go | Auto-run loop — ship tasks continuously |
| /scan | Scan project + suggest goals |
| /stop | Stop all agents |
| /stats | Show metrics |
| /status | Show goals progress |
| /help | List all commands |
| /digest | Weekly summary |

## Architecture

```
Telegram → Coordinator → Coder → Senior Reviewer → Auto-merge
               ↓              ↓              ↓
          Ask First    Branch+PR     Review+Merge
               ↓              ↓              ↓
          Proactive    Self-learning   Build verify
```

## Project Structure

```
ClaudeBot/
├── agents/          # Agent persona definitions + memory
├── commands/        # Slash command definitions (.md)
├── plugins/         # Plugin configs (placeholder)
├── scripts/         # Utility scripts (placeholder)
├── install.sh       # Interactive installer
├── start.sh         # Launch all agents in tmux
├── config.env       # Template config (installed to ~/agents/)
└── com.claudebot.agents.plist  # macOS launchd service
```
