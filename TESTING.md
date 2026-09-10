# TESTING.md - proving a game works, and finding out how it feels

Two different jobs. Suites prove the logic and hold it still while everything else changes.
Play-testing finds out whether the game is any good, which no assertion can. Both are
required before anything is called finished. Edited only by `/digest`.

## The layers, and what each one catches

| Layer | Runs | Catches | Cannot catch |
|---|---|---|---|
| **Pure tests + golden** (`test/run_tests.gd`) | headless, ~1 s | balance, content, curves, a changed constant | a wiring bug: the frame loop missing, a flush forgotten |
| **Design tests** (`test/test_tuning.gd`) | headless | intent: "a hazard breaks faster than the rock around it", "every species is reachable", "the reckless option never works" | anything about the picture |
| **Smoke** (`test/run_smoke.gd`) | headless, boots the real scene | a scene that fails to build, a node never added, a render path never flushed, a button that does not work, a level boundary that freezes | layout on a tall phone, colour, feel |
| **Visual guard** (`test/run_visual.gd`) | needs a GPU, local only | the whole picture going wrong at once: everything black, nothing drawn, a solid silhouette | geometry, which belongs in the model |
| **Filmed run** (`scripts/movie.ps1`) | needs a GPU, deterministic | motion, pop-in, transitions, a slide show where an animation should be, the short states | whether it is fun |
| **The phone** (`scripts/device.ps1`) | real device | touch, safe area, frame time, thermal, the back button, sleep and resume | nothing, but it is the slowest |
| **Gideon** | | whether it is fun | |

**A screenshot proves one state, never the absence of a bug in the states it did not
reach.** Three HUD faults shipped behind one good-looking picture.

## Rules for the suites

- **Golden over a whole run, with policies.** `test/policies.gd` is the definition of
  "playing well" and lives in the repo. Every policy fails for a different reason, and the
  pair that proves a decision exists differs in exactly one thing. A test helper that plays
  the game is a second, worse player.
- **A perfect bot proves nothing about difficulty.** The human bot has reaction time
  (~0.3 s), misreads a tell about one time in six, has a hand that wobbles, and has memory.
  Tune the game so the human bot struggles, never the bot so the game looks hard. When a
  bot loses to a dumber bot, sweep the bot's free parameter before touching a game constant.
  `techniques/human-bot-policies.md`.
- **Measure a claim in the part of the game the claim is about**, per item, across five or
  six seeds. A harness that can only start from the beginning tests five tutorial fish.
- **A construct that cannot fail is untested, not safe**: a modulo, a `|| fallback`, a clamp,
  a fixture where every value is convenient. Add the awkward fixture and say why.
- **Assert the property the message states, not a literal.** "bays equals upgrade count",
  not "bays equals 7".
- **Test intent as well as values.** A deeper ore is rarer than the one above it. The
  cooling mineral lives below the heat line. These have caught design mistakes before a
  human saw them.
- **Constants that share a formula move together.** Put the test on the derived quantity
  the player feels, and grep every formula a constant appears in before changing it.
- **Every "there is always a way out" test drives the input handler's seam**, not the
  method. A way out the handler never calls is a missing feature with full coverage.
- **Test the random source itself** (range, distribution) and that each mechanic occurs in
  an actual run. A condition that can never be true fails as absence.
- **Test a scrolling list at a size where it must scroll**, a moving obstacle at every
  phase, a priority in the case where the priorities disagree.
- **Verify a regression test by reintroducing the bug.** Never re-record a golden without
  reading the diff. A recorder that rewrites the file itself and refuses a broken bracket
  count is cheaper than the two hand-edits that broke it.
- **If reintroducing the bug does not fail the test, the test is measuring a confounder.**
  Remove the confounder's freedom, do not tighten the threshold. Stillwater's line-sag test
  passed with sag hard-wired to ignore tension, because tension also bends the rod and the
  rod moved the whole line: call the function under test with fixed inputs rather than
  setting a value and stepping a frame, since stepping a frame runs every confounder you are
  trying to exclude. Two identical numbers in the failure message ("0.183 vs 0.183") are the
  proof it is looking at the right quantity.
- **An allow-list clause is where a vacuous guard hides**, because it is the clause that
  makes the test pass. Coreward's no-`Math.random` guard allowed the roll whenever the
  preceding text ended in `=`, which was meant to permit an injectable default and also
  permitted the bug. Falsify each clause separately, not the test as a whole.
- **A branch reachable only through a failure needs its failure path exercised once**, or it
  is untested in exactly the case it exists for. `new-game.ps1` probed "does this repo exist"
  with a command that is *meant* to fail on a new game, and died there; nobody had ever
  scaffolded a game whose repo did not already exist.
- **A tool that cannot report failure reports absence instead**, and absence is the answer we
  act on. Any scraper, filter or search whose empty result would be believed needs a positive
  control: one query whose answer is known non-empty, run before the miss is written down.
- **Version is one fact in three files and no code derives it.** Every game asserts
  `Changelog.VERSION` == `version/name` in **each** export preset == `RELEASES[0].version`,
  read out of `export_presets.cfg` as a pure test. The AAB preset's copy is the dangerous one
  because nobody sees it until a store upload.
- **Wait on game state, never wall-clock time.** Anything that accumulates over game time
  runs through the headless seam (`freeze()` then `advance(seconds)`), where sixty game
  seconds is sixty game seconds on every machine. Hold a real control only in the tests whose
  subject IS the wiring.
- **A poll timeout must be shorter than the test timeout**, or the failure reads "timeout"
  instead of naming the value.
- **Assert on the reading the player sees, not on how the view draws it.** A restyle broke
  three assertions that read `style.width`.
- **A safety test aimed at a case that cannot trigger is worse than no test.** Fixtures
  assert their own preconditions.
- **Any list of things to run that is maintained by hand fails silently in the safe-looking
  direction.** Point runners at a glob.
- **Assert saturation, not a hand-derived ceiling**, for physical stability.

## Pixels versus the model

Test the *picture* with pixels and the *placement* with the model. Two geometry bugs (a pool
rendering striped, a sign hung at eye height) burned three discarded frame metrics before
being written as numbers in the model, where they are exact, need no GPU, and the failure
names the object. What frame statistics are for is everything going wrong at once, which the
model cannot see.

For a pixel check worth running: measure first, set the threshold, break the build on
purpose and watch it fail. Give the runner a `--report` mode that prints and asserts
nothing. Sample every second or two across the whole level and judge the worst frame; a
handful of chosen moments is not a sweep. Keep it local: thresholds derived on Vulkan do not
transfer to a GPU-less CI runner, and two sets of numbers for one check is how a check stops
meaning anything.

## Filming a run: the tool that judges motion

Every still-image tool answers "does this moment look right". Half of what a game is judged
on is movement. `scripts/movie.ps1` drives the game with Godot's Movie Maker mode:

```powershell
scripts\movie.ps1 -Replay test/replays/level1.json -Seconds 20 -Fps 60 -Every 20
# -> build/movie/<name>/frame00000000.png ... and build/movie/<name>/sheet.png
```

- `--write-movie out/frame.png --fixed-fps 60 --quit-after N --resolution 460x996` renders a
  PNG per frame at a fixed timestep with the dummy audio driver. Because the timestep is
  fixed and the sim is seeded, **a replay file produces the same frames on every run**.
- `scripts/replay_player.gd` is an autoload that reads `--replay=<file>` from the user args
  and feeds recorded `InputEventScreenTouch`/`Drag` events through
  `get_viewport().push_input(ev, true)` on the recorded physics frame. Record a replay on the
  desk with `--record=<file>`, or on the phone (it writes to `user://`, pull it with adb).
- `ffmpeg` tiles every Nth frame into a contact sheet with the frame number burned in, so
  a whole level is one image Claude can read and cite by frame.
- Named scenarios (`test/replays/*.json`) make a repro a command rather than a paragraph.
  Scenarios that need the game running cross the title screen like a player, never through
  a bypass flag.
- **It must not run headless.** A real window, small and off-screen, is the whole point.
- **Write replay coordinates against the PROJECT viewport, not `-Resolution`.** Movie Maker
  renders at the project's viewport size and `-Resolution` only sizes the window; measured
  from inside a run, `get_visible_rect()` is **1080x2338** (M) on this stack, not the 460x996
  the sheet is downscaled to. A replay written at 460x996 lands every tap in the top-left
  fifth, hits nothing, and films a game that looks broken rather than a coordinate that is.
- **No headless probe can produce replay coordinates**: a headless root reports 100x100 and
  every anchored control resolves against that. Print `get_global_rect()` from inside the
  game's tick for one frame and film three seconds.
- **Keep film output out of any directory Godot imports.** `build/` is inside the project, so
  `--import` walks it, reimports every frame slowly, and dies on the movie writer's
  `frame.wav` - which reads as "the check suite is broken" when the tests are fine.
- **Budget about 150 MB and twenty seconds of wall clock per second of film** (M): sixteen
  seconds is 960 full-resolution PNGs and 2.4 GB. Film the shortest run that shows the thing.
- **Collect console errors and print them with the sheet.** Three separate bugs sat in the
  console while they were hunted somewhere else.

What the first filmed runs found that no screenshot had: an intro that cut to a new planet
on every caption (the actual slide show), a wordmark running off a 375 px screen, a title
rendering over the intro, and a scenario that was wrong rather than the game.

## Judging feel from a filmed run

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

## On the phone

`scripts/device.ps1` wraps adb from `C:\dev\toolchain\android-sdk\platform-tools`:

| Command | What it does |
|---|---|
| `install` | `adb install -r -g build/<slug>.apk` |
| `launch` | `am start -W -S -n <pkg>/com.godot.game.GodotAppLauncher` |
| `log` | `adb logcat -s godot`, which is every `print()` and error from the game |
| `shot` | `adb exec-out screencap -p > build/phone/<time>.png` (piping through PowerShell corrupts bytes; the script uses exec-out to a file) |
| `record 30` | `screenrecord --time-limit 30`, pulled and tiled into a sheet |
| `perf` | `dumpsys gfxinfo <pkg>` percentiles before and after ten seconds of play, plus `dumpsys thermalservice` |
| `tap x y`, `swipe ...`, `back`, `home` | scripted input, the back button, pause and resume |
| `pull-replay` | pulls `user://replay.json` recorded on the phone for desk playback |

Run `perf` at the start of a session and again after ten minutes of play. Thermal
throttling is the constraint on a phone and it degrades a session while it is being played.
Record the numbers in `NOTES.md`.

**Exercise the phone-only paths every time**: the back button (`NOTIFICATION_WM_GO_BACK_REQUEST`),
home then resume (`APPLICATION_PAUSED` / `RESUMED`, the game should pause, save and duck
audio), rotation locked, safe area respected, haptics firing.

## Playtest notes and the loop with Gideon

- His words go to `playtests/<game>.md`, dated, verbatim, the moment he says them.
- Number his asks back to him. Handle every one or say why not.
- When he sends a screenshot, look at it before answering, and set up the test scene where
  the bug CAN appear (the one junction where it cannot is where four rounds were wasted).
- Send him a screenshot at the phone's aspect and the APK link with every build, and the
  changelog entry. He checks the stamp.
- Other sessions are running on this PC. A flaky suite is more likely a shared port or a
  half-written `dist/` than a bug. Every game has its own preview port and never a default.
