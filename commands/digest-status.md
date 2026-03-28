# Daily Digest Status

Kiểm tra trạng thái Daily Claude Code Digest và hiển thị thông tin quản lý.

## Thực hiện tuần tự:

### 1. Kiểm tra launchd
Chạy: `launchctl list | grep claude.daily`
- Nếu có kết quả → đang active
- Nếu không → đã tắt

### 2. Xem config schedule
Chạy: `plutil -p ~/Library/LaunchAgents/com.claude.daily-digest.plist`
Lấy giờ chạy từ StartCalendarInterval.

### 3. Xem log gần nhất
Chạy: `tail -20 ~/.claude/scheduled/logs/digest-$(date +%Y-%m-%d).log 2>/dev/null || echo "Chưa có log hôm nay"`

### 4. List created digest notes
Run: `ls -la ~/path/to/digest/folder/ 2>/dev/null | tail -10`

### 5. Xác định chủ đề hôm nay
Dựa theo thứ trong tuần (date +%u):
- 1=Thứ 2: CLAUDE.md
- 2=Thứ 3: Hooks & Automation
- 3=Thứ 4: Agents & Skills
- 4=Thứ 5: MCP & Plugins
- 5=Thứ 6: Workflow & Productivity
- 6=Thứ 7: Channels & Remote
- 7=Chủ nhật: Tổng hợp tuần

### 6. Hiển thị tổng kết
Format rõ ràng với:
- Trạng thái: Active/Inactive
- Giờ chạy: HH:MM
- Chủ đề hôm nay + ngày mai
- Log cuối cùng (tóm tắt)
- Số digest notes đã tạo
- Lệnh quản lý nhanh:
  - Tắt: `launchctl unload ~/Library/LaunchAgents/com.claude.daily-digest.plist`
  - Bật: `launchctl load ~/Library/LaunchAgents/com.claude.daily-digest.plist`
  - Chạy thủ công: `~/.claude/scheduled/daily-digest.sh`
  - Xem log: `cat ~/.claude/scheduled/logs/digest-$(date +%Y-%m-%d).log`
