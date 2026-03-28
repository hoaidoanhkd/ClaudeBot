# Daily Review

Xem lại những gì đã làm hôm nay: git commits, files thay đổi, Obsidian notes.

## Thực hiện tuần tự:

### 1. Git commits hôm nay
```bash
for dir in ~/Desktop/Projects/*/; do
  if [ -d "$dir/.git" ]; then
    COMMITS=$(git -C "$dir" log --oneline --since="today" 2>/dev/null)
    if [ -n "$COMMITS" ]; then
      echo "=== $(basename $dir) ==="
      echo "$COMMITS"
      git -C "$dir" diff --stat HEAD~1 2>/dev/null
      echo ""
    fi
  fi
done
```

### 2. Files thay đổi hôm nay
```bash
find ~/Desktop/Projects -name "*.swift" -o -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.md" | xargs stat -f "%m %N" 2>/dev/null | awk -v today=$(date +%s) 'today - $1 < 86400 {print $2}' | head -20
```

### 3. Obsidian notes hôm nay
Dùng MCP obsidian search notes chỉnh sửa hôm nay.
Liệt kê tên notes và tóm tắt thay đổi.

### 4. Claude Code sessions
```bash
ls -lt ~/.claude/sessions/ 2>/dev/null | head -5
```

### 5. Digest đã nhận chưa
```bash
ls -la "/Volumes/FF951/Obsidian/03 - Resources/Claude Code Digest/$(date +%Y-%m-%d).md" 2>/dev/null
```

### 6. Tổng kết ngày
Hiển thị:
- 💻 Commits: số commits, projects nào
- 📁 Files: số files thay đổi
- 📝 Notes: notes nào đã sửa/tạo
- 📰 Digest: đã nhận/chưa
- 🏆 Highlight: điều đáng nhớ nhất hôm nay

### 7. Gợi ý cho ngày mai
Dựa trên context hôm nay, gợi ý 1-2 việc nên làm ngày mai.
