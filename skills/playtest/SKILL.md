---
name: playtest
description: Test-play a game to judge how it runs and feels, not just whether tests pass. Films deterministic runs on the desk into contact sheets, installs and drives the build on the phone over adb, measures frame time and thermal, and writes the judgement into NOTES.md. Use after any change to motion, a screen or the first minute, before every ship, and whenever Gideon reports something that "feels" wrong.
argument-hint: desk | phone | scenario <name> | all
---

# Playtest

Suites prove the logic. This skill finds out how the game feels, in the only way a session
can: by filming it and looking. `C:\dev\gamedev-notes\TESTING.md` has the reasoning and the
six questions. The tools live in the game repo's `scripts/`.

## Desk (every visual milestone)

1. Make sure `scripts\check.ps1` is green first. A filmed run of a broken build tells you
   nothing.
2. Pick or write the scenarios. `test/replays/*.json` are recorded touch sequences. Every
   game keeps at least: `idle` (no input, the attract state), `first-minute` (a player's
   first sixty seconds including the first menu open), `boundary` (finish a level and start
   the next), `fail` (run out and retry), `shop` (open, scroll to the bottom, buy, leave).
   Record one with `godot --path . --resolution 460x996 -- record=test/replays/<name>.json touch`
   and play it yourself with the mouse, or write the JSON by hand from Control rects.
3. Film:
   ```powershell
   scripts\movie.ps1 -Replay test\replays\first-minute.json -Seconds 60 -Every 30
   scripts\movie.ps1 -Seconds 10 -Name idle
   ```
   Read `build\movie\<name>\sheet.png` with the Read tool. Tile n is frame n times `Every`.
   Read `godot.log` messages the script prints.
4. Answer the six questions from `TESTING.md` in `NOTES.md` under `## Playtest <date>`:
   feedback in the same frame, speed and coasting, pop-in and layering, the short states,
   the first-minute win and the next goal, any frame where the player would not know what
   to do. Name the frame number for each finding.
5. For a finding, fix, film again, compare sheets. When a report survives a correct fix,
   stop tuning and measure (hide a layer, print the buffer).

## Phone (before every ship, and for anything about touch)

Requires the phone plugged in, unlocked, USB debugging accepted. If `adb devices` shows
nothing, say so in the report and ship on the desk evidence; do not wait.

```powershell
scripts\check.ps1 -Export                 # the APK
scripts\device.ps1 install
scripts\device.ps1 launch
scripts\device.ps1 perf                   # baseline percentiles and thermal
scripts\device.ps1 record 30              # while driving it with tap/swipe below, or by hand
scripts\device.ps1 tap 540 1800 ; scripts\device.ps1 swipe 300 1500 800 1500 200
scripts\device.ps1 back ; scripts\device.ps1 home ; scripts\device.ps1 resume
scripts\device.ps1 perf -Seconds 10       # after play
scripts\device.ps1 log -Dump              # every print and error from the run
scripts\device.ps1 shot
```

Check on the phone, and write the answers in `NOTES.md`: the safe area (nothing under the
camera cutout or the gesture bar), the back button pauses rather than quits, home then
resume returns to a paused game with audio ducked, haptics fire, the frame-time
percentiles and thermal status before and after ten minutes, no `ERROR` in the log, and the
hit boxes line up with the drawn controls (tap a control's drawn centre and watch the log).

## Report

To him: the sheet or the phone video, the findings as numbered lines with frame numbers, and
what changed because of them. His replies go to `playtests/<slug>.md` verbatim. Anything
that generalises goes to `/record-lesson`.
