# The size guard measures whatever APK is sitting in `build/`, so run `check.ps1 -Export` in the commit that changes assets

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** POLISH.md / the ship gate, and GODOT.md / the commands

## What happened
A shed full of imported props took Stillwater's APK from 35.6 MB to 64.58 MB, an 81% jump over
its budget. Local `scripts\check.ps1` reported the size step GREEN and the commit was pushed;
CI failed on the same check a minute later. The guard reads the APK file in `build/`, and mine
was from the previous export, so it had measured an APK that did not contain any of the assets
under review. Every local run since the last export had been re-measuring the same stale
artefact and passing. The real fix took the build to 43.71 MB through `process/size_limit`
(512 on the props on screen, 256 on background-only ones) and the budget was re-recorded with
that number and the reason.

## The rule
A size guard that reads a build artefact is only as fresh as the artefact. In any commit that
adds, removes or reimports an asset, run the check with `-Export` so the APK is rebuilt before
it is weighed, and treat a green size step over a stale APK as no measurement at all. The
cheap version of this is to fail the guard when the APK is older than the newest file under
`assets/`.

## Replaces or contradicts
GODOT.md line 80: "`& $godot --headless --path . --script res://scripts/check_size.gd      # size guard, both directions`" - correct as a command, but it says nothing about what it is weighing, which is the whole trap.
