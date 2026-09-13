# Film to one MJPEG file, not a PNG per frame: the sheet is identical and it costs 44 per cent less wall clock

**Game:** template  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Filming a run: the tool that judges motion, and techniques/filming-a-run.md

## What happened
Filming a run was the most expensive thing the studio does on a PC running several sessions
at once, so it got measured instead of guessed. `scripts\movie.ps1 -Seconds 18 -UserArgs
policy=dodger` in `godot-template`, the 1080-frame run: **187.5 s wall clock, 82.7 MB, 1084
files**. Timing the three phases apart showed where it went: **render 157 s, contact sheet
4.8 s, mp4 24 s**. So the sheet was never the cost. The cost was that Godot encoded 1080
full-size PNGs on the way out and ffmpeg decoded all of them twice on the way back in, and
**nothing ever read one of those PNGs** - the only artefacts anyone opens are a 54-tile
contact sheet scaled to 230 px wide and an mp4 at crf 22, both already lossy and both
already downscaled. Switching `--write-movie` to `build/movie/<name>/run.avi`, which is
Godot's built-in MJPEG writer, and making the sheet and the mp4 in one ffmpeg invocation
with `split`, gave **106.2 s, 52.7 MB, 4 files** (render 86.7 s, sheet and video together
18.9 s) for the same 1080 frames. The sheet is the same picture tile for tile: **SSIM 0.992,
PSNR 42.6 dB** against the old one, and a full-size frame pulled back out of the AVI is
**PSNR 44.9 dB** against its PNG, with the build stamp still crisp, so `mjpeg_quality` was
left alone. The old `$pngs.Count -lt 2` guard could not tell a run that stopped a second in
from a short film, so it is now an ffprobe frame count that refuses anything under 90 per
cent of the frames asked for: the header count is 0.3 s and a full decode is 10.8 s, so it
reads the header first and only decodes when the header is absent, which is exactly what a
crashed writer leaves behind. Verified by pointing `run/main_scene` at a scene that does not
exist: 0 of 300 frames, the top of `godot.log` printed, no sheet.

## The rule
**Film with Godot's MJPEG writer (`--write-movie <dir>/run.avi`) and build the sheet and the
mp4 from that one file in a single ffmpeg pass.** Budget **about 6 s of wall clock and 3 MB
per second of film** at 60 fps (M, flat-shaded template; `movie.ps1` prints its own cost
line every run, so read that rather than this number), and still film the shortest run that
shows the thing. `-Png` restores the PNG sequence and `frame.wav` at 2.3x the wall clock and
1.6x the disk, for the one case that needs it: a full-size frame with no JPEG in the way (a
thin line of type, a gradient, a one-pixel seam, a pixel check) or the audio as a file. The
AVI stays on disk, so re-tiling at a different `-Every` no longer costs a re-render. **The
frame count comes from the file, not from whether any file exists** - a guard that only asks
"is something there" passes a run that died and hands back a plausible sheet of the wrong
thing.

## Replaces or contradicts
Three places say the old mechanism or the old number:

1. `TESTING.md:344`, in "Filming a run: the tool that judges motion": "`scripts/movie.ps1`
   drives the game with Godot's Movie Maker mode at a fixed timestep over a seeded sim, so
   **a replay file produces the same frames on every run**" - the determinism sentence still
   holds, but the surrounding mechanism is now one MJPEG file rather than one PNG per frame,
   and the example block's "`-> build/movie/<name>/frame00000000.png ... and
   build/movie/<name>/sheet.png`" (TESTING.md:354) names files that no longer exist unless
   `-Png` is passed.
2. `TESTING.md:366`: "**Budget about 150 MB and twenty seconds of wall clock per second of
   film** (M)." Replace with about 3 MB and 6 s per second of film at 60 fps, measured on
   the template, and keep the "film the shortest run that shows the thing" sentence that
   follows it, which is now about other sessions' CPU rather than about disk.
3. `techniques/filming-a-run.md`, two places: the mechanism paragraph, "`--write-movie
   out/frame.png --fixed-fps 60 --quit-after N --resolution 460x996` renders a PNG per frame
   at a fixed timestep with the dummy audio driver", and the "What it costs, and what it
   found" section, "**Budget about 150 MB and twenty seconds of wall clock per second of
   film** (M): sixteen seconds is 960 full-resolution PNGs and 2.4 GB." Both need the new
   command, the new numbers and the `-Png` escape hatch. That 2.4 GB was measured in a real
   textured game and the numbers here are the flat-shaded template, so keep the game figure
   as the upper end rather than deleting it outright.
