# A game that pauses on focus loss must skip that while OS.has_feature("movie") is true, and print a line when focus-out fires so the film's godot.log says whether it happened

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Filming a run, and techniques/filming-a-run.md

## What happened

Two measured facts. (1) The MJPEG movie.ps1 (forward-ported from the template today) in a real textured 3D game (Snowball: Forward Mobile, HDRI sky, glb kits, a 288x7740 SubViewport trail, 460x996 at 60 fps) costs 6.6 s of wall clock and 6.6 MB of disk per filmed second: 12 s = 720 frames, 79.7 s total (render 58.8 s, sheet+video 20.9 s), 78.9 MB; 8 s = 480 frames, 67 s, 54.4 MB. The old PNG-per-frame script filmed 60 s of the same game in 37 min 56 s (2276 s, 38 s per filmed second, 2063 s of it PNG encoding at 573 ms/frame). So for a textured game the wall clock is 5.8x better and disk is about 2.2x the template's 3 MB/s figure because the MJPEG frames are bigger, which is the upper end the template lesson asked to keep. (2) A filmed run paused itself at 3 s (tiles 6 to 23 of a 12 s sheet were the Paused shell) because the game pauses on NOTIFICATION_APPLICATION_FOCUS_OUT (the correct phone behaviour: home then resume returns to a paused game) and the desktop took the Godot window's focus during the 80 s render. A second run did not reproduce it, so the cause is inferred from the pause shell in the sheet, not proven.

## The rule

A game that pauses on focus loss must skip that while OS.has_feature("movie") is true, and print a line when focus-out fires so the film's godot.log says whether it happened. A film must not depend on what the desktop does during the render, and the sheet of a paused game looks like a pass (the frames are all valid) until someone reads it.

## Replaces or contradicts

nothing
