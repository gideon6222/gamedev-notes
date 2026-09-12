# The test harness: discovery, clocks, floors and what a green run does not prove

**Game:** all of them, and the template owns every fix  **Status:** each item is a shipped fault
**Read when:** a suite reports "all passing" and you are not sure what it ran, a run does not
terminate, a green local run disagrees with CI, a test hangs or captures the wrong screen, or you
are about to believe a count.

Split out of `TESTING.md` at the 2026-09-12 digest, which needed the room. The standing rules are
still listed there in one line each; the mechanism, the counts and the dead ends are here. They all
answer the same question, which is the question this whole base keeps paying for: **what did the
green run actually run?**

Two takeaways that generalise past the harness:

- **A number nobody reads is not a measurement.** A suite count, an assertion count and a suite
  LIST are each worth printing only if something fails when they move in the safe-looking
  direction.
- **Discovery, the clock and the entry point are all shared state between a test and the game.**
  Every fault below is one of the three quietly disagreeing with what the test assumed.

## The runner: what it discovered, and what it counted

- **Any list of things to run that is maintained by hand fails silently in the safe-looking
  direction.** Point runners at a glob, and **fail on an empty glob** - zero suites and a green
  exit are indistinguishable from outside. A sibling game added nine `test_*.gd` files, not to the
  runner's array, and reported "65 passing" for a suite that had never run. The template's
  `test/run_tests.gd` is now the glob with the empty-glob failure and the assertion floor, and the
  template is the copy that matters: a game inherits its runner once, at scaffold, and nothing
  propagates backwards. **And a glob runner discovers through the IMPORT CACHE, so a bare
  `--script` can run fewer suites than the gate**: gravewell reported "195 tests over 20 suites"
  all session while `check.ps1` on the same tree reported 204 over 22, because `DirAccess.open` had
  never seen `test_controls.gd` and `test_sim_boundary.gd` - committed for weeks, passing, and
  missing their `.uid` files in that working tree. `check.ps1` runs `--import` first and CI was
  never blind. Run the gate rather than a bare `--script` before believing a green, **make the
  runner print its suite LIST and not only the count** so a shrinking set is visible, and treat an
  untracked `.uid` beside a tracked `.gd` as the tell.

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

## The clock, and waiting on the right thing

- **Wait on game state, never wall-clock time, and on THAT state rather than a proxy for it.**
  Anything that accumulates over game time runs through the headless seam (`freeze()` then
  `advance(seconds)`), where sixty game seconds is sixty game seconds on every machine; hold a
  real control only in the tests whose subject IS the wiring. A depth is a proxy for having
  drilled and the fuel gauge moving IS having drilled - a proxy can be retuned out from under the
  test and is reached at a different rate on a slower machine, and Coreward's "until 10 m" passed
  on the desk and failed on a GPU-less CI runner that got seven metres in the same window.

- **A helper that advances game time stops the clock and does not hand it back.** The stop is
  deliberate, so do not "fix" `advance` to restart it - the caller knows whether it wants real
  time. One helper calling `advance(3)` to settle an animation froze the rest of the spec, with
  every readout healthy (in play, key held, undocked) while nothing moved, which reads as a
  physics or input bug and is neither. **Put the warning where the mistake is made**: on
  `advance`, which people call, not on `startClock`, which people forget to call.

## A run that does not finish, or finishes looking at the wrong thing

- **A hanging suite is a parse error until proven otherwise, and `head` is the first command,
  not `grep FAIL`**, which hides the whole class of fault that produces no `FAIL`. **A harness
  must refuse to run against a stub**: one line after instantiating the scene, assert it has the
  method the suite is about to call and quit non-zero naming the script. `GODOT.md` has why.

- **A milestone that puts a screen in front of the game blinds every harness written before
  it.** The title returns before the game ticks, on purpose, so `freeze()` + `advance()` advanced
  nothing and captured the menu: exit 0, no error, a photograph of the title filed as evidence
  about tunnel lighting. Fix every entry point in the same commit and make the one way in a
  METHOD the real button also calls, or half the scripts reach into a private and half forget.
  The same fault one level down: **a look-pass fixture that positions the camera by playing the
  game can fail to position the camera** - Coreward's "the building is missing" screenshot had
  flown the ship across the world and never brought it back. Assert the subject is in frame
  before judging the photograph.
