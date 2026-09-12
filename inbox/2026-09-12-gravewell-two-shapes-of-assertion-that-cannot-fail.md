# Two assertion shapes that can never fail: comparing a timestamp across calls with no time between them, and asserting a state that was already true before the call under test

**Game:** gravewell  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites

## What happened
Rule 11 run over a new seven-test suite, five faults reintroduced one at a time. Three
were caught. Two were not, and both were "once" or "sets up" claims written the natural
way:

1. **The latch.** `claim_gravewell()` must fire the ending once. The test called it twice
   and compared `finished_at` across the two calls. With the `if finished: return` latch
   deleted the test still passed, because no simulated time passes between two back-to-back
   calls, so the re-stamp writes the identical value. It also never counted the `ended`
   signal, which is the thing the claim is actually about.
2. **The setup.** `launch_final()` must build the last world as a real descent, and the
   test asserted `phase == DESCENT`. With the `redescend()` call deleted the test still
   passed, because the phase was already `DESCENT` before `launch_final()` ran.

Both failures are invisible to the assertion count: the suite reported the same 195 tests
and 24441 assertions with the faults in as without.

## The rule
To test that something fires once, count the emissions, and advance whatever clock the
stamp reads between the two calls. To test that a call establishes a state, assert on state
the call is the only thing that could have produced, and check the fixture is NOT already
in that state before it runs, otherwise the assertion is about the fixture.

## Replaces or contradicts
- **A construct that cannot fail is untested, not safe**: a modulo, a `|| fallback`, a clamp, a
  fixture where every value is convenient, a safety test aimed at a case that cannot trigger. Add
  the awkward fixture, make fixtures assert their own preconditions, and say why.
