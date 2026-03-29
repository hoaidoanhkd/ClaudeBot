# Switch Project

Switch the multi-agent system to a different project.

## Steps:

### 1. Ask user for new project:
- Project path (e.g., ~/Desktop/Projects/MyApp)
- GitHub repo (e.g., user/MyApp)

### 2. Update config
Edit ~/agents/config.env:
- PROJECT_NAME
- PROJECT_PATH
- GITHUB_REPO

### 3. Reset memory for new project
```bash
# Backup old memory
cp -r ~/agents/memory ~/agents/memory-backup-$(date +%Y%m%d)

# Reset GOALS.md (will be scanned again)
printf '# Project Goals\n\nRun /scan to discover goals.\n' > ~/agents/GOALS.md
```

### 4. Restart agents
```bash
~/.claude/scheduled/multi-agent-start.sh
```

### 5. Scan new project
Automatically run /scan after restart.
