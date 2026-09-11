# Renaming a property a test reads off an untyped variable silently deletes every assertion after it

**Game:** stillwater  **Date:** 2026-09-11  **Belongs in:** `TESTING.md` under rules for the suites

## What happened

The fight's HUD gauge was renamed from `_tension_bar` to `_distance_bar` in the game. The smoke
suite reads it as `main._tension_bar`, where `main` is an **untyped** local (`var main =
scene.instantiate()`), so the compiler has nothing to check. At runtime the missing property is
a non-fatal error, the check function stops at that line, and every assertion below it never
runs.

The suite printed **"smoke: 387 assertions, all passing"**. It had been 402. Nothing was red.
Fifteen assertions - including "the gauge is actually on screen", which exists because its
absence once shipped a build where neither gauge was ever visible - had quietly stopped
existing, and the only trace was a number nobody reads.

## The rule

**A suite that reports its assertion count must also enforce a floor on it.** Ten lines:

```gdscript
const MIN_ASSERTIONS := 390
if _t.checks < MIN_ASSERTIONS:
    print("  %d assertions, but at least %d expected - a check bailed part-way" % [...])
    quit(1)
```

It is a canary rather than a target: it cannot say which assertions vanished, only that some
did. That is enough, because the cause is always the same shape - something errored mid-check.

**And prefer a typed handle where the harness touches the game.** `var main: Node3D = ...`
does not help for game-specific members, but assigning the properties a test uses into typed
locals at the top of each check turns a silent bail into a loud one. Where that is impractical,
the floor above is the backstop.

The general form, which is the part worth keeping: **any harness that can partially complete
must report how much of itself ran, and fail when that shrinks.** A pass/fail flag alone cannot
distinguish "everything passed" from "most of it never executed".

## Replaces or contradicts

Nothing. It sits beside the existing note that a parse error in a loaded scene presents as a
hang - same family, opposite symptom: there the harness runs against a stub forever, here it
quietly runs less of itself and reports success.
