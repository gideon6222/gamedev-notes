# TESTING.md - proving a game works, and finding out how it feels

Two different jobs. Suites prove the logic and hold it still while everything else changes;
play-testing finds out whether the game is any good, which no assertion can. Both are required
before anything is called finished. Edited only by `/digest`.

## The layers, and what each one catches

| Layer | Runs | Catches | Cannot catch |
|---|---|---|---|
| **Pure tests + golden** (`test/run_tests.gd`) | headless, ~1 s | balance, content, curves, a changed constant | a wiring bug: the frame loop missing, a flush forgotten |
| **Design tests** (`test/test_tuning.gd`) | headless | intent: "a hazard breaks faster than the rock around it", "every species is reachable", "the reckless option never works" | anything about the picture |
| **Smoke** (`test/run_smoke.gd`) | headless, boots the real scene | a scene that fails to build, a node never added, a render path never flushed, a button that does not work, a level boundary that freezes | layout on a tall phone, colour, feel |
| **Visual guard** (`test/run_visual.gd`) | needs a GPU, local only; **candle-gift only** - `check.ps1` runs it `if (Test-Path)`, and no other repo has one | the whole picture going wrong at once: everything black, nothing drawn, a solid silhouette | geometry, which belongs in the model |
| **Filmed run** (`scripts/movie.ps1`) | needs a GPU, deterministic | motion, pop-in, transitions, a slide show where an animation should be, the short states | whether it is fun |
| **The phone** (`scripts/device.ps1`) | real device | touch, safe area, frame time, thermal, the back button, sleep and resume | nothing, but it is the slowest |
| **Gideon** | | whether it is fun | |

**A screenshot proves one state, never the absence of a bug in the states it did not
reach.** Three HUD faults shipped behind one good-looking picture.

## Rules for the suites

- **Golden over a whole run, with policies.** `test/policies.gd` is the definition of "playing
  well" and lives in the repo. Every policy fails for a different reason, and the pair that proves
  a decision exists differs in exactly one thing. A test helper that plays the game is a second,
  worse player.
- **A perfect bot proves nothing about difficulty.** The human bot has reaction time (~0.3 s),
  misreads a tell about one time in six, wobbles, and has memory. Tune the game so the human bot
  struggles, never the bot so the game looks hard; when a bot loses to a dumber bot, sweep the
  bot's free parameter before touching a game constant. `techniques/human-bot-policies.md`.
- **A policy that sets the value the control would set is not a test of the control**, so a
  suite made entirely of policies tests only the simulation - which is how a game ships inverted,
  five times now. Wildform's golden over five policies, 86 tests, 4,800 assertions, smoke, filmed
  sheets and phone-aspect screenshots all missed it: every policy called `steer_to(world_x)`,
  correct on both sides of the bug. **Every game gets one test that drives a real
  `InputEventScreenDrag` through the real handler and asserts where the avatar ends up ON
  SCREEN**: `main._cam.transform.basis.x.x > 0.5` is the NDC claim as arithmetic, no GPU, no
  tree, no frame, and read **-1.00** before the fix. For a facing, assert the ART's forward and
  NORMALISE it - a basis carries the model's scale, and the dot read 0.19 for a creature facing
  perfectly forwards. `test/test_controls.gd` in the template.
- **A fixture where every policy succeeds measures nothing.** Four policies on a bought-out
  ladder dealt byte-identical damage to eight decimals, because every one kills an 864 HP boss and
  every run ends at the boss's health. Check the losers actually lose before trusting a
  comparison, and give a policy **the loadout its player would really have there**, from the
  progression probe: over-equipping flattens the field, under-equipping fails everything, and both
  read as "no difference". Re-measured that way: 254.8 / 249.3 / 214.5 / 208.0 over twelve seeds
  (M). Never compare on ONE seed, and assert the ORDER of the field, not a single gap.
- **Measure a claim in the part of the game the claim is about**, per item, across five or
  six seeds. A harness that can only start from the beginning tests five tutorial fish.
- **A construct that cannot fail is untested, not safe**: a modulo, a `|| fallback`, a clamp, a
  fixture where every value is convenient, a safety test aimed at a case that cannot trigger. Add
  the awkward fixture, make fixtures assert their own preconditions, and say why. The companion:
  **a construct that fails only for SOME inputs needs those inputs enumerated, not sampled once**
  - Gravewell's destroyed-cell gap is entered or missed on `hp / hardness` against the remaining
  fill, so one bite size passes for the same reason one seed does, and the test that catches it
  cuts every cell with eight bite sizes across two classes and five depths and asserts the
  property directly: a passable cell has always broken, and reports no material.
- **Assert the property the message states, not a literal.** "bays equals upgrade count",
  not "bays equals 7".
- **A test that re-derives the rule it is testing passes with the rule deleted.** A room
  placer's test walked the same slots, applied the same drop condition and asserted no overlaps:
  it checks the copy matches, never that the world is right. Make the decision REPORTABLE and
  assert the OUTPUT - export the placement, then assert every room on it is stamped cell-for-cell
  and no two overlap. The trap repeats one level down: "was this room placed", answered by whether
  its centre cell is stamped, is also true of a room that was dropped. The smell is a test
  containing a copy of a condition from the source; the question is whether it could pass with
  the feature absent, as long as both sides agree it is absent.
- **Test intent as well as values.** A deeper ore is rarer than the one above it. The
  cooling mineral lives below the heat line. These have caught design mistakes before a
  human saw them.
- **Constants that share a formula move together.** Put the test on the derived quantity
  the player feels, and grep every formula a constant appears in before changing it.
- **Every "there is always a way out" test drives the input handler's seam**, not the
  method. A way out the handler never calls is a missing feature with full coverage.
- **Test the random source itself** (range, distribution) and that each mechanic occurs in
  an actual run. A condition that can never be true fails as absence.
- **A sampling test for rare content passes when the rare thing simply misses**, so the rarer
  the content the weaker the test gets - backwards, since that is where a generation bug hides
  longest. "The first world does not contain solmarrow" survived moving the ore's floor from
  372 m to 20 m: 0.12% of 494 eligible cells is 0.6 expected. **Test the invariant, not the
  sample** - "no cell above a material's floor ever holds it" cannot be satisfied by luck - and
  split the guard by what it can see, the invariant to the generator and the floor VALUES to a
  golden of the table. If you must sample, assert on a lot of it and on a RATE.
- **Test a scrolling list at a size where it must scroll** (seven rows fit on a phone, so at
  real size the test exercised nothing), a moving obstacle at every phase, a priority in the case
  where the priorities disagree.
- **A test cannot SET derived state; drive the input the derivation reads.** Assigning a value
  that `_sync_*` recomputes on the next line measures the unchanged one and reports it as a number
  - "the sky over the quarry is the same as over the reeds, 0.01 against 0.01" - indistinguishable
  from the feature not existing, and it nearly cost a re-plumb of a correct shader. Setting the
  inputs tests the derivation for free. Where the input has no scenario, **assert the
  RELATIONSHIP instead**: Stillwater's boat never moves in world space, so "the foam follows the
  boat" tested something the game does not do, while "the collar sits AHEAD of the origin along
  her own axis" catches the mistake genuinely available there (node forward is -Z). **The tell is
  two identical numbers** when you have just set one of them yourself.
- **A test must not depend on what the case before it left on disk.** Reset the file AND the
  value the object loaded from it.
- **Verify a regression test by reintroducing the bug** - but that proves nothing if the check
  is never REACHED, and one session "verified" a guard that had been silently skipped, so the
  verification step was fooled too. Read the assertion count alongside it. Never re-record a
  golden without reading the diff; a recorder that rewrites the file itself and refuses a broken
  bracket count is cheaper than the two hand-edits that broke it.
- **Suspect any fix you cannot make fail.** If reintroducing the bug does not fail the test,
  the test is measuring a confounder: remove the confounder's freedom, do not tighten the
  threshold. Stillwater's line-sag test passed with sag hard-wired to ignore tension, because
  tension also bends the rod and the rod moved the whole line - call the function under test with
  fixed inputs rather than setting a value and stepping a frame, since stepping a frame runs every
  confounder you are trying to exclude. And if deleting a fix changes nothing observable, either
  the test is wrong or the fix is; a test written AFTER a hand-tuned fix can be measuring the
  tuning rather than the fix.
- **A test can measure the wrong END of the right object**: a plausible number that moves when
  the game changes and is never the number in question. Name the end at risk in the assertion's
  own words ("the LAST candle, not the leader") before you write it.
- **A sentinel value used inside a max or min must stay ordered**, and a "never" sentinel is
  parked at the end of the axis it lives on, asserted. A flat "way off" constant makes a search
  for the worst case return the FIRST case: Candle Gift returned a flat 9.0 for every point
  behind the lens, they compared equal, `if f > worst` kept the nearest, and the camera framed
  against a candle metres in front of the one hanging off the edge - it held to level six and
  broke at level ten, where `9.0 + local.z` keeps the ordering true. Gravewell parked "no water"
  at -1e6 and, depth growing downward, that is above the whole planet: every class rendered as
  submerged.
- **Print the state before theorising about it.** Three rounds of plausible causes all fitted
  the screen and none was true; one print of the cells around the stuck ship showed
  `mat=2 fill=0.00` and ended it.
- **Write a table's balance property as an assertion in the same commit as the table**
  (`CRAFT.md`): the cheapest test in the repo, and the one most likely to fire on its first run
  against a table its author has just proofread.
- **A tool that cannot report failure reports absence instead, and absence is the answer we act
  on.** Any scraper, filter, search or allow-list whose empty result would be believed needs a
  positive control: one query whose answer you have actually CHECKED is non-empty, run before the
  miss is written down ("obviously Kenney has UI assets" is a plausible control testing a URL that
  lists nothing). **Loud failure is not enough**: `assets.py` printed `HTTP 404` above its empty
  table and the scout still wrote down "KayKit has zero creature repos", because a reader of a
  search looks for ROWS and an error line and a genuine zero both present as none. Check the exit
  status before recording a miss, re-run the query yourself before the conclusion goes into a
  plan, and in your own tool put the failure on the LAST line and exit non-zero. Better: make the
  tool tell the two apart - zero rows after filtering is an answer, zero rows before it is a
  broken scraper.
- **An allow-list clause is where a vacuous guard hides**, because it is the clause that makes
  the test pass: Coreward's no-`Math.random` guard allowed the roll whenever the preceding text
  ended in `=`, meant to permit an injectable default and also permitting the bug. Falsify each
  clause separately, not the test as a whole.
- **A branch reachable only through a failure needs its failure path exercised once**, or it is
  untested in exactly the case it exists for. `new-game.ps1` probed "does this repo exist" with a
  command *meant* to fail on a new game, and died there.
- **Version is one fact in five places and no code derives any of them**: `Changelog.VERSION`,
  `RELEASES[0].version`, and `version/name` **and `version/code`** in every export preset. The
  template's `test/test_version.gd` asserts all five out of `export_presets.cfg` as a pure test
  and is the copy to take: the sibling games' versions collect only `version/name=`, which is why
  four of five repos sat on `version/code=1` after a dozen releases each, and Play rejects any
  upload whose code is not higher than the last. Tie the code to `RELEASES.size()`. The AAB
  preset's copies are the dangerous ones - nobody sees them until an upload is rejected.
- **Wait on game state, never wall-clock time, and on THAT state rather than a proxy for it.**
  Anything that accumulates over game time runs through the headless seam (`freeze()` then
  `advance(seconds)`), where sixty game seconds is sixty game seconds on every machine; hold a
  real control only in the tests whose subject IS the wiring. A depth is a proxy for having
  drilled and the fuel gauge moving IS having drilled - a proxy can be retuned out from under the
  test and is reached at a different rate on a slower machine, and Coreward's "until 10 m" passed
  on the desk and failed on a GPU-less CI runner that got seven metres in the same window.
- **A tool that drives the real code is a fuzzer whether or not you meant it to be.** When a
  probe or harness throws, the first question is "can the game reach this state", never "how do I
  get my tool past it" - and the tell is a fix in the tool that was a GUARD rather than a
  correction, since a guard says "this input is possible and I am handling it", which is a
  statement about the code under test. Coreward guarded a probe against an unsellable hold item
  and the same crash arrived hours later from his phone, on a black screen, every frame.
- **A milestone that puts a screen in front of the game blinds every harness written before
  it.** The title returns before the game ticks, on purpose, so `freeze()` + `advance()` advanced
  nothing and captured the menu: exit 0, no error, a photograph of the title filed as evidence
  about tunnel lighting. Fix every entry point in the same commit and make the one way in a
  METHOD the real button also calls, or half the scripts reach into a private and half forget.
  The same fault one level down: **a look-pass fixture that positions the camera by playing the
  game can fail to position the camera** - Coreward's "the building is missing" screenshot had
  flown the ship across the world and never brought it back. Assert the subject is in frame
  before judging the photograph.
- **Enforce a FLOOR on the assertion count; reading it is not enough.** A runtime error inside a
  check is non-fatal in GDScript: the function stops there, everything below it never runs, and
  the harness prints "all passing" with a smaller number nobody reads. A renamed property read off
  an untyped `main` took a smoke suite 402 -> 387 and deleted "the gauge is actually on screen",
  which exists because its absence once shipped; an invented method name aborted a test body while
  the pure suite said "107 tests, 10877 assertions, all passing". `const MIN_ASSERTIONS` that
  fails the run is ten lines and is a canary, not a target - it cannot say which assertions
  vanished, only that some did, and the cause is always the same shape. The template's
  `run_tests.gd` and `run_smoke.gd` carry one, plus a nag when the count drifts far above it so
  the floor cannot rot. Grep for `SCRIPT ERROR` as well as for failures: Godot writes those to
  stderr. `int(null)` throws and an unset shader uniform reads back as null, so set every uniform
  a test reads.
- **Verify the artefact, not the exit code of the tool that made it**, in the same script that
  makes it so the check cannot be skipped: dimensions, size against a known-good baseline, and a
  variance measure that tells an image from a flat fill. A converter has returned 0 having
  written a 342-byte solid colour. `ASSETS.md` owns the recipe and the baselines.
- **Anything that measures layout runs after the element is visible.** A `display:none` subtree
  measures zero on every axis, so a "nothing is laid out yet" fallback fires on every call and
  quietly becomes the implementation - Coreward's camera-framing fix shipped, looked right, and
  had never once run. A guard that fires every time is not a guard.
- **Isolate a shader term by REPLACING it, not by reading it**, and keep the `debug_term`
  uniform with one branch per term permanently rather than adding it each time: two frames
  answered in one pass what reading the code had not, twice. (`GODOT.md` has the rendering side.)
- **A hanging suite is a parse error until proven otherwise, and `head` is the first command,
  not `grep FAIL`**, which hides the whole class of fault that produces no `FAIL`. **A harness
  must refuse to run against a stub**: one line after instantiating the scene, assert it has the
  method the suite is about to call and quit non-zero naming the script. `GODOT.md` has why.
- **A helper that advances game time stops the clock and does not hand it back.** The stop is
  deliberate, so do not "fix" `advance` to restart it - the caller knows whether it wants real
  time. One helper calling `advance(3)` to settle an animation froze the rest of the spec, with
  every readout healthy (in play, key held, undocked) while nothing moved, which reads as a
  physics or input bug and is neither. **Put the warning where the mistake is made**: on
  `advance`, which people call, not on `startClock`, which people forget to call.
- **Assert the SPAN of what a periodic job recorded, not that it recorded anything.** Work added
  BESIDE the branch that resets a countdown, guarded on the same `<= 0`, runs once ever - the
  timer is reset in the frame it expires, so periodic work belongs INSIDE the branch that resets
  it and a second `if` on the same variable tests it at a different point in its cycle. One sample
  satisfies "did anything get recorded", and a map that recorded one row looks exactly like a map
  you have not explored. Assert `hi - lo` against the distance travelled: putting the bug back
  reported `rows 0..0`, which named it in the failure message.
- **Project by hand rather than calling `unproject_position`, and it is better, not merely
  equivalent.** Headless there is no viewport and `global_transform` is IDENTITY, so a guard
  written for CI either throws (suite prints "all passing", check never ran) or reports every
  point BEHIND the camera. Multiply local transforms up the parent chain and project with
  `tan(fov/2)` against the PHONE's aspect (`keep_aspect` is KEEP_HEIGHT, so `fov` is vertical):
  that tests the aspect the player has, not whatever window a desktop run opened, and it runs in
  CI. Verified against the windowed probe, -1.25/-0.91 by hand against -1.20/-0.85 rendered.
- **When an input seam changes, grep the tests for the OLD seam before changing anything else.**
  A `tap()` that became a documented no-op kept every caller passing while applying no input at
  all, and passed until the escape margin widened - which is when anyone learned it had stopped
  testing. A no-op that keeps its name is worse than a deleted one, which fails loudly; if a
  stand-in must survive, have it increment a counter the tests can assert on.
- **A guard whose input is a build artifact has to own the build, or refuse a stale one.** A new
  room took an APK from 35.62 MB to **64.58 MB**, 81% past a 10% tolerance, while `check.ps1`
  printed `size ok` throughout: it runs the guard only `if` an APK exists in `build/`, and
  measured one from an earlier session, before any of the new assets existed. CI exported first
  and caught it. Compare the artifact's mtime against the newest source file and say "no APK
  newer than your changes" rather than OK - the template's `check_size.gd` now does. **A green
  local check is not a green build** wherever a local step can silently measure the wrong thing.
- **A poll timeout must be shorter than the test timeout**, or the failure reads "timeout"
  instead of naming the value.
- **Assert on the reading the player sees, not on how the view draws it.** A restyle broke
  three assertions that read `style.width`.
- **Any list of things to run that is maintained by hand fails silently in the safe-looking
  direction.** Point runners at a glob, and **fail on an empty glob** - zero suites and a green
  exit are indistinguishable from outside. A sibling game added nine `test_*.gd` files, not to the
  runner's array, and reported "65 passing" for a suite that had never run. The template's
  `test/run_tests.gd` is now the glob with the empty-glob failure and the assertion floor, and the
  template is the copy that matters: a game inherits its runner once, at scaffold, and nothing
  propagates backwards.
- **Assert saturation, not a hand-derived ceiling**, for physical stability.

## Pixels versus the model

The arithmetic, the four instances and the three versions of one check are in
`techniques/pixel-and-model-assertions.md`. The rules:

- **Test the *picture* with pixels and the *placement* with the model.** The model is exact,
  needs no GPU and names the object; frame statistics are for everything going wrong at once.
- **Measure BOUNDS, not origins, and demand a margin rather than a boundary.** Project all eight
  corners of the bounding box; a label's origin is nowhere near its edges, and `x > 0` passes for
  a plate flush with the screen edge.
- **A measurement taken over a WHOLE picture can be satisfied by the wrong part of it.** When a
  pixel assertion passes with the feature deleted, the fix is never a bigger threshold, it is a
  narrower question: a named position, a control sample, or a statistic a handful of pixels cannot
  move. Take the MEDIAN, never the brightest.
- **Screen position near the lens is violently non-linear**, so sweep a near-camera mount as
  measured numbers, never by eye.
- A pixel check is worth running only if it was measured first, broken on purpose once, has a
  `--report` mode, sweeps the level rather than a handful of moments, and stays LOCAL - Vulkan
  thresholds do not transfer to a GPU-less CI runner.

## Filming a run: the tool that judges motion

Every still-image tool answers "does this moment look right". Half of what a game is judged
on is movement. `scripts/movie.ps1` drives the game with Godot's Movie Maker mode, at a fixed
timestep over a seeded sim, so **a replay file produces the same frames on every run** and two
sheets a week apart are comparable cell for cell. The mechanism, the probe, the stamp and the
wrapper traps are in `techniques/filming-a-run.md`.

```powershell
# Record the scenario first if the repo does not have it - most carry only the idle stub.
godot --path . --resolution 460x996 -- record=test/replays/first-minute.json touch
scripts\movie.ps1 -Replay test/replays/first-minute.json -Seconds 20 -Fps 60 -Every 20
scripts\movie.ps1 -Seconds 10 -Name idle          # no -Replay: films the attract state
# -> build/movie/<name>/frame00000000.png ... and build/movie/<name>/sheet.png
```

- **`replay=<file>` and `record=<file>` are bare words with no leading `--`.** Godot eats a
  leading `--` even after the `--` separator (`GODOT.md`) and `replay_player.gd` matches only the
  bare form, so `--replay=` feeds no events, reports no error, and films the idle game.
- **What exists today is `idle` and almost nothing else**, and every `idle.json` in the studio is
  the 3-byte stub `[]`: stillwater adds `first-cast` and `logbook`, gravewell adds `first-minute`,
  wrecking-crew has no `test/replays` at all. The named set (`first-minute`, `boundary`, `fail`,
  `shop`) is work to do in the game you are in, never something to assume is on disk. **Record the
  scenario this milestone needs before filming it**, crossing the title screen like a player
  rather than through a bypass flag, and commit it with the milestone.
- **It must not run headless.** A real window, small and off-screen, is the whole point.
- **Replay coordinates are in the PROJECT viewport, not `-Resolution`** (measured
  `get_visible_rect()` = **1080x2338**, M), and **no headless probe can produce them** - a
  headless root reports 100x100. Either mistake lands every tap in the top-left fifth and films a
  game that looks broken rather than a coordinate that is. Do not hand-roll the probe:
  `godot --path . --resolution 460x996 --script res://scripts/rects.gd`, which is in every repo,
  walks the scene and prints each control's rect, centre, visibility and `mouse_filter`.
- **The build stamp is a test subject, not decoration.** `scripts/stamp.ps1` rewrites
  `src/build_stamp.gd` before every export and CI runs the same script, so **the smoke test
  asserts the stamp is NOT the committed `"dev"` / `"unbuilt"` fallback after a build** and a
  broken stamp pipeline fails the build instead of shipping a lie to the phone.
- **Keep film output out of any directory Godot imports.** `build/` is inside the project, so
  `--import` walks it and dies on the movie writer's `frame.wav`, reading as "the check suite is
  broken" when the tests are fine. `build/.gdignore` is the fix; `GODOT.md` has the rest.
- **Budget about 150 MB and twenty seconds of wall clock per second of film** (M): sixteen
  seconds is 960 full-resolution PNGs and 2.4 GB. Film the shortest run that shows the thing.
- **Collect console errors and print them with the sheet**: three separate bugs sat in the
  console while they were hunted somewhere else.
- **A wrapper must not treat the tool's own chatter as failure.** Godot writes leaked ObjectDB
  instances and "resources still in use at exit" to stderr on a NORMAL exit, so with
  `$ErrorActionPreference = 'Stop'` a filmed run dies **after** writing every frame and before
  tiling one, every run. Wrap native calls in the `Native` helper in `GODOT.md` AND unwrap the
  ErrorRecords when writing the log, or the error sweep greps for a string Godot never wrote.
- **The first time a tool is used in a repo is a test of the TOOL, not of the repo.** Candle
  Gift's first filmed run in five rounds of work failed with nothing wrong with the game.
- **A fix applies to the whole family of scripts in the same commit.** A note that a fix is
  "still owed to `movie.ps1` and `device.ps1`" is a bug report filed against yourself, and the
  owed half is precisely the half that costs the next session an hour.

What the first filmed runs found that no screenshot had: an intro that cut to a new planet on
every caption, a wordmark running off a 375 px screen, a title rendering over the intro, and a
scenario that was wrong rather than the game.

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

Run `perf` at the start of a session and again after ten minutes of play: thermal throttling is
the constraint on a phone and it degrades a session while it is being played. Record the numbers
in `NOTES.md`.

**Exercise the phone-only paths every time**: the back button (`NOTIFICATION_WM_GO_BACK_REQUEST`),
home then resume (`APPLICATION_PAUSED` / `RESUMED`, the game should pause, save and duck
audio), rotation locked, safe area respected, haptics firing.

## Playtest notes and the loop with Gideon

- His words go to `playtests/<game>.md`, dated, verbatim, the moment he says them.
- Number his asks back to him. Handle every one or say why not.
- When he sends a screenshot, look at it before answering, and set up the test scene where the
  bug CAN appear - the one junction where it cannot is where four rounds were wasted.
- Send him a screenshot at the phone's aspect and the APK link with every build, and the
  changelog entry. He checks the stamp.
- Other sessions are running on this PC. A flaky suite is more likely a shared port or a
  half-written `dist/` than a bug. Every game has its own preview port and never a default.
