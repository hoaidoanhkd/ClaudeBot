# App Idea Generator — iOS/SwiftUI

Tìm ý tưởng app iOS/SwiftUI dựa trên market gap analysis, không phải random brainstorm.

## Thực hiện:

### 1. Hỏi lĩnh vực (nếu chưa nói rõ)
Nếu người dùng chưa nêu lĩnh vực, hỏi:
"Bạn đang quan tâm lĩnh vực nào? (health, productivity, language, finance, social, education, utilities, hoặc gì khác?)"

### 2. Đọc Ideas Log (dedup check)
Dùng MCP obsidian đọc file `03 - Resources/App Ideas Log.md`.
Ghi nhớ tất cả ý tưởng đã có để tránh trùng.

### 3. Research (ít nhất 4 searches)

**Search 1: App Store trends**
- "[lĩnh vực] app iOS 2026 trending" OR "best [lĩnh vực] apps iOS"
- Tìm: apps phổ biến nhất, rating, complaints trong reviews

**Search 2: Gaps & complaints**
- "[lĩnh vực] app iOS missing feature" OR "reddit [lĩnh vực] app frustrating"
- Tìm: điều gì người dùng ghét ở apps hiện tại, tính năng thiếu

**Search 3: Indie developer success**
- "indie iOS app [lĩnh vực] revenue" OR "solo developer iOS app success story"
- Tìm: apps indie thành công, business model, niche chưa bão hòa

**Search 4: SwiftUI feasibility**
- "SwiftUI [keyword từ gap analysis]" tutorial OR example
- Tìm: tính năng nào dễ build với SwiftUI, APIs nào Apple cung cấp sẵn

### 4. Phân tích & đề xuất 2-3 ý tưởng

Mỗi ý tưởng cần có:

```
## 💡 Ý tưởng: [Tên app]

**Vấn đề:** [Pain point cụ thể từ research]
**Giải pháp:** [App làm gì, 1-2 câu]
**Target user:** [Ai sẽ dùng]
**Tại sao chưa ai làm tốt:** [Gap analysis từ research]

**MVP scope (1-2 tuần):**
- Feature 1: ...
- Feature 2: ...
- Feature 3: ...

**SwiftUI stack:**
- Frameworks: (SwiftUI, HealthKit, CoreML, etc.)
- APIs: (nếu cần)
- Complexity: Thấp / Trung bình / Cao

**Revenue model:** Free + IAP / Subscription / One-time purchase
**Competition:** [Apps tương tự và tại sao ý tưởng này khác]
```

### 5. Đánh giá & xếp hạng
Xếp hạng mỗi ý tưởng theo 3 tiêu chí (1-5):
- **Market fit:** nhu cầu thật, có người sẵn sàng trả tiền
- **Feasibility:** build được trong 1-2 tuần bằng SwiftUI
- **Differentiation:** khác biệt rõ so với apps hiện có

### 6. Lưu vào Obsidian
Append vào `03 - Resources/App Ideas Log.md`:
```markdown
---
### [Ngày] — [Lĩnh vực]

#### [Tên app 1] ⭐ [tổng điểm]/15
[Tóm tắt 2-3 dòng]
- Market: X/5 | Feasibility: X/5 | Differentiation: X/5

#### [Tên app 2] ⭐ [tổng điểm]/15
[Tóm tắt 2-3 dòng]
- Market: X/5 | Feasibility: X/5 | Differentiation: X/5
```

### 7. Hỏi người dùng
"Bạn thích ý tưởng nào? Tôi có thể:
- Tạo spec chi tiết + wireframe
- Bắt đầu code SwiftUI project ngay
- Tìm thêm ý tưởng lĩnh vực khác"
