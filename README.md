# ClaudeBot

Autonomous multi-agent system for Claude Code. Control your agents via Telegram or Discord — they implement features, review code, and manage PRs for you.

## Quick Start with Telegram (recommended, ~3 minutes)

### 1. Create a Telegram bot
Message [@BotFather](https://t.me/BotFather) → `/newbot` → copy the **token**.

### 2. Install
```bash
git clone https://github.com/hoaidoanhkd/ClaudeBot.git
cd ClaudeBot
./install.sh    # Choose "Telegram only", paste token when asked
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
```
Follow the instructions, then press `Ctrl+B` then `D` to detach.

### 6. Send a message to your bot on Telegram
Try: `/status` or `/help` — the bot should reply!

---

## Adding Discord (optional)

Already using Telegram? You can add Discord later without reinstalling.

### 1. Create a Discord bot
1. [Discord Developer Portal](https://discord.com/developers/applications) → **New Application**
2. Tab **Bot** → enable **Message Content Intent** (under Privileged Gateway Intents)
3. Tab **OAuth2 → URL Generator**:
   - Scope: `bot`
   - Permissions: View Channels, Send Messages, Read Message History, Add Reactions, Attach Files
4. Open the generated URL → select your server → **Authorize**
5. Tab **Bot** → **Reset Token** → copy token (don't share it anywhere!)

### 2. Save the token
Run in a **separate Terminal** (token is hidden when you type):
```bash
bash ~/Desktop/Projects/ClaudeBot/setup-discord-token.sh
```
Or run `./install.sh` again and choose "Both Telegram + Discord".

### 3. Install the Discord plugin (one time only)
Open Claude Code (or attach to coordinator) and run:
```
/plugin install discord@claude-plugins-official
```

### 4. Restart agents
```bash
./start.sh
```

### 5. Pair your Discord
1. **DM your bot** on Discord → bot replies with a pairing code
2. In the coordinator:
```bash
tmux attach -t cc-coordinator
# Type: /discord:access pair <the-code-from-step-1>
```

### 6. Test — send a message to your bot on Discord!

---

## Prerequisites

- **macOS** (Apple Silicon)
- **Claude Code CLI** + Claude Max subscription
- **Bun** runtime
- **tmux**
- **gh** CLI (GitHub)
- **claude-peers-mcp** (inter-agent communication)

> `install.sh` checks all of these and tells you what's missing.

## Agents

| Agent | Role | Mode |
|-------|------|------|
| Coordinator | Receives messages, delegates tasks, reports results | Always-on |
| Coder | Implements features, creates branches + PRs | Always-on |
| Senior Reviewer | Reviews code, approves + merges PRs | Always-on |
| Researcher | Web search, deep research | On-demand |

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
| /channel telegram | Switch to Telegram |
| /channel discord | Switch to Discord |

> Only one channel is loaded at a time. Use `/channel` to switch (triggers a restart).

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
├── scripts/         # Utility scripts (watchdog, health, stats, etc.)
├── install.sh       # Interactive installer
├── uninstall.sh     # Clean removal
├── start.sh         # Launch agents in tmux
├── config.env       # Config template
└── com.claudebot.agents.plist  # macOS auto-start
```

To uninstall: `./uninstall.sh`
