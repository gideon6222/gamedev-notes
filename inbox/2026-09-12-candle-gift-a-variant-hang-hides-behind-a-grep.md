# `Callable.call()` is a Variant source the `["` grep does not find, and piping a suspected hang through `grep` hides the parse error that caused it

**Game:** candle-gift  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Invariants every game keeps (beside the Dictionary-Variant rule), and TESTING.md / Rules for the suites

## What happened

A pure suite that runs in about three seconds ran past a **600-second timeout**. The recorded
symptom for that in this repo is a quadratic hang (`Trail.layout` calling `sample_back` per
candle), so that is what it was diagnosed as, and about fifteen minutes went into looking for
one.

It was a parse error. `var hit := fires.call(threshold)` infers Variant from a
`Callable.call()`, the project treats that warning as an error, so `test_util.gd` failed to
compile. `run_tests.gd` globs `test_*.gd`, `load()` returned a broken script, `.new()` on it
printed `Nonexistent function 'new' in base 'GDScript'` — and the runner then **spun instead
of exiting**.

Two things made it expensive rather than a ten-second fix.

**The Variant rule in `GODOT.md` names Dictionary reads and its grep only finds those.**
`grep -rn 'var [a-z_]* := .*\["'` cannot see `fires.call(x)`, `arr[i]`, or anything else
returning Variant, and `Callable.call()` is the one a test helper hits, because a local lambda
is how a test avoids repeating itself.

**Every run was piped through `grep -E "FAIL|tests,"`,** which is a perfectly sensible filter
for a passing suite and discards the only line that mattered. The parse error was printed on
the very first run and never reached the terminal. Re-running once with nothing piped showed
it immediately.

## The rule

**Any `:=` on a Variant-returning expression fails the whole file, not the line** — Dictionary
reads, untyped Array elements, and `Callable.call()`, which no existing grep here catches.
Annotate the local: `var hit: int = fires.call(threshold)`.

**Run a suspected hang once with nothing piped before theorising about it.** A filter written
for a healthy run discards exactly the diagnostic a broken one prints, and a hang is evidence
about the RUNNER, not about the code under test — a globbing runner that cannot load a suite
should fail loudly, and this one spun.

## Replaces or contradicts

**Only one of the two halves is new, and the digest should not duplicate the other.**

Sharpens `GODOT.md`: "**A value read out of a Dictionary is a Variant and `:=` cannot infer
from one.** Annotate the local: `var pos: Vector3 = c.pos`. `grep -rn 'var [a-z_]* := .*\["'
src/ test/` finds every one in a second and the failure mode is a five-minute hang each." That
line is right about the symptom and too narrow about the source: the grep it offers cannot see
`Callable.call()`, which is the Variant a TEST file hits, because a local lambda is how a test
avoids repeating itself. Widen it to `var [a-z_]* := .*\(\.call(\|\["\)` and say "a Dictionary
read, an untyped Array element, or `Callable.call()`" rather than naming only the first.

Does **not** replace `GODOT.md`'s "**A parse error in a script the harness loads produces a run
that never terminates**, not a failure" — that rule already exists and already predicted this
symptom exactly. It is the reason the fifteen minutes were avoidable, and the reason the second
half of this lesson is the part worth adding: the rule was in the base, and a `grep` filter on
the run's output meant the evidence for it never reached the terminal.

So the genuinely new line is the habit, and it belongs in `TESTING.md` beside the suite rules:
**run a suspected hang once with nothing piped.** A filter written for a healthy run discards
exactly the diagnostic a broken one prints.
