# Goal Discovery Scan

Scan project BurnRate, phát hiện issues, tạo GOALS.md tự động.

## Thực hiện:

### 1. Chạy scan script
```bash
~/scripts/goal-discovery.sh ~/Desktop/Projects/BurnRate
```

### 2. Phân tích kết quả
Từ scan output, phân loại issues theo:
- **STABILITY**: force unwraps, fatalError (Severity: 4)
- **COMPLETENESS**: TODO/FIXME, empty bodies (Severity: 3)
- **QUALITY**: test coverage, large files (Severity: 2)
- **UX**: hardcoded strings, missing accessibility (Severity: 2)
- **ARCHITECTURE**: file structure, complexity (Severity: 2)

### 3. Tính priority score
Score = Severity² / Effort
- Effort: 1=XS(<1h), 2=S(1-4h), 3=M(1-2d), 4=L(3-5d), 5=XL(>1w)

### 4. Cập nhật GOALS.md
Ghi kết quả vào ~/agents/GOALS.md với format:
- P1 (Score > 4): Critical
- P2 (Score > 1): High
- P3 (Score >= 0.5): Medium
- P4 (Score < 0.5): Low
- Giữ nguyên section ✅ COMPLETED
- Giữ nguyên Periodic Tasks

### 5. Báo cáo
In summary: bao nhiêu issues mới, top 3 priorities, so sánh với lần scan trước.
