# Film from the state, not from the beginning: the drive-in is most of the bill, so put the seam on the game and let every tool ask for a situation by name

**Game:** godot-template  **Date:** 2026-09-13  **Belongs in:** TESTING.md / filming and contact sheets

## What happened

Every filming and screenshot tool in the studio reached an interesting moment the only way a
player can, by playing from frame one until it arrived. The four states `godot-template`
could be put into lived in `scripts\shot.gd` alone, as arms of a match in the screenshot
tool, so `movie.ps1` knew none of them and had no way to skip the drive-in.

Measured on `godot-template` on 2026-09-13, filming at 60 fps into one MJPEG file. The unit
rate is 6.3 s of wall clock and 3.0 MB per second of film, either way. Level 2 opens 28.9 s
into the run (26.7 s of level 1 plus the 2.2 s interlude), so five seconds of it cost:

| | film | frames | wall clock | disk |
|---|---|---|---|---|
| by playing to it | `-Seconds 34` | 2040 | 216.0 s | 100.7 MB |
| by seeking to it | `-State level2 -Seconds 5` | 300 | 37.3 s | 14.9 MB |

Six times faster and seven times smaller for the same five seconds of picture, and the gap
grows with how deep into a run the moment is. What `-State` buys is not a cheaper second, it
is not filming the 29 seconds in front of the one you want.

The seam is three methods on the GAME, not on the tool: `dev_states()` (the one table of
names and one-line descriptions), `dev_seek(name)` (put the game there, return false for a
name it does not know, and hand back a RUNNING game) and `dev_heartbeat()` (the few numbers
that must move). A name ending in `.json` is loaded through the save pair, so a run pulled
off the phone is a state like any other. `shot.gd`, `replay_player.gd` and `movie.ps1` all
ask the same object the same question, so there is one writer and a state is a word on a
command line rather than the tenth near-identical `shot_*.gd` file.

Three things were only found because the seam was filmed rather than reasoned about. A seek
that leaves the game frozen films twenty seconds of a still picture, so the contract had to
be that a seek returns a RUNNING game and the screenshot tool stops the clock itself. The
`level2` arm played greedily for six seconds on a denser level and arrived with one life
left, so the first film of it died twelve frames in and spent its budget on a fresh level 1
- a state you cannot play out of is not a state. And a refused `.json` had already reset the
run before finding out the file was not there, which the suite caught on the first draft.

The same `dev_heartbeat()` is what makes a long run say early whether it is getting
anything. `movie.ps1` passes `beat` on every film, the game prints `DEVBEAT f=<frame> k=v`
lines every 30 physics frames, `-StallSeconds` (45) kills a run whose READING has stopped
changing and `-MaxMinutes` (15) is the wall clock. Godot does not block-buffer stdout under
redirection - measured, beats arrive at about 100 a second in a continuous trickle, never in
one lump at the end - so a stall is visible while it is happening. An infinite loop in
`_ready` now costs 30 s instead of six minutes. A film shorter than `-StallSeconds` ends
before the watchdog would fire, so the first and last readings are compared afterwards too
and an unchanged pair throws with the two frame numbers rather than handing back a contact
sheet of a frozen picture.

## The rule

**Put `dev_states()`, `dev_seek(name)` and `dev_heartbeat()` on the game, and film from the
state.** A moment N seconds into a run costs N seconds of film to reach and nothing to seek
to; measured on the template, five seconds of level 2 cost 216.0 s and 100.7 MB by playing
to it and 37.3 s and 14.9 MB by seeking to it. Add an arm to `dev_seek`, never a new
`shot_*.gd`. A seek hands back a RUNNING game, a refusal leaves the simulation exactly as it
was, and a state you cannot play out of is not a state - assert all three, planting a
synthetic state first so a seek that does nothing cannot pass. Record a touch replay only
for what a seek cannot reach, which is a GESTURE; `-State` and `-Replay` together are
refused, because a replay is touches pinned to numbered physics frames of a run that started
at the beginning. **And make every long film prove it is getting data**: a heartbeat every
30 physics frames, a watchdog on the reading rather than on the line, and a first-against-last
comparison after the run. `doctor.ps1 Test-DevStates` WARNs while a game has no seam.

## Replaces or contradicts

Extends this line in TESTING.md, which is still true about the unit rate and is now only
half the advice:

> - **Budget about 6 s of wall clock and 3 MB per second of film at 60 fps** (M, flat-shaded
>   template - `movie.ps1` prints its own cost line every run, read that rather than this number). [...]
>   Film the shortest run that shows the thing, keep output
>   out of any directory Godot imports (`build/.gdignore`), and print the console errors with the
>   sheet.

"Film the shortest run that shows the thing" was advice about `-Seconds` when the start of
the film was not a choice. It is now advice about both ends: seek to the start, then film
the shortest run. The measured rate itself is unchanged (6.3 s and 3.0 MB per filmed second
on the template, remeasured 2026-09-13).
