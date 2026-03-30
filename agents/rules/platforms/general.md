# General Rules (all platforms)

Loaded for every project regardless of type.

## No git reset --hard in agents repo
NEVER run `git reset --hard` or `git clean` in `~/agents/` or ClaudeBot repo.
Use `git checkout -- <specific-file>` for targeted resets.
Memory files are untracked and irreplaceable.

## Git Workflow
- NEVER commit directly to main — use feature branches
- Each task → `git checkout -b feat/[task-name]`
- Build + test MUST pass before creating PR

## Quality Checklist (before every PR)
- [ ] No hardcoded strings that should be localized
- [ ] No debug prints or temporary code
- [ ] Error handling for all user inputs (empty, nil, overflow)
- [ ] Accessibility labels on new UI elements
