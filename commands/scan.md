# Goal Discovery Scan

Scan the current project, detect issues, and auto-generate GOALS.md.

## Steps:

### 1. Run scan script
```bash
# Uses PROJECT_PATH from config.env
source ~/agents/config.env
~/scripts/goal-discovery.sh "$PROJECT_PATH"
```

### 2. Analyze results
From scan output, classify issues by:
- **STABILITY**: force unwraps, crashes, unhandled errors (Severity: 4)
- **COMPLETENESS**: TODO/FIXME, empty bodies, missing implementations (Severity: 3)
- **QUALITY**: test coverage, large files, code smells (Severity: 2)
- **UX**: hardcoded strings, missing accessibility, UX issues (Severity: 2)
- **ARCHITECTURE**: file structure, complexity, coupling (Severity: 2)

### 3. Calculate priority score
Score = Severity^2 / Effort
- Effort: 1=XS(<1h), 2=S(1-4h), 3=M(1-2d), 4=L(3-5d), 5=XL(>1w)

### 4. Update GOALS.md
Write results to ~/agents/GOALS.md with format:
- P1 (Score > 4): Critical
- P2 (Score > 1): High
- P3 (Score >= 0.5): Medium
- P4 (Score < 0.5): Low
- Preserve COMPLETED section
- Preserve Periodic Tasks

### 5. Report
Print summary: new issues found, top 3 priorities, comparison with previous scan.
