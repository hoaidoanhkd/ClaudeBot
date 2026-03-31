
## 2026-03-30 — Decimal comparison in SwiftData #Predicate (PR #165)
- Anti-pattern: Using `Decimal` values in `#Predicate` for `@Query` (e.g., `$0.balance < 0`, `$0.currentAmount < $0.targetAmount`)
- Risk: SwiftData stores Decimal as TEXT in SQLite → string comparison semantics differ from numeric (e.g., "-50" > "-100" as strings but -50 > -100 numerically is false)
- Fix: Keep Decimal comparisons as in-memory `.filter {}` OR verify SwiftData's actual storage type and predicate translation behavior first
- Safe alternatives: Use Int (points/cents) for amounts if DB-level filtering is needed, or store a computed Bool property (e.g., `isNegative: Bool`) and filter on that

## 2026-03-30 — Nested .shimmer() in skeleton hierarchy (PR #167)
- Anti-pattern: Applying .shimmer() to a container view (DashboardSkeleton) that already contains sub-components (SkeletonCard, SkeletonRow) which call .shimmer() internally
- Risk: Double gradient overlay with competing @State phase animations → overly bright or visually inconsistent shimmer effect
- Fix: Apply shimmer at ONE level only. Either (a) remove top-level shimmer from DashboardSkeleton, or (b) make SkeletonCard/SkeletonRow not shimmer and let parent apply it
- Rule: If a composable skeleton is used standalone AND inside a parent skeleton, extract a ShimmerFree variant

## 2026-03-30 — AppCategory.find without custom categories (PR #169)
- Anti-pattern: AppCategory.find($0.categoryId) when categoryId may belong to a custom category
- Risk: Falls back to all.last! (last built-in expense category) → wrong display name shown
- Fix: Always use AppCategory.find(id, custom: customCategories.map(\.asAppCategory)) when custom categories may be present
- Rule: Any place that resolves a categoryId string to a display name must consider custom categories

## 2026-03-31 — PR #196 — Incomplete parameter threading
- Anti-pattern: Claiming to fix "all AppCategory.find() calls" without running grep to verify all call sites. Budget views (BudgetRowView, DashboardBudgetSummary, BudgetFormViews, InactiveBudgetRow) and service layer (BudgetViewModel, NotificationManager) were missed.
- Prevention: Before submitting a "fix all X calls" PR, run: `grep -rn "\.find(\|displayName\|\.icon\|\.colorHex" --include="*.swift"` and check every result is updated or has a justification for why it doesn't need custom categories.
- Tags: custom-categories, grep-verification, incomplete-fix
