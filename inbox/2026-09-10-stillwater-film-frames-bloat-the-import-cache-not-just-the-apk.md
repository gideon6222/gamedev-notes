# Film frames bloat the IMPORT CACHE as well as the APK, and that symptom is a gate that slowly gets slower

**Game:** stillwater  **Date:** 2026-09-10  **Belongs in:** `GODOT.md` under export, extending the line the gravewell lesson just added

## What happened

The 2026-09-10 digest folded in Gravewell's finding: `movie.ps1` writes one PNG per frame into
`build/`, the exporter walks the project directory, and the next APK was 1.42 GB. The fix is
`exclude_filter` in every preset plus a `build/.gdignore`.

Applying it to Stillwater, which had been filmed a dozen times that session, the APK measured
**35.6 MB with and without the filter** — apparently proving the filter did nothing. It does
nothing *there*, because this game deletes its frames after reading each contact sheet, so
there was nothing left for the exporter to pack.

The damage was one step earlier. `.godot/imported/` held **1.7 GB** across 2,646 entries, all
film frames, and `build/` held **1,026 stale `.import` files** pointing at PNGs that had been
deleted weeks of frames ago. Godot imports a frame the moment it appears and keeps the
converted copy forever; deleting the source does not reclaim it.

It had been visibly costing time all session and was read as something else: the gate's import
step drifted from 5.8 s to 45 s to 80 s as more runs were filmed. That reads as a slow
machine, or as a big asset import, and it is neither.

    .godot/imported   1.7 GB -> 27 MB
    import step       80 s   -> 5.8 s

## The rule

**`.gdignore` is the load-bearing half of that fix, not `exclude_filter`.** The filter protects
the package; the marker protects the importer, and the importer is hit on every single run of
the gate rather than only on an export. A game that cleans up its frames is fully exposed to
the second and completely immune to the first, which is exactly backwards from how the fix
reads.

**A gate step that gets slower over a session is a symptom, not a machine.** Time the steps.
`check.ps1` already prints each one's duration, which is the only reason the drift was
recoverable after the fact.

And when tidying an existing repo, the marker stops new imports but **does not remove the ones
already made**: delete `build/**/*.import` and the matching `.godot/imported/` entries by hand
once, or the 1.7 GB stays.

## Replaces or contradicts

Extends, does not contradict, the `GODOT.md` export line from Gravewell — which currently
justifies the pair with the APK number and so makes `exclude_filter` look like the important
half. Worth adding the import-cache number beside it so the `.gdignore` is not treated as
optional tidiness.

## Also worth recording: the measurement that lied

The first attempt to establish the "before" exported with `exclude_filter` cleared and got the
same 35.6 MB — because the `.gdignore` was already in place, so the two fixes were covering for
each other. That is precisely the confounder rule from `TESTING.md` ("call the function under
test with fixed inputs; stepping a frame runs every confounder you are trying to exclude")
applying to a build system rather than to a game, and it caught the person who had written the
rule into the file an hour earlier. **When two fixes address one fault, removing one and
measuring proves nothing.**
