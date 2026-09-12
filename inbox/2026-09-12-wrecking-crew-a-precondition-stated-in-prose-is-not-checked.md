# A precondition a test states in a comment and never asserts will fail as the thing it was testing

**Game:** wrecking-crew  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites

## What happened

The new handedness gate went red on its first real run with three failures, the
loudest of them reading `the driving controls are INVERTED`. The controls were
fine. `_read_stick` and `drive_dir` are both symmetric, and the right-hand case
passed.

The machine had travelled **exactly 0.00 m** on a left push because it spawns at
`x = -17.5000`, and `_clamp_to_deck` pins `|x|` at `DECK_W*0.5 - RIG_RADIUS`,
which is also 17.5. It starts welded to the left wall. `_clear_spawn_x()` scores
each candidate x by its clearance from `columns` and `walls`, and `walls` holds
infill panels only, so the perimeter is not in the scan at all: the gap it
measures GROWS the closer it looks to a wall the machine cannot pass. Level 1 is
the only level whose front row is fully panelled, so the middle scored 0.65 and
the room's edge scored 3.437, and the edge won.

Measured by porting the sim: left 0.000 m, right +10.745 m. After the fix, level 1
spawns at -15.50 and both directions travel 10.745 m, perfectly mirrored.

The second half of the lesson is the test's own. Its `HOLD` constant carried the
comment *"still far short of the deck's side wall, which is 17.5 m from the spawn"* --
the precondition, stated in prose, never asserted. When it silently stopped being
true, the gate failed with the wrong explanation attached, and the wrong
explanation was the one that invites someone to lower the threshold until it
passes. This studio has shipped inverted controls six times by that route.

## The rule

A precondition a test needs is an assertion, not a comment. If a setup depends on
where something spawns, how much room it has, or what state a scene boots in,
assert that first, in the same test, with its own message -- so a broken
precondition reports itself instead of being reported as the thing under test.

And a failure message must be able to be wrong. "The controls are INVERTED" was
stated with total confidence about a control that was correct. Where a test can
distinguish "the subject is broken" from "the fixture is broken", it should say
which, and the check for the fixture goes first.

## Replaces or contradicts

Nothing. `TESTING.md` already says a positive control must be a query whose answer
you have checked, and that a construct that cannot fail is untested. This is the
neighbouring case: a construct that CAN fail, for a reason that has nothing to do
with its subject, and names its subject anyway.
