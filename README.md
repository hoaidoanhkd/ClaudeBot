# ClaudeBot — Autonomous Multi-Agent System for Claude Code

Hệ thống multi-agent tự chủ điều khiển qua Telegram. Tự scan codebase, đề xuất goals, implement, review, merge PRs — tất cả tự động.

## Features
- 3 agents: Coordinator + Coder + Senior Reviewer (Claude Opus)
- Telegram control: /go /scan /stop /stats /help + inline buttons
- GitHub PR workflow: branch → implement → PR → auto-merge
- Self-learning: reflection → guiding/cautionary principles
- Goal Discovery: scan code + web research → GOALS.md → GitHub Issues
- Auto-recovery: watchdog, keepalive, crash logging
- 24/7 proactive: periodic goal check + ask user
- Dynamic: 1 config file to switch projects

## Quick Start
```bash
git clone https://github.com/hoaidoanhkd/ClaudeBot.git
cd ClaudeBot
./install.sh
# Edit config.env with your project path + GitHub repo
./start.sh
```

## Requirements
- macOS (Apple Silicon)
- Claude Code CLI + Claude Max subscription
- Bun runtime
- tmux
- gh CLI (GitHub)
- claude-peers-mcp (separate repo)

## Telegram Setup
1. Create bot via @BotFather
2. Set token in `~/.claude/channels/telegram/.env`
3. Pair via `/telegram:access`

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
