# A half-ticked milestone box counts as done, because no tool understands `- [~]`

**Game:** wildform  **Date:** 2026-09-13  **Belongs in:** INDEX.md / Standing rule 3

## What happened

wildform's PLAN.md marked M16 (the phone session) as `- [~] **M16** ...` with a "PARTLY DONE 2026-09-12" note, because four of its items had been answered and four were still owed when the phone dropped off USB. Both tools that read the outline count a box as done unless it is exactly `- [ ]`. `scripts\progress.ps1` reported "24 of 24 milestones done (100%), 0 left across 0 phases" and `scripts\doctor.ps1` reported "plan outline 24 of 24 milestones ticked" - while PLAN.md's own prose two sections lower said "M16 is the only unfinished milestone" and NOTES.md listed the four things still owed. So the studio dashboard, the doctor and every stop-and-report opened with a 100% that was wrong, and the one piece of owed work in the repo was invisible to everything except a human reading the prose. The fix is one character: `- [ ]`. The count then read "24 of 25 milestones done (96%), 1 left", "Phase 3: polish and store 4/5 next: M16 <- active". The "PARTLY DONE" paragraph under the box is where partial progress belongs - it is prose, and prose is not counted.

## The rule

A milestone box is `- [x]` or `- [ ]` and nothing else. Partial progress is written in the milestone's own text, never in the box. Any other marker - `[~]`, `[/]`, `[-]` - reads as done to progress.ps1 and doctor.ps1, and the effect is that the only unfinished work in a repo disappears from every count that is supposed to surface it.

## Replaces or contradicts

one `- [ ]` line per milestone, ticked in the commit that finishes it, and each release gets a changelog entry in the player's terms.
