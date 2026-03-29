# Switch Project

Switch the multi-agent system to a different project.

Memory is isolated per project — switching preserves old project's lessons.

## Steps:

### 1. Ask user for new project:
- Project path (e.g., ~/Desktop/Projects/MyApp)
- GitHub repo (e.g., user/MyApp)

### 2. Update config
Edit ~/agents/config.env:
- PROJECT_NAME
- PROJECT_PATH
- GITHUB_REPO

### 3. Create memory for new project
```bash
# New project gets its own memory directory (old project memory is preserved)
mkdir -p ~/agents/memory/$PROJECT_NAME/shared

# Reset GOALS.md for new project
printf '# Project Goals\n\nRun /scan to discover goals.\n' > ~/agents/GOALS.md
```

### 4. Restart agents
```bash
~/.claude/scheduled/multi-agent-start.sh
```

### 5. Scan new project
Automatically run /scan after restart.
