# Movie Maker mode ignores `--resolution`, so replay coordinates are the project viewport (about 1080x2338), and a headless run cannot tell you a control's rect

**Game:** stillwater  **Date:** 2026-09-09  **Belongs in:** TESTING.md / filming a run, and GODOT.md / what headless cannot see

## What happened

`scripts\movie.ps1` passes `--resolution 460x996`, and `test/replays/README.md` said to write
replay coordinates "in viewport coordinates at the 460x996 test resolution". Both are wrong
about the same thing. Godot's Movie Maker (`--write-movie`) renders at the **project's**
viewport size and says so in its own log — "recording movie in 1080x1920 @ 60 FPS" — while
`get_visible_rect()` measured from inside the run reports **1080x2338**: the project's 1080
width with `stretch/aspect="expand"` pulling the height out to the phone's shape.
`-Resolution` sizes the window only. ffmpeg does the downscaling afterwards, which is exactly
why the contact sheet looks right and hides the problem.

A replay written against 460x996 therefore lands every tap in the top-left fifth of the
screen. It hits nothing, the run films perfectly, and the sheet shows a game sitting on its
title screen ignoring input — which reads as a broken game, not a broken coordinate.

Getting the real rects took a detour worth recording. A headless run reports
`root.size == (100, 100)` regardless of `--resolution`, and every anchored control resolves
against that: Stillwater's Action button printed `rect=(-306,-464 260x260)`. So no headless
probe can produce replay coordinates. What worked was printing `get_global_rect()` from
inside `_tick` on one frame and filming three seconds — the title buttons came out at
(540,1644), (540,1802), (540,1960), and a replay built on those drove the whole first minute:
title, gate, walk down, cast.

Cost, measured: sixteen seconds of film is 960 full-resolution PNGs and **2.4 GB**, and the
ffmpeg pass afterwards runs into minutes rather than seconds.

## The rule

Write replay coordinates against the project viewport — `1080 x round(1080 * phone aspect)`,
about 1080x2338 on this stack — never against `movie.ps1 -Resolution`, which only sizes the
window. To get a control's real rect, print `get_global_rect()` from inside the game's tick
for one frame and film three seconds; a headless viewport is 100x100 and every anchored
control reports nonsense against it. And film the shortest run that shows the thing: budget
about 150 MB and twenty seconds of wall clock per second of film.

## Replaces or contradicts

Contradicts the template's `test/replays/README.md`, which said 460x996 — corrected in
`godot-template` 2270dbf. It also sharpens a rule already in NOTES.md for Stillwater ("a
headless run uses the base size, where the wrong layout and the right one are identical"),
which was written about screenshots and turns out to govern replay coordinates too, for the
same reason.
