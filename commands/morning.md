# Morning Briefing

Tóm tắt buổi sáng: digest + Obsidian notes hôm qua + git status các projects.

## Thực hiện tuần tự:

### 1. Daily Digest mới nhất
Đọc file Obsidian digest gần nhất:
```bash
ls -t "/Volumes/FF951/Obsidian/03 - Resources/Claude Code Digest/"*.md | head -1
```
Đọc nội dung file đó và tóm tắt 3-5 điểm chính.

### 2. Obsidian notes hôm qua
Dùng MCP obsidian search_vault_simple tìm notes được chỉnh sửa gần đây.
Tóm tắt những notes nào đã thay đổi.

### 3. Git status các projects chính
Chạy lần lượt cho mỗi project:
```bash
for dir in ~/Desktop/Projects/*/; do
  if [ -d "$dir/.git" ]; then
    echo "=== $(basename $dir) ==="
    git -C "$dir" log --oneline -3 --since="yesterday"
    git -C "$dir" status --short 2>/dev/null
    echo ""
  fi
done
```

### 4. Kiểm tra digest schedule
```bash
launchctl list | grep claude.daily
```

### 5. Tổng kết
Hiển thị gọn gàng:
- 📰 Digest: highlights hôm nay
- 📝 Notes: gì đã thay đổi hôm qua
- 💻 Projects: git status tóm tắt
- ⏰ Digest bot: đang chạy/tắt
- 🎯 Gợi ý: 1-2 việc nên làm hôm nay dựa trên context
