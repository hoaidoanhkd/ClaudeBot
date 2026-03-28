# Multi-Agent System

Quản lý hệ thống multi-agent (coordinator + coder + reviewer).

## Thực hiện:

### 1. Kiểm tra peers
Chạy: `cd ~/claude-peers-mcp && bun cli.ts status`

### 2. Kiểm tra tmux sessions
Chạy: `tmux list-sessions`

### 3. Hiển thị status
- Coordinator: active/inactive (tmux cc-coordinator)
- Coder: active/inactive (tmux cc-coder)  
- Reviewer: active/inactive (tmux cc-reviewer)
- Broker: running/stopped
- Số peers connected

### 4. Lệnh quản lý
- Start all: `~/.claude/scheduled/multi-agent-start.sh`
- Stop all: `tmux kill-session -t cc-coordinator; tmux kill-session -t cc-coder; tmux kill-session -t cc-reviewer`
- Restart: stop + start
- View agent: `tmux attach -t cc-[name]`
