# Learn — Claude Code Tip of the Day

Tìm và dạy 1 tip/trick Claude Code mới mỗi ngày. Chủ đề xoay theo thứ (giống digest).

## Xác định chủ đề
Chạy: `date +%u` để biết thứ mấy:
- 1=T2: CLAUDE.md tips
- 2=T3: Hooks & automation tricks
- 3=T4: Agents & Skills patterns
- 4=T5: MCP server tricks
- 5=T6: Workflow & productivity hacks
- 6=T7: Channels & remote tips
- 7=CN: Hidden features & Easter eggs

## Thực hiện:

### 1. Đọc Tips Log TRƯỚC (dedup check)
Dùng MCP obsidian đọc file `03 - Resources/Claude Code Tips Log.md`.
- Đếm số tips hiện có → tip tiếp theo = số đó + 1
- Ghi nhớ TOÀN BỘ tiêu đề và từ khóa chính của các tips đã có
- Danh sách này dùng để TRÁNH TRÙNG LẶP ở bước 3

### 2. Web search
Tìm 1 tip CỤ THỂ và THỰC HÀNH ĐƯỢC ngay theo chủ đề hôm nay.
Search: "Claude Code [chủ đề]" tip trick tutorial
Ưu tiên: bài có code/config copy-paste được.

### 3. Kiểm tra trùng lặp (QUAN TRỌNG)
So sánh tip tìm được với danh sách tips đã có từ bước 1:
- Nếu TRÙNG nội dung (dù khác nguồn) → BỎ QUA, search tip khác
- Nếu TƯƠNG TỰ nhưng có góc nhìn mới → OK, nhưng ghi chú "Mở rộng từ Tip #X"
- Nếu HOÀN TOÀN MỚI → OK, tiếp tục
- Lặp lại search tối đa 3 lần nếu cứ bị trùng
- Nếu sau 3 lần vẫn trùng → thông báo "Đã hết tips mới cho chủ đề này, thử chủ đề khác?"

### 4. Hiển thị tip
Format:
```
🎓 Claude Code Tip #[số] — [Chủ đề]

[Mô tả ngắn gọn vấn đề]

💡 Tip: [giải pháp cụ thể]

📋 Code/Config:
[code block copy-paste được]

🔗 Nguồn: [link]
```

### 5. Lưu vào log
Append vào Obsidian file `03 - Resources/Claude Code Tips Log.md`:
```markdown
### Tip #[số] — [ngày] — [chủ đề]
[nội dung tip]
[link nguồn]
```

### 6. Hỏi người dùng
"Bạn muốn thử tip này ngay không? Hay muốn tìm tip khác?"
