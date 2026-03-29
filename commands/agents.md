# Multi-Agent System

Manage the multi-agent system (coordinator + coder + reviewer).

## Steps:

### 1. Check peers
Run: `cd ~/claude-peers-mcp && bun cli.ts status`

### 2. Check tmux sessions
Run: `tmux list-sessions`

### 3. Show status
- Coordinator: active/inactive (tmux cc-coordinator)
- Coder: active/inactive (tmux cc-coder)
- Reviewer: active/inactive (tmux cc-reviewer)
- Broker: running/stopped
- Number of connected peers

### 4. Management commands
- Start all: `~/.claude/scheduled/multi-agent-start.sh`
- Stop all: `tmux kill-session -t cc-coordinator; tmux kill-session -t cc-coder; tmux kill-session -t cc-reviewer`
- Restart: stop + start
- View agent: `tmux attach -t cc-[name]`
- Health check: `~/scripts/agent-health.sh`
