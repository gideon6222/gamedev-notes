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

1. Make sure the gate is green first: `scripts\check.ps1` in a Godot repo, `npm run check`
   in a web one. A filmed run of a broken build tells you nothing.
2. Pick or write the scenarios. `test/replays/*.json` are recorded touch sequences. Run
   `ls test\replays` before you plan the shoot. Most repos carry only `idle.json`, and every
   `idle.json` in the studio is the 3-byte stub `[]`; the only recorded replays that exist
   are gravewell's `first-minute` and stillwater's `first-cast` and `logbook`.
   The set a game is working toward, one recorded at a time as the milestones need them:
   `idle` (no input, the attract state), `first-minute` (a player's first sixty seconds
   including the first menu open), `boundary` (finish a level and start the next), `fail`
   (run out and retry), `shop` (open, scroll to the bottom, buy, leave). Do not assume a
   name on that list is on disk.
   The scenario this milestone needs and the repo does not have gets recorded first, before
   any filming:
   `godot --path . --resolution 460x996 -- record=test/replays/<name>.json touch`, played
   through with the mouse, or written by hand from Control rects. Commit it with the
   milestone. A replay file that is `[]` films the idle game and the sheet looks like a
   pass, which is the failure filming exists to catch.
3. Film:
   ```powershell
   scripts\movie.ps1 -Replay test\replays\first-minute.json -Seconds 60 -Every 30
   scripts\movie.ps1 -Seconds 10 -Name idle
   ```
   Read `build\movie\<name>\sheet.png` with the Read tool. Tile n is frame n times `Every`.
   Read `godot.log` messages the script prints.
   **A filmed second costs about 6 s of wall clock and 3 MB** on this PC (M, template at
   60 fps, one MJPEG file since 2026-09-12; a heavier game renders slower, and the script
   prints its own cost line every run, so use that number rather than this one). Other
   sessions are building on the same machine, so **film the shortest run that shows the
   thing** and raise `-Every` rather than the seconds when you only need coverage: sixty
   seconds is six minutes of somebody else's CPU.
   `-Png` brings back the old lossless PNG per frame plus `frame.wav`, at 2.3x the wall
   clock and 1.6x the disk in this flat-shaded template (M), and a game with real textures
   widens the disk gap because PNG stops compressing. Use it only when a finding needs a
   full-size frame
   with no JPEG in the way (a thin line of type, a gradient, a one-pixel seam) or the audio
   track as a file. The sheet never needs it.
4. Answer the six questions from `TESTING.md` in `NOTES.md` under `## Playtest <date>`:
   feedback in the same frame, speed and coasting, pop-in and layering, the short states,
   the first-minute win and the next goal, any frame where the player would not know what
   to do. Name the frame number for each finding.
5. For a finding, fix, film again, compare sheets. When a report survives a correct fix,
   stop tuning and measure (hide a layer, print the buffer).

## Phone (before every ship, and for anything about touch)

Requires the phone plugged in, unlocked, USB debugging accepted. If `adb devices` shows
nothing, say so in the report and ship on the desk evidence; do not wait.

**One phone, every session.** The pass starts with `scripts\device.ps1 install`, which claims
the phone for you. **Exit code 75 means another game has it: do not wait and do not retry.**
Finish the desk pass instead, then edit the `PHONE TEST OWED` line `device.ps1` has just
written into `NOTES.md` to say what you were going to test on the phone, and say in the report
that the phone pass is owed. End the pass with `scripts\device.ps1 release`. Never call `adb`
directly, for any step: a raw adb call is the one path the lease cannot see, and it is how two
games end up installing over each other.

```powershell
scripts\check.ps1 -Export                 # the APK
scripts\device.ps1 install                # claims the phone; exit 75 = another game has it
scripts\device.ps1 launch
scripts\device.ps1 perf                   # baseline percentiles and thermal
scripts\device.ps1 record 30              # while driving it with tap/swipe below, or by hand
scripts\device.ps1 tap 540 1800 ; scripts\device.ps1 swipe 300 1500 800 1500 200
scripts\device.ps1 back ; scripts\device.ps1 home ; scripts\device.ps1 resume
scripts\device.ps1 perf -Seconds 10       # after play
scripts\device.ps1 log -Dump              # every print and error from the run
scripts\device.ps1 shot
scripts\device.ps1 release                # give the phone back, always
```

Check on the phone, and write the answers in `NOTES.md`: the safe area (nothing under the
camera cutout or the gesture bar), the back button pauses rather than quits, home then
resume returns to a paused game with audio ducked, haptics fire, the frame-time
percentiles and thermal status before and after ten minutes, no `ERROR` in the log, and the
hit boxes line up with the drawn controls (tap a control's drawn center and watch the log).

## An independent read (`all`, and before every ship)

Launch the `playtester` subagent in the game repo and wait for it. It runs the gate, films
every scenario in `test/replays/`, drives the phone if `device.ps1` is there, and returns
numbered findings against the six questions and his recurring complaints. It fixes nothing
and it reports every step it could not run.

Read its findings against your own. The ones it found and you did not are the findings worth
having: you already know what this build was meant to look like, and it does not. Take its
report as evidence, not as a verdict; the fixes are yours.

## Report

To him: the sheet or the phone video, the findings as numbered lines with frame numbers, and
what changed because of them. His replies go to `playtests/<slug>.md` verbatim. Anything
that generalizes goes to `/record-lesson`.
