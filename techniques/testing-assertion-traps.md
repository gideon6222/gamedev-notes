# Assertion shapes that pass with the bug present

**Game:** Coreward, Stillwater, and studio tooling (`assets.py`) · **Status:** each item a shipped
fault, now guarded · **Read when:** a test passes and you are not sure it could ever fail; a UI
element ships invisible or stuck visible through a whole release; a precondition lives in a
comment instead of an assertion; a scraper or search tool reports a miss that might be its own
failure; a regression test cannot be made to fail by reintroducing the bug; a test recomputes the
same condition the code under test does.

Split out of `TESTING.md` at the 2026-09-12 digest, which needed the room. The one-line rules are
still there; the full story, with the numbers, is here.

**Generalisable takeaways**

- **A test that could pass with the bug present is not proof of anything**, however many
  assertions surround it or however green the suite reads.
- **The tell is almost always a copy**: the test recomputes the same condition the code does,
  names only the controls the author remembers, states a precondition in prose instead of
  asserting it, or cannot tell its own tool's failure from an honest empty result.

---

## A precondition stated in a comment fails as the thing it was testing

A new handedness gate went red reading `the driving controls are INVERTED` about controls that
were fine: the machine had traveled exactly 0.00 m, spawned at `x = -17.5000` against a clamp at
17.5 and welded to the wall, while the test's `HOLD` constant carried the precondition ("still far
short of the deck's side wall") in prose and never asserted it.

**A failure message must be able to be wrong.** Where a test can tell "the subject is broken" from
"the fixture is broken" it says which, and the fixture check goes FIRST - a confident wrong message
invites lowering the threshold until it passes, which is how this studio shipped inverted controls
six times.

## A phase check as a list of remembered controls misses the one nobody named

A new DAILY button, left out of a den's three-line visibility list, drew as a solid slab across the
type pips through a whole release, in every screenshot ever taken of it. A 200-assertion smoke
suite could not fail on it, because every assertion NAMES a control and this was one nobody had
named yet.

**Write a phase check as a partition over whatever the UI actually holds, not as a list of the
controls you remember.** Walk the UI root's children, flip the phase, fail on anything drawn in
both that is not on a deliberately short allow-list, and check the other direction too: drawn in
NEITHER phase is dead weight. The allow-list then becomes a decision someone writes down rather
than one that happens by omission. Two load-bearing details: **`is_visible_in_tree()`, not
`visible`** (a control inside a hidden sheet has `visible == true`, and twenty-one false positives
came from that), and only the layer the phase governs - `get_children()`, not a recursive
`find_children`, since a panel's contents are governed by the panel.

## A test that re-derives the rule it is testing passes with the rule deleted

A room placer's test walked the same slots, applied the same drop condition and asserted no
overlaps: it checks the copy matches, never that the world is right. Make the decision REPORTABLE
and assert the OUTPUT.

The trap repeats one level down - "was this room placed", answered by whether its center cell is
stamped, is also true of a room that was dropped. The smell is a test containing a copy of a
condition from the source; the question is whether it could pass with the feature absent, both
sides agreeing it is absent.

## A regression test has to be verified by reintroducing the bug

Stillwater's line-sag test passed with sag hard-wired to ignore tension, because tension also
bends the rod and the rod moved the whole line anyway, so a test that only set a value and stepped
a frame ran every confounder it was trying to exclude.

**Verify every regression test by reintroducing the bug, and suspect any fix you cannot make
fail.** That proves nothing if the check is never REACHED - one session "verified" a guard that
had been silently skipped - so read the assertion count alongside it. If the bug goes back in and
the test still passes, the test is measuring a confounder: remove the confounder's freedom, never
tighten the threshold. **Call the function under test with fixed inputs** rather than setting a
value and stepping a frame. If deleting a fix changes nothing observable, either the test is wrong
or the fix is, and a test written AFTER a hand-tuned fix can be measuring the tuning.

## A test that steps a system once proves the step, never the sequence

Anything with feedback in it - a meter that costs you the means to refill it, an economy priced off
its own output, difficulty that scales with progress - needs a probe that runs the loop dozens of
times, asserting *does it still have a way forward*.

Coreward's collapse test proved a single collapse recovers and said nothing about three: a probe on
the shipping loop stopped dead on run 22, three regions down, the meter pinned at zero and nothing
changing for six more runs. The cheap version is a unit test that loops the PURE system until it
stops changing and asserts the terminal state is actionable - a millisecond for what cost a browser
probe four simulated hours.

## A sampling test for rare content passes when the rare thing simply misses

"The first world does not contain solmarrow" survived moving the ore's floor from 372 m to 20 m:
0.12% of 494 eligible cells is 0.6 expected. The rarer the content the weaker a sampling test
gets - backwards, since that is where a generation bug hides longest.

**Test the invariant, not the sample**: "no cell above a material's floor ever holds it" cannot be
satisfied by luck, and split the guard by what it can see. If you must sample, assert on a lot of
it and on a RATE.

## An allow-list clause is where a vacuous guard hides

Coreward's no-`Math.random` guard allowed the roll whenever the preceding text ended in `=`,
meant to permit an injectable default and also permitting the bug. **An allow-list clause is where
a vacuous guard hides**, because it is the clause that makes the test pass. Falsify each clause
separately, not the test as a whole.

## A verified artefact beats a trusted exit code

A converter has returned 0 having written a 342-byte solid color. **Verify the artefact, not the
exit code of the tool that made it**, in the same script that makes it so the check cannot be
skipped: dimensions, size against a known-good baseline, and a variance measure that tells an
image from a flat fill. `ASSETS.md` owns the recipe and the baselines.

## A layout measurement taken before the element is visible measures zero and calls it a fallback

Coreward's camera-framing fix shipped, looked right, and had never once run: a `display:none`
subtree measures zero on every axis, so a "nothing is laid out yet" fallback fires on every call
and quietly becomes the implementation. **Anything that measures layout runs after the element is
visible.** A guard that fires every time is not a guard.

## An input seam that becomes a documented no-op keeps every caller green

A `tap()` that became a documented no-op kept every caller passing while applying no input at all,
and passed until the escape margin widened - which is when anyone learned it had stopped testing.
**When an input seam changes, grep the tests for the OLD seam before changing anything else.** A
no-op that keeps its name is worse than a deleted one, which fails loudly; if a stand-in must
survive, have it increment a counter the tests can assert on.

## A tool that cannot report failure reports absence instead

`assets.py` printed `HTTP 404` above its empty results table and the scout still wrote "KayKit has
zero creature repos", because a reader of a search looks for ROWS and an error line reads as none.

**Any scraper, filter, search or allow-list whose empty result would be believed needs a positive
control**: one query whose answer you have CHECKED is non-empty, run before the miss is written
down. Check the exit status before recording a miss, put your own tool's failure on the LAST line,
and tell the two apart - zero rows after filtering is an answer, zero rows before it is a broken
scraper. `ASSETS.md` has the recipe.
