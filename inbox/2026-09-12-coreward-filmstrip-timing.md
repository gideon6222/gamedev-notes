# A filmstrip driven by fixed-step advance misreports anything smoothed or timed per drawn frame or on the wall clock (fades, flashes, light-field smoothing, CSS transitions), so when a sheet shows a fade that should have finished, run the same moment on the real clock and screenshot it before touching the game.

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Judging feel from a filmed run

## What happened
Coreward's filmstrip harness (scripts/filmstrip.mjs, a Playwright contact sheet) advances the game clock in fixed chunks through a debug seam (`advance(0.25)` per frame) and paints one real frame per chunk. A new two-second CONTINUE sequence looked wrong on the sheet: the ground under the landing pad stayed dark in every frame until the frame after play began, which read as "the daylight is not applied until the mode changes". Two probes were written before the cause was found. A probe that dumped the light values (ambient, sun, lamp intensity) showed them identical in the last frame of the sequence and in play. Only a run on the REAL clock (`startClock`, wait 1.7 s of wall time, screenshot) showed the ground lit at 1.7 s, exactly as designed. The cause: the propagated light field's smoothing is applied per DRAWN frame with the skipped simulation time carried into the next draw, which is correct for the game (the seam runs thousands of undrawn ticks) but means a sheet of ten quarter-second frames shows a fade that has barely started. Same family as an earlier finding in this game where a 420 ms white flash on a setTimeout stayed up across two captures. In both cases the game was right and the instrument was lying.

## The rule
A filmstrip driven by fixed-step advance misreports anything smoothed or timed per drawn frame or on the wall clock (fades, flashes, light-field smoothing, CSS transitions), so when a sheet shows a fade that should have finished, run the same moment on the real clock and screenshot it before touching the game.

## Replaces or contradicts
nothing
