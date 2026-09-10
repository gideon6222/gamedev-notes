# A feel test that lets a second thing move with the first tests neither — hold the inputs still and drive the function

**Game:** stillwater  **Date:** 2026-09-10  **Belongs in:** TESTING.md / asserting feel

## What happened

Stillwater's fishing line became a curve whose sag is driven by the fight's tension: slack
hangs, taut pulls straight. The obvious test for that is the one I wrote first — reach a
fight, read the midpoint's droop, drop `sim.tension` to almost nothing, step a frame, read it
again, assert the second is larger.

It passed. It also passed with the sag **hard-wired to ignore tension completely**, which is
the only reason I found out. Tension does not only set the sag; it also bends the rod. So
lowering it moved the ROD TIP, which moved the whole line, which moved the midpoint - by more
than the threshold, in the same direction, for entirely the wrong reason. The test was
measuring rod bend and reporting it as line sag.

Rewritten to call the draw function directly with fixed endpoints - same `a`, same `b`, two
tension values, compare - it now reports 0.183 vs 0.183 when the bug is reintroduced, and
fails.

## The rule

When asserting that X changes the shape or feel of Y, check what else X drives. If X moves
anything else in the picture, the test must hold those still - **call the function under test
with fixed inputs rather than setting a value and stepping a frame.** Stepping a frame runs
the whole game, and the whole game is exactly the set of confounders you are trying to
exclude.

And the general form, which is the cheap habit that caught it: **verify a new assertion by
reintroducing the bug it is supposed to catch, and read the numbers it prints when it
fails.** Two identical values in a failure message ("0.183 vs 0.183") are proof the test is
looking at the right quantity. A test that fails with two plausibly different numbers may
still be measuring the wrong thing.

## Replaces or contradicts

Extends INDEX.md standing rule 11 ("a construct that cannot fail is untested, not safe"),
which says to reintroduce the bug. This is the case where reintroducing it was not enough on
its own: the test still passed, and what exposed it was that it passed. Worth adding to
TESTING.md as the follow-on - **if reintroducing the bug does not fail the test, the test is
measuring a confounder, and the fix is to remove the confounder's freedom rather than to
tighten the threshold.**
