# Conventions — BurnRate
# Last updated: 2026-04-01

## Git Workflow
- NEVER commit to main — feature branches + PR
- Naming: feat/xxx, fix/xxx, chore/xxx
- Squash merge, delete branch after merge

## PR Format
- Title: short, descriptive
- Body: link GitHub Issues with Closes #N
- CI disabled (billing) — local build verify only

## File Organization
- Views: BurnRate/Views/ (by feature)
- Components: BurnRate/Views/Components/
- Models: BurnRate/Models/
- Services: BurnRate/Services/

## New File Checklist
- Add to pbxproj (PBXBuildFile + PBXFileReference + Group + Sources)
- Add #Preview macros
- Check simulator: xcrun simctl list devices available

## Code Quality
- No force unwraps (!)
- No hardcoded strings (localize)
- Error handling for all user inputs
- Accessibility labels on interactive elements
