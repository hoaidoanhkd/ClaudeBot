# ClaudeBot v2.0 Roadmap — Migrate to Agent Teams

## Why
Claude Code now has official Agent Teams feature (experimental).
Replace tmux + claude-peers with built-in Agent Teams for better coordination.

## Keep (ClaudeBot unique features)
- Discord/Telegram control
- Self-learning (lessons, patterns, anti-patterns)
- Self-evolving (/evolve)
- Auto-discovery (/scan, /brainstorm)
- /go auto-run loop
- QA batch testing
- Multi-platform rules
- Agent personalities (SOUL.md)
- Cost tracking, secret scan, rollback

## Replace
| Current (v1.x) | New (v2.0) |
|---|---|
| tmux sessions | Agent Teams split panes |
| claude-peers MCP | Built-in mailbox messaging |
| GOALS.md manual dispatch | Shared task list + self-claim |
| start.sh spawns agents | Lead spawns teammates |
| agent-watchdog.sh | Built-in TeammateIdle hook |

## New features from Agent Teams
- Direct agent-to-agent messaging (Coder ↔ Reviewer without Coordinator)
- Plan approval before implementation
- Hooks: TeammateIdle, TaskCreated, TaskCompleted
- Split pane display (see all agents at once)
- Task dependencies (auto-unblock)

## Prerequisites
- Claude Code v2.1.32+
- Enable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- Agent Teams becomes stable (currently experimental)

## Migration steps
1. Enable Agent Teams in settings.json
2. Convert coordinator.md → team lead prompt
3. Convert coder.md, reviewer.md, qa-tester.md → teammate prompts
4. Replace start.sh with lead spawning teammates
5. Keep Discord channel on lead (Coordinator)
6. Keep memory system (MEMORY_DIR)
7. Keep /evolve, /brainstorm, /scan commands
8. Add hooks: TeammateIdle → HEARTBEAT checks
9. Add hooks: TaskCompleted → after-action review
10. Test full pipeline
11. Remove: claude-peers dependency, tmux manual management, watchdog

## Timeline
- Week 1-2: Use v1.4.0 on BurnRate, stabilize
- Week 3: Prototype v2.0 on branch
- Week 4: Test + migrate
- Week 5: Release v2.0.0

## Risk
- Agent Teams is EXPERIMENTAL — may change or break
- No session resumption (agents restart = lost context)
- Higher token cost (each teammate = full context window)
- Wait until Agent Teams is stable before shipping v2.0
