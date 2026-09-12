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
- **A test that steps a system once proves the step, never the sequence.** Anything with feedback
  in it - a meter that costs you the means to refill it, an economy priced off its own output,
  difficulty that scales with progress - needs a probe that runs the loop dozens of times, and the
  assertion is *does it still have a way forward*. Coreward's collapse test proved a single
  collapse recovers and said nothing about three: a probe on the shipping loop stopped dead on run
  22 with three regions down, the meter pinned at zero and nothing changing for six more runs. The
  cheap version is a unit test that loops the PURE system until it stops changing and asserts the
  terminal state is actionable - a millisecond for what cost a browser probe four simulated hours.
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
  through the real handler and asserts where the avatar ends up ON SCREEN**: `main._cam.transform.basis.x.x > 0.5` is the NDC claim as arithmetic, no GPU, no
  tree, no frame, and read **-1.00** before the fix. For a facing, assert the ART's forward and
  NORMALISE it - a basis carries the model's scale, and the dot read 0.19 for a creature facing
  perfectly forwards. `test/test_controls.gd` in the template.
- **And every game gets one FILMED scenario driven by a policy through the real input handler.**
  The assertion above catches an inverted axis at one instant; this catches everything that goes
  wrong over a minute of play, and it is about thirty lines on the replay autoload: ask the policy
  where it wants to be, put the sim's steering state back, convert the difference to pixels with
  the handler's OWN constants inverted (so a change to the control changes the bot with it), clamp
  to what a thumb can do in one frame (54 px, or it teleports and the film proves nothing), and
  push a real `InputEventScreenDrag`. First run on wildform: the evolution transform covered the
  whole screen for 5.08 s, three times, a fifth of the run unreadable, while all 4,800 assertions
  passed - every one drove the sim and none drove the picture. Recorded touch replays do not
  replace it: they stop being valid the moment the layout moves, and a policy adapts.
- **A fixture where every policy succeeds measures nothing.** Four policies on a bought-out ladder
  dealt byte-identical damage to eight decimals, because every one kills an 864 HP boss and every
  run ends at the boss's health. Check the losers actually lose, and give a policy **the loadout its
  player would really have there**: over-equipping flattens the field, under-equipping fails
  everything, and both read as "no difference". Re-measured that way, 254.8 / 249.3 / 214.5 / 208.0
  over twelve seeds (M). Never compare on ONE seed, and assert the ORDER of the field, not a gap.
- **A bound is only as good as the count it is measured over, so raise the sample rather than
  loosen the bound.** Candle Gift checked that every probability constant can actually fire over
  200 hashed chunks; a 0.035 tier expects seven hits and drew two. Widening the band until two
  passes would have accepted a broken hash for every other constant, all five to fifteen times
  larger; 2000 chunks makes the expected value 70 and the same 50% bound meaningful for all of
  them, and 2000 integer hashes was never why the suite took any time. **In a pure test a bigger
  sample is almost always free.** The same check showed why **a bound is stated against its own
  input, never as a hand-derived literal**: halving `CASH_CHANCE` 0.50 to 0.26 failed with "money
  can never spawn", a correct change reported as a breakage by a message saying the opposite of
  the truth.
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
- **A precondition a test states in a COMMENT will fail as the thing it was testing.** The new
  handedness gate went red reading `the driving controls are INVERTED` about controls that were
  fine: the machine had travelled exactly 0.00 m because it spawned at `x = -17.5000` against a
  clamp at 17.5, welded to the wall, while the test's `HOLD` constant carried the precondition
  ("still far short of the deck's side wall") in prose and never asserted it. **A failure message
  must be able to be wrong.** Where a test can tell "the subject is broken" from "the fixture is
  broken" it says which, and the fixture check goes FIRST - a confident wrong message is the one
  that invites someone to lower the threshold until it passes, which is how this studio shipped
  inverted controls six times.
- **Two assertion shapes that can never fail, both of them the natural way to write it.** For
  "fires once", COUNT the emissions and advance whatever clock the stamp reads between the calls:
  comparing `finished_at` across two back-to-back calls passed with the `if finished: return` latch
  deleted, because no simulated time passed and the re-stamp wrote the identical value. For "sets
  up a state", assert on state the call is the only thing that could have produced and check the
  fixture is NOT already in it - `launch_final()` asserting `phase == DESCENT` passed with its
  `redescend()` deleted, the phase having been DESCENT already. Both are invisible to the assertion
  floor: 195 tests and 24,441 assertions with the faults in as without.
- **Assert the property the message states, not a literal.** "bays equals upgrade count",
  not "bays equals 7".
- **Write a phase check as a partition over whatever the UI actually holds, not as a list of the
  controls you remember.** A new DAILY button was left out of the den's three-line visibility list
  and drew as a solid slab across the type pips for every second of play, through a release, in
  every screenshot ever taken of it - and a 200-assertion smoke suite could not fail on it, because
  every assertion NAMES a control and this was a control nobody had named yet. Walk the UI root's
  children, flip the phase, fail on anything drawn in both that is not on a deliberately short
  allow-list, and check the other direction too: drawn in NEITHER phase is dead weight. The
  allow-list then becomes a decision somebody writes down rather than one that happens by omission.
  Two load-bearing details: **`is_visible_in_tree()`, not `visible`** (a control inside a hidden
  sheet has `visible == true`, and twenty-one false positives came from that), and only the layer
  the phase governs - `get_children()`, not a recursive `find_children`, since a panel's contents
  are governed by the panel.
- **Give every node a `name` at construction.** An unnamed one is `@Label@56` in every error and
  every inspector tree, and the time it matters is the time you are reading a failing check.
- **A test that re-derives the rule it is testing passes with the rule deleted.** A room placer's
  test walked the same slots, applied the same drop condition and asserted no overlaps: it checks
  the copy matches, never that the world is right. Make the decision REPORTABLE and assert the
  OUTPUT. The trap repeats one level down - "was this room placed", answered by whether its centre
  cell is stamped, is also true of a room that was dropped. The smell is a test containing a copy of
  a condition from the source; the question is whether it could pass with the feature absent, both
  sides agreeing it is absent.
- **Test intent as well as values**: a deeper ore is rarer than the one above it, the cooling
  mineral lives below the heat line. These have caught design mistakes before a human saw them.
- **Constants that share a formula move together.** Put the test on the derived quantity the player
  feels, and grep every formula a constant appears in before changing it.
- **Every "there is always a way out" test drives the input handler's seam**, not the
  method. A way out the handler never calls is a missing feature with full coverage.
- **Test the random source itself** (range, distribution) and that each mechanic occurs in
  an actual run. A condition that can never be true fails as absence.
- **A sampling test for rare content passes when the rare thing simply misses**, so the rarer
  the content the weaker the test gets - backwards, since that is where a generation bug hides
  longest. "The first world does not contain solmarrow" survived moving the ore's floor from 372 m
  to 20 m: 0.12% of 494 eligible cells is 0.6 expected. **Test the invariant, not the sample** -
  "no cell above a material's floor ever holds it" cannot be satisfied by luck - and split the
  guard by what it can see. If you must sample, assert on a lot of it and on a RATE.
- **Test a scrolling list at a size where it must scroll** (seven rows fit on a phone, so at real
  size the test exercised nothing), a moving obstacle at every phase, a priority where the
  priorities disagree.
- **A test cannot SET derived state; drive the input the derivation reads.** Assigning a value
  that `_sync_*` recomputes on the next line measures the unchanged one and reports it as a number
  - "the sky over the quarry is the same as over the reeds, 0.01 against 0.01" - indistinguishable
  from the feature not existing, and it nearly cost a re-plumb of a correct shader. Where the input
  has no scenario, **assert the RELATIONSHIP instead**: Stillwater's boat never moves in world
  space, so "the foam follows the boat" tested something the game does not do, while "the collar
  sits AHEAD of the origin along her own axis" catches the mistake genuinely available there (node
  forward is -Z). **The tell is two identical numbers** when you set one of them yourself.
- **A test must not depend on what the case before it left on disk.** Reset the file AND the
  value the object loaded from it.
- **Verify every regression test by reintroducing the bug, and suspect any fix you cannot make
  fail.** That proves nothing if the check is never REACHED - one session "verified" a guard that
  had been silently skipped - so read the assertion count alongside it. If the bug goes back in and
  the test still passes, the test is measuring a confounder: remove the confounder's freedom, never
  tighten the threshold. Stillwater's line-sag test passed with sag hard-wired to ignore tension,
  because tension also bends the rod and the rod moved the whole line, so **call the function under
  test with fixed inputs** rather than setting a value and stepping a frame, which runs every
  confounder you are trying to exclude. If deleting a fix changes nothing observable, either the
  test is wrong or the fix is, and a test written AFTER a hand-tuned fix can be measuring the
  tuning. Never re-record a golden without reading the diff.
- **A test can measure the wrong END of the right object** - a plausible number that moves when the
  game changes and is never the number in question. Name the end at risk in the assertion's own
  words ("the LAST candle, not the leader") before you write it (`CRAFT.md` has the camera side).
- **A sentinel value used inside a max or min must stay ordered**, and a "never" sentinel is parked
  at the end of the axis it lives on, asserted. A flat "way off" constant makes a search for the
  worst case return the FIRST case: Candle Gift returned a flat 9.0 for every point behind the lens,
  they compared equal, `if f > worst` kept the nearest, and the camera framed a candle metres in
  front of the one hanging off the edge - it held to level six and broke at ten, where
  `9.0 + local.z` keeps the ordering true. Gravewell parked "no water" at -1e6 which, depth growing
  downward, is above the whole planet: every class rendered as submerged.
- **Print the state before theorising about it.** Three rounds of plausible causes all fitted
  the screen and none was true; one print of the cells around the stuck ship showed
  `mat=2 fill=0.00` and ended it.
- **Write a table's balance property as an assertion in the same commit as the table**
  (`CRAFT.md`): the cheapest test in the repo, and the one most likely to fire on its first run
  against a table its author has just proofread.
- **A tool that cannot report failure reports absence instead, and absence is the answer we act
  on.** Any scraper, filter, search or allow-list whose empty result would be believed needs a
  positive control: one query whose answer you have CHECKED is non-empty, run before the miss is
  written down. **Loud failure is not enough**: `assets.py` printed `HTTP 404` above its empty table
  and the scout still wrote "KayKit has zero creature repos", because a reader of a search looks for
  ROWS and an error line reads as none (`ASSETS.md`). Check the exit status before recording a miss,
  put your own tool's failure on the LAST line, and tell the two apart - zero rows after filtering
  is an answer, zero rows before it is a broken scraper.
- **An allow-list clause is where a vacuous guard hides**, because it is the clause that makes
  the test pass: Coreward's no-`Math.random` guard allowed the roll whenever the preceding text
  ended in `=`, meant to permit an injectable default and also permitting the bug. Falsify each
  clause separately, not the test as a whole.
- **A branch reachable only through a failure needs its failure path exercised once**, or it is
  untested in exactly the case it exists for. `new-game.ps1` probed "does this repo exist" with a
  command *meant* to fail on a new game, and died there.
- **Version is one fact in five places and no code derives any of them**: `Changelog.VERSION`,
  `RELEASES[0].version`, and `version/name` **and `version/code`** in every export preset. The
  template's `test/test_version.gd` asserts all five out of `export_presets.cfg` as a pure test and
  is the copy to take: the sibling games collect only `version/name=`, which is why four of five
  repos sat on `version/code=1` after a dozen releases each, and Play rejects any upload whose code
  is not higher than the last. Tie the code to `RELEASES.size()`. The AAB preset's copies are the
  dangerous ones.
- **A tool that drives the real code is a fuzzer whether or not you meant it to be.** When a
  probe or harness throws, the first question is "can the game reach this state", never "how do I
  get my tool past it" - and the tell is a fix in the tool that was a GUARD rather than a
  correction, since a guard says "this input is possible and I am handling it", which is a
  statement about the code under test. Coreward guarded a probe against an unsellable hold item
  and the same crash arrived hours later from his phone, on a black screen, every frame.
- **Verify the artefact, not the exit code of the tool that made it**, in the same script that
  makes it so the check cannot be skipped: dimensions, size against a known-good baseline, and a
  variance measure that tells an image from a flat fill. A converter has returned 0 having
  written a 342-byte solid colour. `ASSETS.md` owns the recipe and the baselines.
- **Anything that measures layout runs after the element is visible.** A `display:none` subtree
  measures zero on every axis, so a "nothing is laid out yet" fallback fires on every call and
  quietly becomes the implementation - Coreward's camera-framing fix shipped, looked right, and
  had never once run. A guard that fires every time is not a guard.
- **Assert the SPAN of what a periodic job recorded, not that it recorded anything.** Work added
  BESIDE the branch that resets a countdown, guarded on the same `<= 0`, runs once ever - the
  timer is reset in the frame it expires, so periodic work belongs INSIDE the branch that resets
  it and a second `if` on the same variable tests it at a different point in its cycle. One sample
  satisfies "did anything get recorded", and a map that recorded one row looks exactly like a map
  you have not explored. Assert `hi - lo` against the distance travelled: putting the bug back
  reported `rows 0..0`, which named it in the failure message.
- **When an input seam changes, grep the tests for the OLD seam before changing anything else.**
  A `tap()` that became a documented no-op kept every caller passing while applying no input at
  all, and passed until the escape margin widened - which is when anyone learned it had stopped
  testing. A no-op that keeps its name is worse than a deleted one, which fails loudly; if a
  stand-in must survive, have it increment a counter the tests can assert on.
- **A guard whose input is a build artifact has to own the build, or refuse a stale one.** A shed
  of imported props took an APK from 35.62 MB to **64.58 MB**, 81% past a 10% tolerance, while
  `check.ps1` printed `size ok` throughout: it weighs whatever APK is in `build/`, and that one was
  from the previous export. CI exported first and caught it. Compare the artifact's mtime against
  the newest source file and say "no APK newer than your changes" rather than OK - the template's
  `check_size.gd` now does - and **run the check with `-Export` in any commit that adds, removes or
  reimports an asset**. Treat a green size step over a stale APK as no measurement at all. **A green
  local check is not a green build** wherever a local step can silently measure the wrong thing.
- **What a green run actually ran is its own subject**, and five shipped faults are in
  `techniques/the-test-harness.md`. The rules:
  - **Point runners at a glob and FAIL on an empty glob** - zero suites and a green exit are
    indistinguishable from outside, and a sibling game reported "65 passing" for a suite that had
    never run. **A glob discovers through the IMPORT CACHE**, so run the gate, never a bare
    `--script`, before believing a green: gravewell read 195 tests over 20 suites all session
    against the gate's 204 over 22. **Print the suite LIST, not only the count**, and treat an
    untracked `.uid` beside a tracked `.gd` as the tell.
  - **Enforce a FLOOR on the assertion count.** A runtime error inside a check is non-fatal in
    GDScript: the function stops, everything below it never runs, and the harness prints "all
    passing" with a smaller number nobody reads (402 -> 387 deleted "the gauge is actually on
    screen"). `const MIN_ASSERTIONS` is a canary, not a target. Grep for `SCRIPT ERROR` too.
  - **Wait on game STATE, never wall-clock time, and on that state rather than a proxy for it.**
    Anything accumulating over game time runs through `freeze()` then `advance(seconds)`; a depth
    is a proxy for having drilled and the fuel gauge moving IS having drilled. "Until 10 m" passed
    on the desk and failed on a GPU-less runner that got seven metres in the same window.
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
- **Assert saturation only where the statistic is MONOTONE, the run is long enough to reach the
  envelope, and nothing downstream clamps the quantity being watched.** Saturation is the right
  question and was a bad assertion: Wrecking Crew's ratio of one 30 s window's worst ball speed
  over the previous one's, under 1.15, fails at **25% of window positions** slid along a 20-minute
  trace (22% on the old spawn, M). It had been a coin flip for the life of the game, and a
  two-metre spawn change reseeded it rather than breaking it. Longer windows do not rescue it -
  1.485 at 60 s, 1.305 at 120 s, 1.216 at 180 s (M) - because a maximum is an extreme-value
  statistic and converges far slower than a 15% tolerance, so the tolerance sat inside the
  sampling noise of its own statistic. **Slide any test that compares two statistics from a
  simulated trace along a much longer run and count how often it would have passed**; if the
  answer is not "always", the number reports where you sampled.
- **Check what a guard clamp does to the quantity you assert.** A value capped by `limit_length`,
  `clamp` or `min` saturates whether the system is healthy or running away, so "it settles" proves
  nothing: a radial correction at gain 1.6 settles at ~45 m/s against a correct ~44 and no
  saturation or ceiling test catches it. Where a clamp exists, a recorded ceiling PLUS the
  per-frame clamp check is the honest shape, and the comment says which faults it cannot separate.
  **A replacement assertion nobody has seen fail is a guess** - break the code and watch it go red.
  `techniques/wrecking-crew-pendulum.md`.

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
over a seeded sim, so **a replay file produces the same frames on every run** and two sheets a week
apart are comparable cell for cell. Mechanism, probe, stamp and every wrapper trap:
`techniques/filming-a-run.md`.

```powershell
# Record the scenario first if the repo does not have it - most carry only the idle stub.
godot --path . --resolution 460x996 -- record=test/replays/first-minute.json touch
scripts\movie.ps1 -Replay test/replays/first-minute.json -Seconds 20 -Fps 60 -Every 20
scripts\movie.ps1 -Seconds 10 -Name idle          # no -Replay: films the attract state
# -> build/movie/<name>/frame00000000.png ... and build/movie/<name>/sheet.png
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
- **Budget about 150 MB and twenty seconds of wall clock per second of film** (M). Film the
  shortest run that shows the thing, keep output out of any directory Godot imports
  (`build/.gdignore`), and print the console errors with the sheet.
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
