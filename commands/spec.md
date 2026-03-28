# App Spec Generator — iOS/SwiftUI

Tạo PRD + Technical Spec từ ý tưởng đã chọn trong Ideas Log. Nối tiếp flow: `/idea` → `/spec` → code.

## Thực hiện:

### 1. Đọc Ideas Log
Dùng MCP Obsidian đọc file `03 - Resources/App Ideas Log.md`.
Liệt kê các ý tưởng gần nhất và hỏi user:
"Bạn muốn tạo spec cho ý tưởng nào?"

Nếu user đã nêu tên app cụ thể (ví dụ gọi `/spec BurnRate`), bỏ qua bước hỏi và dùng ý tưởng đó.

### 2. Research bổ sung (2-3 searches)

**Search 1: UX patterns**
- "best [loại app] app UI UX design iOS"
- Tìm: màn hình chính của competitors, UX patterns phổ biến

**Search 2: Technical feasibility**
- "SwiftUI [framework cần dùng] tutorial example 2025 2026"
- Tìm: code examples, gotchas, limitations của frameworks

**Search 3: Monetization validation**
- "[loại app] app pricing strategy indie iOS"
- Tìm: price points thành công, conversion rates, paywall placement

### 3. Tạo PRD (Product Requirements Document)

```markdown
# [Tên App] — PRD

## Vision
[1-2 câu mô tả app và giá trị cốt lõi]

## Target Users
- Primary: [persona chính + pain point]
- Secondary: [persona phụ nếu có]

## User Stories
1. As a [user], I want to [action] so that [benefit]
2. ...
(Liệt kê 5-8 user stories cho MVP)

## Screens & Navigation

### Screen 1: [Tên] (Tab/Root)
- Purpose: ...
- Key elements: ...
- User actions: ...

### Screen 2: [Tên]
...

(Mô tả từng screen, 4-6 screens cho MVP)

## Core Features (MVP)
| # | Feature | Priority | Complexity |
|---|---------|----------|------------|
| 1 | ...     | P0       | Low        |
| 2 | ...     | P0       | Medium     |
| 3 | ...     | P1       | Low        |
(P0 = must have, P1 = should have, P2 = nice to have)

## Monetization
- Model: [Free + IAP / Subscription / One-time]
- Free tier: [những gì miễn phí]
- Paid tier: [giá + những gì unlock]
- Paywall placement: [khi nào show paywall]
```

### 4. Tạo Technical Spec

```markdown
# [Tên App] — Technical Spec

## Architecture
- Pattern: MVVM
- Data: SwiftData
- Navigation: NavigationStack

## Data Model
```swift
@Model class [Entity1] {
    var id: UUID
    var name: String
    // ... properties
}
```
(Định nghĩa tất cả models cần thiết)

## SwiftUI Components

### Views
| View | Type | Description |
|------|------|-------------|
| ContentView | TabView | Root navigation |
| [Screen]View | Screen | ... |
| [Widget]View | Component | Reusable |

### ViewModels
| ViewModel | Responsibilities |
|-----------|-----------------|
| [Name]ViewModel | ... |

## Frameworks & APIs
| Framework | Usage | Notes |
|-----------|-------|-------|
| SwiftUI | UI | iOS 17+ |
| SwiftData | Persistence | ... |
| Charts | Visualizations | ... |
| WidgetKit | Home screen widgets | ... |
(Liệt kê tất cả frameworks cần import)

## Project Structure
```
[AppName]/
├── App/
│   └── [AppName]App.swift
├── Models/
│   └── ...
├── ViewModels/
│   └── ...
├── Views/
│   ├── Screens/
│   └── Components/
├── Services/
│   └── ...
├── Extensions/
│   └── ...
└── Resources/
    └── Assets.xcassets
```

## Implementation Order
1. [ ] Data models + SwiftData setup
2. [ ] Core views (skeleton)
3. [ ] Business logic (ViewModels)
4. [ ] Charts / visualizations
5. [ ] Widgets (nếu có)
6. [ ] StoreKit / IAP
7. [ ] Polish + animations
```

### 5. Lưu vào Obsidian
Tạo file mới trong Obsidian: `03 - Resources/Specs/[Tên App] Spec.md`
Nội dung = PRD + Technical Spec gộp lại.

### 6. Hỏi user tiếp theo
"Spec đã lưu vào Obsidian. Bạn muốn:
- 🛠 Bắt đầu code ngay (cho tôi path tới folder project)
- 🎨 Xem wireframe trước
- ✏️ Chỉnh sửa spec"
