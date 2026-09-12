# When a threshold test's expected count is small, raise the sample size rather than loosen the bound

**Game:** candle-gift  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites

## What happened

`test_util.gd` checks that every probability constant the game compares a hash against can
actually fire — a constant the generator never reaches disables a whole mechanic silently. It
did this by counting hits over **200** hashed chunks and comparing against four hand-derived
literals, one per constant.

Two faults surfaced together when money was rebalanced.

**The literals were each right only for the constant they were written against.** Halving
`CASH_CHANCE` from 0.50 to 0.26 failed the check with **"money can never spawn"** — which is
not remotely what had happened. A correct change produced a failure message telling the reader
the opposite of the truth. Restating each bound against its own threshold
(`hit > threshold * SAMPLES * 0.5`) fixes that and survives the next rebalance.

**Then the smallest constant failed honestly.** A new tier chance of 0.035 expects seven hits
in 200 and drew two. The tempting fix is to widen the band until two passes — and that band
would then have accepted a genuinely broken hash for every other constant in the list, all of
which are five to fifteen times larger. Raising the count to **2000** makes the expected value
70 and the same 50% bound meaningful again, for the small constant and the large ones alike.

The check costs 2000 integer hashes. It was never the reason the suite took any time.

## The rule

**A bound is only as good as the count it is measured over.** If the smallest thing a shared
assertion covers has an expected value in single figures, ordinary variance will fail it, and
loosening the bound to accommodate that makes the assertion vacuous for everything else it
covers. Raise the sample size instead — in a pure test it is almost always free.

And **state each bound against its own input, never as a hand-derived literal.** A literal is
correct on the day it is written and afterwards reports rebalances as breakages, in a message
that actively misleads about what changed.

## Replaces or contradicts

Nothing. It is the quantitative companion to two rules already there — "**A construct that
cannot fail is untested, not safe**" and "**Assert the property the message states, not a
literal.** 'bays equals upgrade count', not 'bays equals 7'" — neither of which says anything
about how many samples make a statistical bound mean what it claims.
