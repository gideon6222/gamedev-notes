# Filming a run: Movie Maker, replay files, and the coordinates that make or break a shoot

**Game:** every Godot game in the studio; `movie.ps1`, `replay_player.gd`, `rects.gd` and `stamp.ps1` are template scripts · **Status:** in every repo except wrecking-crew, which has no `test/replays` at all · **Read when:** setting up filming in a new repo; a contact sheet that looks like the idle game; writing or recording a replay; a filmed run that dies after writing every frame

Every still-image tool answers "does this moment look right". Half of what a game is judged on is
movement, and a contact sheet is the only instrument that sees it. The trap is that almost every
way this goes wrong produces a **plausible sheet of the wrong thing** rather than an error, so the
run looks like a pass.

**Generalisable takeaways**

- **Replay coordinates are in the PROJECT viewport, not the window.** Every wrong-coordinate
  failure lands every tap in the top-left fifth and films a game that looks broken.
- **A tool's own chatter is not a failure**, and a wrapper that treats it as one fails after doing
  all the work.
- **The first time a tool is used in a repo is a test of the TOOL, not of the repo.**

---

## The mechanism

`--write-movie <dir>/run.avi --fixed-fps 60 --quit-after N --resolution 460x996` renders to
Godot's built-in MJPEG writer at a fixed timestep with the dummy audio driver. Because the
timestep is fixed and the sim is seeded, **a replay file produces the same frames on every run**,
which is what makes two sheets a week apart comparable cell for cell. `ffmpeg` builds the contact
sheet and the mp4 from that one AVI in a single pass, every Nth frame tiled with the frame number
burned in, so tile *n* is frame *n* × `-Every` and a finding can be cited by number. `-Png`
switches back to a PNG per frame (`out/frame.png`) plus `frame.wav`, for the rare case that needs a
full-size frame with no JPEG in the way: a thin line of type, a gradient, a one-pixel seam, a pixel
check, or the audio as a file.

**It must not run headless.** A real window, small and off-screen, is the whole point.

`scripts/replay_player.gd` is an autoload that reads **`replay=<file>`** from the user args and
feeds recorded `InputEventScreenTouch`/`Drag` events through `get_viewport().push_input(ev, true)`
on the recorded physics frame. Record on the desk with **`record=<file>`**, or on the phone (it
writes to `user://`; pull it with adb).

**Both are bare words with no leading `--`.** Godot eats a leading `--` even after the `--`
separator (`GODOT.md`) and the player matches only the bare form, so `--replay=` feeds no events,
reports no error, and films a sheet of the idle game.

## Coordinates, which is where the shoots are lost

**Write replay coordinates against the PROJECT viewport, not `-Resolution`.** Movie Maker renders
at the project's viewport size; `-Resolution` only sizes the window. Measured from inside a run,
`get_visible_rect()` is **1080x2338** (M) on this stack, not the 460x996 the sheet is downscaled
to. A replay written at 460x996 lands every tap in the top-left fifth.

**No headless probe can produce replay coordinates.** A headless root reports 100x100 and every
anchored control resolves against that, so again every tap lands in the top-left fifth and the
sheet shows a game that looks broken rather than a coordinate that is.

Do not hand-roll the probe. **`scripts/rects.gd` is in every repo:**

```powershell
godot --path . --resolution 460x996 --script res://scripts/rects.gd
```

It opens a real window, lets six frames pass, **walks the scene** rather than naming controls, and
prints each control's rect, centre, visibility and `mouse_filter`. Three details are load-bearing:

- Walking rather than naming: the version it replaced named four nodes out of the game it had been
  copied from, so it had **never once run** where it shipped.
- `mouse_filter` is printed because a tap delivered to an `IGNORE` control hits whatever is behind
  it, and a miss is a green run that proves nothing.
- It **fails loudly on finding no Control at all**, since an empty listing and a broken walk look
  identical from outside.

## The live-policy seam: `policy=<name>` and `bot_drag_pixels`

A third mode alongside `replay=` and `record=`. `replay_player.gd` owns everything that is the
same in every game - the `policy=<name>` arg, the frame gate, the clamp on how fast a thumb can
move (54 px per physics frame, 1080 px in a third of a second at 60 Hz), building the
`InputEventScreenDrag` and pushing it at the viewport. The game supplies one method:

```gdscript
## Required. The drag, in pixels, the real handler would need this frame to get where the
## named policy wants to be. Must not leave the simulation changed.
func bot_drag_pixels(policy: String, mem: Dictionary, span: float) -> Vector2

## Optional. False during an interlude and after the run is over.
func bot_can_drive() -> bool
```

Found by `has_method("bot_drag_pixels")`, not a class or node name, so the seam can live on the
main scene or a rig node - and it refuses loudly once when nothing implements it, since silence
there is a filmed run of a game nobody is playing, which looks exactly like a filmed run of a game
that ignores input.

Three details cost time on wildform, all now in `godot-template`:

- **Write the pixel conversion from the handler's OWN constants, inverted.** The template's
  `drag_by` does `dx / span * Tuning.LANE_HALF_WIDTH * 3.4`, so `bot_drag_pixels` does
  `world_dx * span / (Tuning.LANE_HALF_WIDTH * 3.4)`. A measured fudge factor drifts the moment the
  control is retuned, and a bot that steers almost right films a plausible run of a broken game.
- **Put the simulation back.** `Policies.steer` mutates the sim to answer, so the wanted target is
  read and the old one restored - left set, the bot takes the shortcut AND films it, the exact
  thing the seam exists to stop.
- **Clamp to what a thumb can do in one frame**, or it teleports and the film says nothing about
  whether the control is reachable.

`test/test_replay_policy.gd` gates the seam itself: the method exists, asking does not move the
sim, a policy that wants nothing asks for nothing, and - the one that matters - the drag the bot
asks for, pushed through the real handler, leaves the policy with nothing left to ask for. That
last one is a property rather than a restatement of the formula, so it catches an inverted control
without naming one: a wrong sign moves the avatar the other way and the second ask comes back
LARGER, not zero.

**Owed, not yet paid.** candle-gift, gravewell and wrecking-crew each grew their own control seam
under their own name, and none has the template's `drag_by`: each needs its own small bespoke
`bot_drag_pixels` and gate. Wildform has the behaviour already and should move onto the template's
shared contract so there is one shape rather than two.

**A game played by pressing, not dragging, needs a second contract.** Stillwater is played
entirely by holding one button, so a faithful `bot_drag_pixels` would return zero forever - the
exact inert seam the gate exists to catch. The template driver now also accepts an optional

```gdscript
## Where the thumb is DOWN this frame in viewport pixels, or Vector2.INF for up.
func bot_touch_pixels(policy: String, mem: Dictionary, size: Vector2) -> Vector2
```

turning the edges into real `InputEventScreenTouch` press/release pairs on finger index 1 (finger
0 stays the drag thumb), lifting the thumb whenever `bot_can_drive()` refuses, and treating a
point that moved to a different control as a lift now and a press next frame. Game side, split
`act` into a read-only `wants(...) -> verb` the filmed bot reads and an `apply(verb, sim)` the
balance bots call, so the film never touches the sim directly.

## A recorded replay goes stale the moment a control moves

**A recorded replay films nobody once the control it targets moves**, and nothing reports it: the
film runs to the end, the sheet gets produced, and it looks like a calm boat. Stillwater's
`first-cast.json` was recorded when touching the water cast the rod; once casting moved to a
button, the replay's touches on the water did nothing, the rod never moved for 36 tiles, and the
caption still read "Cast" throughout. A policy film of the same moment (`policy=<name>`) cast
correctly, because a policy adapts and a recording cannot. **Generate scenario replays from the
policy bot** (`policy=<name>,record=<file>`) rather than typing them by hand, so the file is
regenerated from the current layout rather than aimed at an old one, and treat a filmed run whose
sim state never left its starting state as a failed film, not a calm one.

## Scenarios

Named scenarios (`test/replays/*.json`) make a repro a command rather than a paragraph. Scenarios
that need the game running cross the title screen **like a player**, never through a bypass flag.

**What exists today is `idle` and almost nothing else**: template, candle-gift and wildform ship
only the `idle` stub (3 bytes, the literal `[]`), stillwater adds `first-cast` and `logbook`,
gravewell adds `first-minute`, wrecking-crew has no `test/replays` at all. The named set
(`first-minute`, `boundary`, `fail`, `shop`) is work to do in the game you are in, never something
to assume is on disk. A replay file that is `[]` films the idle game and the sheet looks like a
pass, which is the exact failure filming exists to catch.

## The build stamp is a test subject, not decoration

`scripts/stamp.ps1` rewrites `src/build_stamp.gd` (`const SHA`, `const BUILT`) from git
immediately before every export, CI runs the same script, and the committed fallback is `"dev"` /
`"unbuilt"`. So **the smoke test asserts the stamp is NOT the fallback after a build**, and a
broken stamp pipeline fails the build instead of shipping a lie to the phone - which matters
because the stamp in the pause menu is how he tells whether an update landed.

A dirty tree stamps `sha+`, excluding `build_stamp.gd` itself, because a marker that is always on
carries no information.

## Two ways the wrapper fails after doing all the work

**A wrapper must not treat the tool's own chatter as failure.** Godot writes leaked ObjectDB
instances and "resources still in use at exit" to stderr on a **normal** exit, so with
`$ErrorActionPreference = 'Stop'` a filmed run dies at the Godot call *after* writing every frame
and before tiling one. It reads as "filming is broken" rather than "the wrapper mishandled a
warning", and it is every run, not an edge case.

Both halves are needed: wrap native calls in the `Native` helper (`GODOT.md`), **and** unwrap the
`ErrorRecord`s when writing the log, or the error sweep at the end greps for a string Godot never
wrote. `check.ps1`, `movie.ps1` and `device.ps1` carry both fixes now.

**Keep film output out of any directory Godot imports.** `build/` is inside the project, so
`--import` walks it and dies on the movie writer's `frame.wav`, which reads as "the check suite is
broken" when the tests are fine. `build/.gdignore` is the fix;
`techniques/build-output-and-the-package.md` has what it costs when it is missing.

## What it costs, and what it found

Measured on `godot-template` (flat-shaded, 1080 frames): the old PNG-per-frame writer cost
**187.5 s wall clock, 82.7 MB, 1084 files**; the MJPEG writer with the sheet and the mp4 built
from it in one ffmpeg pass cost **106.2 s, 52.7 MB, 4 files** - about **6 s of wall clock and 3 MB
per second of film at 60 fps** (M; `movie.ps1` prints its own cost line every run, read that
rather than this number). Timed apart: render 86.7 s, sheet and video together 18.9 s. The sheet
is pixel-identical tile for tile (SSIM 0.992, PSNR 42.6 dB against the old writer's sheet) and a
full-size frame pulled back out of the AVI is PSNR 44.9 dB against its source PNG, build stamp
still crisp, so `mjpeg_quality` was left alone. `-Png` costs 2.3x the wall clock and 1.6x the disk
for the one case that needs it.

A real textured 3D game costs more: Snowball (Forward Mobile, HDRI sky, glb kits, a 288x7740
SubViewport trail) measured **6.6 s and 6.6 MB per filmed second** with the MJPEG writer - 5.8x
faster and about 2.2x the template's disk figure, both still far under the old PNG-per-frame
script's **38 s per filmed second on the same game** (2,063 of those seconds were PNG encoding at
573 ms/frame). Film the shortest run that shows the thing.

**The frame count comes from the file, not from whether one exists.** The old `$pngs.Count -lt 2`
guard could not tell a run that stopped a second in from a short film on purpose; an ffprobe frame
count that refuses anything under 90 per cent of the frames asked for can, and reads the header
first (0.3 s) rather than decoding (10.8 s) unless the header is absent, which is exactly what a
crashed writer leaves behind. Verified by pointing `run/main_scene` at a scene that does not
exist: 0 of 300 frames, the top of `godot.log` printed, no sheet.

**A game that pauses on focus loss must skip that while `OS.has_feature("movie")` is true**, and
print a line when focus-out fires so `godot.log` says whether it happened. The desktop can take
the Godot window's focus during an 80+ second render on a PC running several sessions at once, and
a paused game films a sheet that looks like a pass - every frame is valid - until someone reads
it: one Snowball run showed tiles 6 to 23 of a 12-second sheet as the Paused shell, not reproduced
on a second run, so the cause is inferred from the sheet rather than proven.

What the first filmed runs found that no screenshot had: an intro that cut to a new planet on
every caption, a wordmark running off a 375 px screen, a title rendering over the intro, and a
scenario that was wrong rather than the game. Candle Gift's first filmed run, in its fifth round
of work, failed with nothing wrong with the game at all - **the first time a tool is used in a
repo is a test of the tool, not of the repo.**

## The six questions: judging feel from a filmed run

Moved here from `TESTING.md` at the 2026-09-12 digest, which needed the room. `POLISH.md` gates
on these answers being written down.

Look at the sheet and answer, in writing, in `NOTES.md` under a dated heading:

1. Does every player action produce visible, audible and physical feedback in the same
   frame? (Check the frame after each recorded tap.)
2. Does the avatar reach speed within a fifth of a second and coast, or does it snap and
   stop dead?
3. Is anything popping in, sweeping through the middle of the frame, or drawn over
   something it should be behind?
4. Are the short states (a hook window, an impact, a transition, a reward screen) visible
   in at least one frame? If not, film a scenario that reaches them.
5. Is the first sixty seconds a win, and is the next goal visible?
6. Is there a frame where the player would not know what to do?

Then fix, film again, and compare sheet to sheet. Two sheets a week apart are comparable
because cell *n* is the same moment every time.
