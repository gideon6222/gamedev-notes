# A test that throws half way through is reported as PASSING

**Stillwater, 2026-09-11.** The worst thing a suite can do, and this one does it.

A new test called `sim._begin_tug()`. No such method exists — I invented the name. GDScript
threw `Invalid call. Nonexistent function '_begin_tug'`, the test function **aborted at that
line**, and the runner printed:

```
107 tests, 10877 assertions, all passing
```

Everything after the bad line silently did not run, including the one assertion that existed
to catch a real bug. I then "verified" that guard by reintroducing the bug — and the suite
passed, because the assertion was never reached. **The verification step itself was fooled**,
which is the part worth remembering: reintroducing a bug proves nothing if the check cannot
be reached.

**What gave it away** was an assertion COUNT that did not move as much as expected: adding a
test with eight assertions took the total up by four. That number is the only signal, and
only if you are watching it.

**Two fixes, and the second matters more:**

1. The runner should catch a failure inside a test body and report it as a FAILED test rather
   than continuing. Godot prints the SCRIPT ERROR to stderr, which a grep for `FAIL` misses
   entirely — so at minimum grep the run for `SCRIPT ERROR` as well as for failures.
2. **Assert the assertion count.** This repo already learned this once, in the smoke suite,
   after a rename silently dropped fifteen checks: `MIN_ASSERTIONS := 390`. The pure suite had
   no such guard. A suite that cannot tell you it got smaller is a suite that quietly stops
   testing things.

**And a related one from the same hour: a comparison that varies two things measures
neither.** A check that "the right bait means more teases" compared a bluegill on worms
against a *carp* on worms — two species, two base tease counts, two RNG draws. It reported
3 against 3 and would have reported something for any pair of numbers. Same subject, same
seed, one variable.

Related: [[a-construct-that-cannot-fail-is-untested]], [[renaming-a-property-silently-deletes-assertions]]
