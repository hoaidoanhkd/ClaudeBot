# ClaudeBot

Autonomous multi-agent system for Claude Code. Control via Telegram or Discord — agents implement features, review code, and manage PRs autonomously.

**Tested:** 11 PRs merged autonomously in one session (avg 8.9/10 review score).

## Quick Start with Telegram (recommended, ~3 minutes)

### 1. Create a Telegram bot
Message [@BotFather](https://t.me/BotFather) → `/newbot` → copy the **token**.

### 2. Install
```bash
git clone https://github.com/hoaidoanhkd/ClaudeBot.git
cd ClaudeBot
./install.sh    # Choose Telegram, paste token when asked
```

### 3. Install the Telegram plugin (one time only)
Open Claude Code and run:
```
/plugin install telegram@claude-plugins-official
```

### 4. Start agents
```bash
./start.sh
```

### 5. Pair your Telegram
```bash
tmux attach -t cc-coordinator
# Inside the session, type:
/telegram:access
# Then Ctrl+B, D to detach
```

### 6. Send a message to your bot on Telegram
Try `/help` — the bot should reply!

---

## Adding Discord (optional)

### 1. Create a Discord bot
1. [Discord Developer Portal](https://discord.com/developers/applications) → **New Application**
2. Tab **Bot** → enable **Message Content Intent**
3. Tab **OAuth2 → URL Generator** → scope `bot` → permissions: View Channels, Send Messages, Read Message History, Add Reactions, Attach Files
4. Open the generated URL → select your server → **Authorize**
5. Tab **Bot** → **Reset Token** → copy token

### 2. Save the token securely
```bash
bash ~/Desktop/Projects/ClaudeBot/setup-discord-token.sh
```

### 3. Install the Discord plugin (one time only)
```
/plugin install discord@claude-plugins-official
```

### 4. Restart + pair
```bash
./start.sh
tmux attach -t cc-coordinator
# Type: /discord:access pair <code-from-DM>
```

---

## How It Works

```
You send a message (Telegram/Discord)
         ↓
    Coordinator receives
         ↓
    📝 Creates spec (plan + files + criteria)
         ↓
    ⚡ Dispatches to Coder
         ↓
    Coder: docs lookup → implement → build → test-fix loop → self-review → PR
         ↓
    Senior Reviewer: review → merge (or reject → Coder fixes)
         ↓
    📝 Writes lessons to shared memory (self-learning)
         ↓
    Reply result on your channel
```

## Agents

| Agent | Role | Mode |
|-------|------|------|
| **Coordinator** | Plans tasks, delegates, reports progress, runs heartbeat | Always-on |
| **Coder** | Docs lookup → implement → test-fix loop → self-review → PR | Always-on |
| **Senior Reviewer** | Reviews code, verifies build, auto-merges | Always-on |
| **QA Tester** | Verifies features work correctly after merge | On-demand |
| **Researcher** | Web search, competitor analysis | On-demand |

## Commands

| Command | Action |
|---------|--------|
| `/go` | Auto-run loop — picks goals, implements, merges, repeats |
| `/stop` | Stop the loop |
| `/progress` | Status dashboard (🟢 RUNNING / 🟡 WAITING / 🔴 IDLE / 🔵 SCANNING) |
| `/status` | Show goals progress |
| `/health` | Agent health check |
| `/scan` | Scan code + research competitors → add goals |
| `/brainstorm` | Research new features, auto-score, auto-add best ones |
| `/cost` | Token usage + cost estimates |
| `/stats` | Performance metrics |
| `/digest` | Weekly summary |
| `/evolve` | Self-improve agent rules (analyze patterns → propose changes → user approves) |
| `/rollback PR#N` | Revert a merged PR |
| `/channel telegram` | Switch to Telegram |
| `/channel discord` | Switch to Discord |
| `/help` | All commands |

> Only one channel active at a time. `/channel` switches and restarts.

### Claude Code Slash Commands

These run inside Claude Code (not from Telegram/Discord):

| Command | Action |
|---------|--------|
| `/agents` | Manage agent system (check peers, sessions, start/stop) |
| `/scan` | Goal discovery — scan code + research |
| `/stats` | Show agent metrics |
| `/nudge` | Trigger proactive goal check |
| `/parallel` | Spawn parallel coder agents |
| `/sync-goals` | Sync GOALS.md with GitHub Issues |
| `/switch-project` | Switch to a different project |
| `/digest-run` | Generate weekly digest now |
| `/digest-status` | Check digest schedule |

## Key Features

### Autonomous Pipeline
- **Planning phase** — Coordinator creates spec before dispatching (MetaGPT pattern)
- **Test-fix loop** — Coder builds + tests, auto-fixes failures up to 3x (Aider pattern)
- **Self-review** — Coder reviews own diff before creating PR (Copilot pattern)
- **Post-PR CI verification** — Coder waits for CI, auto-fixes if failed (OpenHands pattern)
- **Auto-mode** — no permission prompts, safe actions auto-approved

### Self-Learning
- **After-action reviews** — every task writes lessons to shared memory
- **Successful patterns** — what worked, reused on similar tasks
- **Anti-patterns** — what failed, avoided next time
- **Daily logs** — `~/agents/memory/$PROJECT/daily/YYYY-MM-DD.md`
- **Project-isolated memory** — each project gets its own memory

### Auto-Discovery
- **/scan** — 4 phases: code scan → feature analysis → competitor research → GOALS.md
- **/brainstorm** — web research → generate ideas → auto-score (demand, revenue, gap, feasibility) → auto-add score >= 3.5
- **/go loop** — auto-scan every 5 tasks, auto-brainstorm every 6 hours

### Proactive Monitoring
- **HEARTBEAT.md** — coordinator checks every 30 min idle: agent health, stuck tasks, stale PRs, memory hygiene
- **Autonomy levels** — auto-pilot Effort:S/M tasks, ask first for Effort:L
- **Watchdog** — auto-restart dead agents
- **CI monitor** — alert on GitHub Actions failures

## Prerequisites

- **macOS** (Apple Silicon)
- **Claude Code CLI** + Claude Max subscription
- **Bun** runtime
- **tmux**
- **gh** CLI (GitHub)
- **claude-peers-mcp** (inter-agent communication)

> `install.sh` checks all of these and tells you what's missing.

## Project Structure

```
ClaudeBot/
├── agents/
│   ├── coordinator.md       # Coordinator agent definition
│   ├── coder.md             # Coder agent definition
│   ├── senior-reviewer.md   # Reviewer agent definition
│   ├── researcher.md        # Researcher agent definition
│   ├── HEARTBEAT.md         # Proactive monitoring checklist
│   ├── hooks/               # Failure recovery hooks
│   └── memory/
│       └── shared/          # Shared learning (per-project)
├── commands/                # 9 slash commands
├── scripts/                 # 13 utility scripts
│   ├── agent-watchdog.sh    # Auto-restart dead agents
│   ├── agent-health.sh      # Health check report
│   ├── agent-stats.sh       # Performance metrics
│   ├── goals-sync.sh        # Sync GOALS.md ↔ GitHub Issues
│   ├── repo-map.sh          # Generate project overview
│   ├── go-loop.sh           # Auto-run loop
│   ├── weekly-digest.sh     # Weekly summary
│   └── ...
├── install.sh               # Interactive installer
├── uninstall.sh             # Clean removal
├── start.sh                 # Launch agents in tmux
├── setup-discord-token.sh   # Secure Discord token input
├── config.env               # Config template
└── .github/workflows/ci.yml # CI: shellcheck + security scan
```

## Inspired By

Patterns adopted from top autonomous agent frameworks:
- **MetaGPT** — planning phase, structured specs
- **Aider** — test-fix loop, repo-map
- **OpenClaw** — HEARTBEAT, daily memory logs
- **OpenHands** — post-PR CI verification
- **CrewAI** — shared memory system
- **Cline** — plan/act mode
- **Goose** — auto-debug loop
- **EvoAgentX** — self-learning feedback loops

To uninstall: `./uninstall.sh`
