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

`--write-movie out/frame.png --fixed-fps 60 --quit-after N --resolution 460x996` renders a PNG per
frame at a fixed timestep with the dummy audio driver. Because the timestep is fixed and the sim
is seeded, **a replay file produces the same frames on every run**, which is what makes two sheets
a week apart comparable cell for cell. `ffmpeg` then tiles every Nth frame into a contact sheet
with the frame number burned in, so tile *n* is frame *n* × `-Every` and a finding can be cited by
number.

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

**Owed, not yet paid.** candle-gift, gravewell, stillwater and wrecking-crew each grew their own
control seam under their own name, and none has the template's `drag_by`: each needs its own small
bespoke `bot_drag_pixels` and gate. Wildform has the behaviour already and should move onto the
template's shared contract so there is one shape rather than two.

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

**Budget about 150 MB and twenty seconds of wall clock per second of film** (M): sixteen seconds
is 960 full-resolution PNGs and 2.4 GB. Film the shortest run that shows the thing.

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
