# When a check is moved to run after a step that writes files, run the check once against that step's real output in the same commit

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** TESTING.md / What a green run actually ran is its own subject

## What happened
`scripts/new-game.ps1` was changed (commit "Make the machinery do what the docs say it does") so its placeholder check runs AFTER the README/CLAUDE stubs are written, which was right - the {{TOKEN}} placeholders the stubs introduce were never inspected before. But the stubs legitimately say `built from C:\dev\godot-template`, and the pattern `godot-template|godottemplate|Godot Template|\{\{[A-Z]+\}\}` matched that path, so the very first Godot scaffold after the change (snowball, 2026-09-12) failed on two lines the script had just written itself, leaving a half-made repo at C:\dev\snowball that had to be deleted before re-running. No game had been scaffolded between the change and today, so the failure sat unseen. Fix (committed as "Scaffold: let the stubs name C:\dev\godot-template without tripping the placeholder check"): a negative lookbehind `(?<!C:\\dev\\)godot-template` so the literal template path passes and a bare leftover name still fails.

## The rule
When a check is moved to run after a step that writes files, run the check once against that step's real output in the same commit. A check moved later in a pipeline sees new legitimate content, and the first run that finds out should be the commit that moved it, not the next scaffold. Measured: the stale window was two commits and about one day; the cost was one failed scaffold and a manual delete.

## Replaces or contradicts
"- **Point runners at a glob and FAIL on an empty glob** - zero suites and a green exit are indistinguishable from outside, and a sibling game reported "65 passing" for a suite that had never run."
