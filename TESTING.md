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

- **A smoke test for a web build must assert visibility by computed style** (`toBeHidden()`,
  `toBeVisible()`, or `getComputedStyle().display`), never by the presence or absence of a class
  like `hidden` - a class is a claim and the screen is the fact. When a feature is deleted, grep
  for every CSS selector it carried and check who else still sets that class before removing the
  rule.

- **Golden over a whole run, with policies.** `test/policies.gd` is the definition of "playing
  well" and lives in the repo. Every policy fails for a different reason, and the pair that proves
  a decision exists differs in exactly one thing. A test helper that plays the game is a second,
  worse player.
- **A test that steps a system once proves the step, never the sequence.** Anything with feedback
  in it - a meter that costs you the means to refill it, an economy priced off its own output,
  difficulty that scales with progress - needs a probe that runs the loop dozens of times, asserting
  *does it still have a way forward*. Coreward's collapse probe: `techniques/testing-assertion-traps.md`.
- **A policy must obey the rules the game itself teaches.** A bad player is a useful probe; an
  incoherent one is noise whose numbers look exactly like balance faults. The same probe was
  useless twice first: it ignored the danger warning the game shouts and banked nothing for eight
  runs (given "turn back on danger" the same build climbed), and it held the d-pad for
  `|dx| * 2 + 4` seconds to move `dx` columns, eighteen cells of overshoot at three cells a second.
  **Drive movement to a CONDITION, never for a duration.**
- **A perfect bot proves nothing about difficulty.** The human bot has reaction time (~0.3 s),
  misreads a tell about one time in six, wobbles, and has memory. Tune the game so the human bot
  struggles, never the bot so the game looks hard; when a bot loses to a dumber bot, sweep the
  bot's free parameter before touching a game constant. `techniques/human-bot-policies.md`.
- **A policy that sets the value the control would set is not a test of the control**, so a suite
  made entirely of policies tests only the simulation - which is how a game ships inverted, five
  times now. Wildform's golden over five policies, 86 tests, 4,800 assertions, smoke, filmed sheets
  and phone-aspect screenshots all missed it: every policy called `steer_to(world_x)`, correct on
  both sides of the bug. **Every game gets one test that drives a real `InputEventScreenDrag`
  through the real handler and asserts where the avatar ends up ON SCREEN**, plus the camera's own
  right vector as arithmetic (`basis.x.x > 0.5`, which read -1.00 before the fix) - no GPU, no tree,
  no frame. For a facing, assert the ART's forward and NORMALIZE it: a basis carries the model's
  scale. `test/test_controls.gd` in the template.
- **And every game gets one FILMED scenario driven by a policy through the real input handler.**
  The assertion above catches an inverted axis at one instant; this catches everything wrong over
  a minute of play. First run on wildform: the evolution transform covered the whole screen for
  5.08 s, three times, a fifth of the run unreadable, while all 4,800 assertions passed - every
  one drove the sim and none drove the picture. A recorded touch replay does not replace it: it
  goes stale the moment the layout moves, so re-record one FROM the policy bot
  (`policy=<name>,record=<file>`) rather than by hand, and treat a filmed run whose sim state
  never left its starting state as a failed film, not a calm one. The `bot_drag_pixels` /
  `bot_touch_pixels` contract, the pixel conversion and the thumb-speed clamp live in
  `godot-template` with their own test gate: mechanism in `techniques/filming-a-run.md`. Wildform
  and Stillwater have their seam; candle-gift, gravewell and wrecking-crew still owe theirs.
- **A fixture where every policy succeeds measures nothing.** Four policies on a bought-out ladder
  dealt byte-identical damage to eight decimals, because every run ends at the boss's health. Give
  a policy the loadout its player would really have (over-equipping flattens the field,
  under-equipping fails everything), never compare on ONE seed, and assert the ORDER of the field,
  not a gap. Numbers and the fix: `techniques/human-bot-policies.md`.
- **A bound is only as good as the count it is measured over, so raise the sample rather than
  loosen the bound.** Candle Gift's probability-constant check over 200 hashed chunks expected
  seven hits at a 0.035 tier and drew two; widening the band to pass would have accepted a broken
  hash five to fifteen times over for every other constant, while 2000 chunks makes the expected
  value 70 and the bound meaningful for all of them, at no real cost - **a bigger sample in a pure
  test is almost always free.** And **state a bound against its own input, never as a hand-derived
  literal**: halving `CASH_CHANCE` 0.50 to 0.26 failed with "money can never spawn", a correct
  change reported as a breakage.
- **Measure a claim in the part of the game the claim is about**, per item, across five or
  six seeds. A harness that can only start from the beginning tests five tutorial fish.
- **A construct that cannot fail is untested, not safe**: a modulo, a `|| fallback`, a clamp, a
  fixture where every value is convenient. Add the awkward fixture, make fixtures assert their own
  preconditions, and say why. The companion: **a construct that fails only for SOME inputs needs
  those inputs enumerated, not sampled once** - Gravewell's destroyed-cell gap is entered or missed
  on `hp / hardness` against the remaining fill, so one bite size passes for the same reason one
  seed does; the test that catches it cuts every cell across two classes and five depths and
  asserts the property directly: a passable cell has always broken.
- **A precondition a test states in a COMMENT will fail as the thing it was testing**, and **a
  failure message must be able to be wrong** - where a test can tell "the subject is broken" from
  "the fixture is broken" it says which, and the fixture check goes FIRST. This studio shipped
  inverted controls six times behind a confident wrong message. `techniques/testing-assertion-traps.md`.
- **Two assertion shapes that can never fail, both the natural way to write it.** For "fires
  once", COUNT the emissions and advance the clock between calls: comparing `finished_at` across
  two back-to-back calls passed with the `if finished: return` latch deleted, because the re-stamp
  wrote the identical value with no simulated time passed. For "sets up a state", assert on state
  the call is the only thing that could have produced, and check the fixture is NOT already in it -
  `launch_final()` asserting `phase == DESCENT` passed with `redescend()` deleted, the phase having
  been DESCENT already. Both invisible to the assertion floor: 195 tests and 24,441 assertions with
  the faults in as without.
- **Assert the property the message states, not a literal.** "bays equals upgrade count",
  not "bays equals 7".
- **Write a phase check as a partition over whatever the UI actually holds, not as a list of the
  controls you remember.** A remembered-list check named every control it knew about and so could
  not fail when a new one was left out, and stayed green through a whole release with that control
  drawn wrong on every screen. Walk the UI root's children, flip the phase, fail on anything drawn
  in both that is not on a deliberately short allow-list, and check the other direction too: drawn
  in NEITHER phase is dead weight. `techniques/testing-assertion-traps.md`.
- **Give every node a `name` at construction**, or it is `@Label@56` in every error and inspector
  tree exactly when it matters most: while reading a failing check.
- **A test that re-derives the rule it is testing passes with the rule deleted.** The smell is a
  test containing a copy of a condition from the source; the question is whether it could pass with
  the feature absent, both sides agreeing it is. Make the decision REPORTABLE and assert the
  OUTPUT. `techniques/testing-assertion-traps.md`.
- **Test intent as well as values**: a deeper ore is rarer than the one above it, the cooling
  mineral lives below the heat line. These have caught design mistakes before a human saw them.
- **Constants that share a formula move together.** Put the test on the derived quantity the player
  feels, and grep every formula a constant appears in before changing it.
- **Every "there is always a way out" test drives the input handler's seam**, not the
  method. A way out the handler never calls is a missing feature with full coverage.
- **A smoke test must reach the simulation only through a control the player can press** - emit
  the button's own signal or the touch layer's, never call the `Sim` method the button is supposed
  to call. Gravewell shipped a build where nothing wired a finished descent back to play: the
  check named "a finished descent can be left" called `main.sim.redescend()` directly and passed
  green through 204 tests over 22 suites while the shop, the upgrade ladder and every secret sat
  unreachable behind a button with nothing listening. Calling the method is a unit test with a
  scene attached; the wiring between them is the entire thing the layer exists to catch.
- **Test the random source itself** (range, distribution) and that each mechanic occurs in
  an actual run. A condition that can never be true fails as absence.
- **A sampling test for rare content passes when the rare thing simply misses**, so the rarer the
  content the weaker the test gets - backwards, since that is where a generation bug hides longest.
  **Test the invariant, not the sample.** `techniques/testing-assertion-traps.md`.
- **Test a scrolling list at a size where it must scroll** (seven rows fit on a phone, so the test
  exercised nothing at real size), a moving obstacle at every phase, a priority where priorities
  disagree.
- **A test cannot SET derived state; drive the input the derivation reads.** Assigning a value
  that `_sync_*` recomputes on the next line measures the unchanged one - "the sky over the quarry
  is the same as over the reeds, 0.01 against 0.01" - indistinguishable from the feature not
  existing. Where the input has no scenario, **assert the RELATIONSHIP instead**: Stillwater's
  boat never moves in world space, so "the collar sits AHEAD of the origin along her own axis"
  catches the real mistake (node forward is -Z) where "the foam follows the boat" cannot. **The
  tell is two identical numbers** when you set one of them yourself.
- **A test must not depend on what the case before it left on disk.** Reset the file AND the
  value the object loaded from it.
- **Every headless harness and screenshot tool that boots the real shell points the save AND the
  settings at their own paths before booting, and erases them after** - a save written by a bot
  into the player's file is a corrupted save the player finds later. Make the path a static the
  file wrapper reads (`SimSave.path`, `Settings.path`), not a hard constant, so a smoke test or
  screenshot script can point it at `user://smoke-progress.json` and clean up.
- **Verify every regression test by reintroducing the bug, and suspect any fix you cannot make
  fail.** That proves nothing if the check is never REACHED, so read the assertion count alongside
  it. If the bug goes back in and the test still passes, the test is measuring a confounder: remove
  the confounder's freedom, never tighten the threshold, and **call the function under test with
  fixed inputs** rather than setting a value and stepping a frame. Stillwater's line-sag story and
  the rest: `techniques/testing-assertion-traps.md`. Never re-record a golden without reading the
  diff.
- **Read a re-recorded golden's diff as a count per id, and refuse any re-record where an id
  LEAVES the world that the change could only have added.** An ES-module import cycle between sim
  modules evaluates a constant as undefined with no error, and the first observable sign is a room
  or object missing from the generated world - Coreward's re-record read `- vaultwall 6, -
  vaultcore 6` under a change that should only ever add crates, which was the whole diagnosis.
- **A test can measure the wrong END of the right object** - a plausible number that moves when
  the game changes and is never the number in question. Name the end at risk in the assertion's
  own words ("the LAST candle, not the leader") before you write it (`CRAFT.md` has the camera
  side).
- **A sentinel value used inside a max or min must stay ordered**, and a "never" sentinel is
  parked at the end of the axis it lives on, asserted. A flat "way off" constant makes a search
  for the worst case return the FIRST case: Candle Gift's flat 9.0 for every point behind the lens
  compared equal under `if f > worst`, so the nearest kept winning and the camera framed a candle
  meters in front of the one hanging off the edge, until `9.0 + local.z` kept the ordering true.
  Gravewell parked "no water" at -1e6 which, depth growing downward, is above the whole planet:
  every class rendered as submerged.
- **Print the state before theorizing about it.** Three rounds of plausible causes all fitted the
  screen and none was true; one print of the cells around the stuck ship showed `mat=2 fill=0.00`
  and ended it.
- **Write a table's balance property as an assertion in the same commit as the table**
  (`CRAFT.md`): the cheapest test in the repo, and the one most likely to fire on its first run
  against a table its author has just proofread.
- **A tool that cannot report failure reports absence instead, and absence is the answer we act
  on.** Any scraper, filter, search or allow-list whose empty result would be believed needs a
  positive control: one query whose answer you have CHECKED is non-empty, run before the miss is
  written down. `assets.py` printed `HTTP 404` above its empty table and the scout still wrote
  "KayKit has zero creature repos" (`ASSETS.md`). `techniques/testing-assertion-traps.md`.
- **An allow-list clause is where a vacuous guard hides**, because it is the clause that makes
  the test pass. Falsify each clause separately, not the test as a whole.
  `techniques/testing-assertion-traps.md`.
- **A branch reachable only through a failure needs its failure path exercised once**, or it is
  untested in exactly the case it exists for - `new-game.ps1` probed "does this repo exist" with a
  command *meant* to fail, and died there.
- **Version is one fact in five places and no code derives any of them**: `Changelog.VERSION`,
  `RELEASES[0].version`, and `version/name` **and `version/code`** in every export preset.
  `test/test_version.gd` asserts all five out of `export_presets.cfg`; four of five repos sat on
  `version/code=1` after a dozen releases because their check collected only `version/name=`, and
  Play rejects any upload whose code is not higher than the last. Tie the code to
  `RELEASES.size()`; the AAB preset's copies are the dangerous ones.
- **A tool that drives the real code is a fuzzer whether or not you meant it to be.** When a
  probe or harness throws, the first question is "can the game reach this state", never "how do I
  get my tool past it" - the tell is a fix in the tool that was a GUARD rather than a correction,
  since a guard says "this input is possible and I am handling it", a statement about the code
  under test. Coreward guarded a probe against an unsellable hold item, and the same crash arrived
  hours later from his phone, on a black screen, every frame.
- **Verify the artefact, not the exit code of the tool that made it.** A converter has returned 0
  having written a 342-byte solid color. `techniques/testing-assertion-traps.md`.
- **Anything that measures layout runs after the element is visible**, or a "nothing is laid out
  yet" fallback quietly becomes the implementation. `techniques/testing-assertion-traps.md`.
- **Assert the SPAN of what a periodic job recorded, not that it recorded anything.** Work added
  BESIDE the branch that resets a countdown, guarded on the same `<= 0`, runs once ever - the timer
  resets in the frame it expires, so periodic work belongs INSIDE that branch, with a second `if`
  on the same variable testing it at a different point in its cycle. One sample satisfies "did
  anything get recorded"; a map that recorded one row looks exactly like a map you have not
  explored. Assert `hi - lo` against the distance traveled: putting the bug back reported
  `rows 0..0`, naming it in the failure message.
- **When an input seam changes, grep the tests for the OLD seam before changing anything else** -
  a no-op that keeps its old name passes every caller silently. `techniques/testing-assertion-traps.md`.
- **A guard whose input is a build artifact has to own the build, or refuse a stale one.** A shed
  of imported props took an APK from 35.62 MB to **64.58 MB**, 81% past a 10% tolerance, while
  `check.ps1` printed `size ok` throughout - it weighs whatever APK is in `build/`, which was from
  the previous export; CI exported first and caught it. Compare the artifact's mtime against the
  newest source file and refuse a stale one rather than saying OK (`check_size.gd` now does), and
  **run the check with `-Export` in any commit that adds, removes or reimports an asset**. **A
  green local check is not a green build** wherever a local step can silently measure the wrong
  thing.
- **What a green run actually ran is its own subject**: discovery, the clock and the entry point
  are shared state a test can get wrong even while every assertion passes. Mechanism, counts and
  every dead end: `techniques/the-test-harness.md`. The rules:
  - **When a check moves to run after a step that writes files, run it once against that step's
    real output in the same commit.** A placeholder-scan moved after the README/CLAUDE stubs
    failed on its own legitimate text (`built from C:\dev\godot-template`) on the very next
    scaffold, because nothing had exercised the new order before then.
  - **Point runners at a glob and FAIL on an empty glob**, and **discover through the IMPORT
    CACHE** so a bare `--script` cannot under-report the gate's count. **Print the suite LIST**,
    not only the count, and treat an untracked `.uid` beside a tracked `.gd` as the tell.
  - **Enforce a FLOOR on the assertion count**, a canary rather than a target: a runtime error
    inside a check is non-fatal in GDScript and the harness prints "all passing" with a smaller
    number nobody reads. Install an `OS.add_logger` (4.5+) that closes each test on
    `begin()`/`end()` and fails the one whose body raised an error, with the error's own text -
    grepping for `SCRIPT ERROR` after the fact is not enough. Raise a probe error from a helper
    function, never `_init` itself, or the abort hangs the run instead of failing it, and assert
    every precondition a test's assertions sit behind: an untaken `if` is a body that never ran and
    passes exactly like the abort does.
  - **Wait on game STATE, never wall-clock time**, and on that state rather than a proxy for it -
    a depth is a proxy for having drilled, the fuel gauge moving IS having drilled.
  - **A helper that advances game time stops the clock and does not hand it back**, deliberately,
    so put the warning on `advance`, which people call, not on `startClock`, which they forget.
  - **A hanging suite is a parse error until proven otherwise, and `head` is the first command, not
    `grep FAIL`**, which hides the whole class of fault that produces no `FAIL`. **A harness must
    refuse to run against a stub**: assert the scene has the method the suite is about to call and
    quit non-zero naming the script.
  - **A milestone that puts a screen in front of the game blinds every harness written before it.**
    Fix every entry point in the same commit and make the one way in a METHOD the real button also
    calls. **Assert the subject is in frame before judging a photograph.**
- **A poll timeout must be shorter than the test timeout**, or the failure reads "timeout"
  instead of naming the value.
- **Assert on the reading the player sees, not on how the view draws it.** A restyle broke
  three assertions that read `style.width`.
- **Assert saturation only where the statistic is MONOTONE and the run is long enough to reach the
  envelope**, never a ratio between two window maxima: Wrecking Crew's under-1.15 window ratio
  fails at 25% of window positions along a 20-minute trace (22% on the old spawn, M) and does not
  improve with longer windows (1.485 at 60 s, 1.305 at 120 s, 1.216 at 180 s, M), because it is an
  extreme-value statistic converging far slower than the tolerance assumed. **Slide any such test
  along a much longer run and count how often it would have passed.** And **check what a guard
  clamp does to the quantity you assert**: a value capped by `limit_length`, `clamp` or `min`
  saturates whether the system is healthy or running away (a radial correction at gain 1.6 settled
  at ~45 m/s against a correct ~44 with nothing to catch it), so a recorded ceiling PLUS the
  per-frame clamp check is the honest shape - **a replacement assertion nobody has seen fail is a
  guess.** `techniques/wrecking-crew-pendulum.md`.

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
- **Project by hand rather than calling `unproject_position`**, and it is better, not merely
  equivalent: headless there is no viewport and `global_transform` is IDENTITY, so a guard written
  for CI either throws or reports every point BEHIND the camera. Multiply local transforms up the
  parent chain and project with `tan(fov/2)` against the PHONE's aspect, which tests the aspect the
  player has and runs in CI (verified -1.25/-0.91 by hand against -1.20/-0.85 rendered, M).
- **Screen position near the lens is violently non-linear**, so sweep a near-camera mount as
  measured numbers, never by eye.
- A pixel check is worth running only if it was measured first, broken on purpose once, has a
  `--report` mode, sweeps the level rather than a handful of moments, and stays LOCAL - Vulkan
  thresholds do not transfer to a GPU-less CI runner.

## Filming a run: the tool that judges motion

Every still-image tool answers "does this moment look right". Half of what a game is judged on is
movement. `scripts/movie.ps1` drives the game with Godot's Movie Maker mode at a fixed timestep
over a seeded sim to Godot's own MJPEG writer (`--write-movie <dir>/run.avi`), building the
contact sheet and the mp4 from that one file in a single ffmpeg pass, so **a replay file produces
the same frames on every run** and two sheets a week apart are comparable cell for cell.
Mechanism, probe, stamp and every wrapper trap: `techniques/filming-a-run.md`.

```powershell
# Record the scenario first if the repo does not have it - most carry only the idle stub.
godot --path . --resolution 460x996 -- record=test/replays/first-minute.json touch
scripts\movie.ps1 -Replay test/replays/first-minute.json -Seconds 20 -Fps 60 -Every 20
scripts\movie.ps1 -Seconds 10 -Name idle          # no -Replay: films the attract state
# -> build/movie/<name>/run.avi, contact sheet and mp4 - -Png restores a PNG-per-frame sequence
```

- **`replay=` and `record=` are bare words with no leading `--`**, which Godot eats even after the
  separator, so `--replay=` feeds no events, reports no error, and films the idle game.
- **Record the scenario this milestone needs before filming it**, crossing the title like a player
  rather than through a bypass flag, and commit it with the milestone. Almost every `idle.json` in
  the studio is the 3-byte stub `[]`; the named set is work to do, never something on disk.
- **It must not run headless**, and **replay coordinates are in the PROJECT viewport, not
  `-Resolution`** (`get_visible_rect()` = 1080x2338, M) - no headless probe can produce them, a
  headless root reports 100x100, and either mistake lands every tap in the top-left fifth. Use
  `rects.gd`, which is in every repo.
- **In a screenshot or film tool with positional arguments, a new moment to photograph is a new
  MODE name, never an extra word after the mode** - an unrecognized extra word is silently taken
  as the next positional value rather than failing. **When a shot comes back looking unchanged,
  diff its pixels against the previous file before reviewing it**: a run that dies before the
  shutter leaves the old picture in place with no error.
- **Budget about 6 s of wall clock and 3 MB per second of film at 60 fps** (M, flat-shaded
  template - `movie.ps1` prints its own cost line every run, read that rather than this number). A
  real textured 3D game costs more: Snowball measured 6.6 s and 6.6 MB per filmed second (M),
  still far under the old PNG-per-frame script's 38 s per filmed second on the same game. `-Png`
  is the escape hatch for the rare case that needs a full-size frame with no JPEG in the way, at
  2.3x the wall clock and 1.6x the disk. Film the shortest run that shows the thing, keep output
  out of any directory Godot imports (`build/.gdignore`), and print the console errors with the
  sheet.
- **The frame count comes from the file, not from whether one exists**: an ffprobe count that
  refuses anything under 90 per cent of the frames asked for catches a writer that died mid-render,
  which a `$pngs.Count -lt 2` guard cannot tell from a short film on purpose.
- **A game that pauses on focus loss must skip that while `OS.has_feature("movie")` is true**, and
  print a line when focus-out fires so `godot.log` says whether it happened. The desktop can take
  the Godot window's focus mid-render on a shared PC, and the sheet of a paused game looks like a
  pass - every frame is valid - until someone reads it.
- **The build stamp is a test subject**: the smoke test asserts it is not the committed `"dev"`
  fallback after a build, so a broken stamp pipeline fails instead of shipping a lie to the phone.
- **The first time a tool is used in a repo is a test of the TOOL, not of the repo**, and a fix
  applies to the whole family of scripts in the same commit - the half left owed is precisely the
  half that costs the next session an hour.

What the first filmed runs found that no screenshot had: an intro that cut to a new planet on every
caption, a wordmark running off a 375 px screen, a title rendering over the intro, and a scenario
that was wrong rather than the game.

## Judging feel from a filmed run

Answer **the six questions** in writing, in `NOTES.md` under a dated heading: feedback in the same
frame as each action, acceleration and coasting, anything popping in or drawn over what it belongs
behind, the short states visible in at least one frame, a win and a visible next goal in the first
sixty seconds, and any frame where the player would not know what to do. Spelled out in
`techniques/filming-a-run.md`; `POLISH.md` gates on the answers. Then fix and film again.

- **A filmstrip driven by fixed-step advance misreports anything timed per drawn frame or on the
  wall clock** (fades, flashes, light-field smoothing, CSS transitions): the skipped simulation
  time is real and correct for the game, but a sheet of quarter-second frames can show a fade
  that has barely started. When a sheet shows something that should have finished, screenshot the
  same moment on the real clock before touching the game.

## On the phone

`scripts/device.ps1` wraps adb from `C:\dev\toolchain\android-sdk\platform-tools`:

| Command | What it does |
|---|---|
| `install` | `adb install -r -g build/<slug>.apk` |
| `launch` | `am start -W -S -n <pkg>/com.godot.game.GodotAppLauncher` |
| `log` | `adb logcat -s godot`, which is every `print()` and error from the game |
| `shot` | `adb exec-out screencap -p > build/phone/<time>.png` (piping through PowerShell corrupts bytes; the script uses exec-out to a file) |
| `record 30` | `screenrecord --time-limit 30`, pulled and tiled into a sheet |
| `perf` | `dumpsys SurfaceFlinger --timestats` for the game's own layer before and after ten seconds of play, plus `dumpsys thermalservice`. **Never `gfxinfo`**, which instruments HWUI and reports a confident zero for a Godot game (`GODOT.md`, `techniques/measuring-frames-on-the-phone.md`) |
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
