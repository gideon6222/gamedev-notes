# Wait on the precondition, not on a proxy for it

**What happened.** A Coreward smoke test held the down button until the ship was deeper than
0 m, then asserted that drilling had burned some fuel. A retune cut the fuel a cell of
drilling costs by about two thirds, and the gauge stopped rounding off 100% after a single
cut - so the wait was satisfied while the assertion after it was not, and the test failed on
a game that was working.

I replaced the wait with "until DEPTH 10 m". It passed on this desk and **failed on CI, which
reached seven metres in the same wall-clock window because it has no GPU.** The suite was
green locally and red in the cloud for a change that had nothing to do with either.

The fix was to hold until the fuel percentage drops below 100, which is exactly what the next
line asserts.

**The rule.** When a test has to wait for the game to reach a state, wait for THAT state, not
for something that usually accompanies it. A depth is a proxy for having drilled; the fuel
gauge moving is having drilled. A proxy has two ways to go wrong that the real thing does not:
the relationship between it and the state can be retuned out from under the test, and it can
be reached at a different rate on a slower machine.

**This is the same lesson this repo already had, arriving from a new direction.** It was
recorded as "waiting on real time for something measured in game time is the bug rather than
the timeout", and the answer that time was a deterministic tick seam. That answer only helps
when the harness owns the clock. When a test has to drive the real UI, the version that works
is to wait on the precondition itself.

**Where it belongs.** `TESTING.md`, beside the tick-seam rule, as the case that covers the
tests which cannot use it.
