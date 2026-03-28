# Switch Project

Chuyển hệ thống multi-agent sang project khác.

## Thực hiện:

### 1. Hỏi user project mới:
- Project path (ví dụ: ~/Desktop/Projects/JapaneseVoice-SwiftUI)
- GitHub repo (ví dụ: hoaidoanhkd/JapaneseVoice-SwiftUI)

### 2. Cập nhật config
Sửa ~/agents/config.env:
- PROJECT_NAME
- PROJECT_PATH
- GITHUB_REPO

### 3. Reset memory cho project mới
```bash
# Backup memory cũ
cp -r ~/agents/memory ~/agents/memory-backup-$(date +%Y%m%d)

# Reset GOALS.md (sẽ được scan lại)
echo "# Project Goals — [NEW_PROJECT]\n\n## Chưa scan\nChạy /scan để phát hiện goals." > ~/agents/GOALS.md
```

### 4. Restart agents
```bash
~/.claude/scheduled/multi-agent-start.sh
```

### 5. Scan project mới
Tự động chạy /scan sau khi restart.
