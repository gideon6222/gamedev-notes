# A ratio between two maxima drawn from a chaotic trace measures where you sampled, not whether it converged

**Game:** wrecking-crew  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites

## What happened

`test_the_chain_does_not_invent_energy` drove the wrecking ball adversarially for
60 s, took the worst ball speed of the second half-minute over the worst of the
first, and required the ratio under 1.15. Its comment explained the reasoning
well: driving a pendulum near its period legitimately pumps it, so the honest
question is not a ceiling but whether it converges. The test had been green for
the life of the game. A two-metre change to where level 1 spawns turned it red at
`early 34.526, late 42.899`, ratio **1.2425**.

It looked like the spawn fix had exposed an energy leak the wall had been hiding.
It had not. Driven for **30 simulated minutes** (108,000 steps), the cumulative
peak saturates at **43.91 m/s by minute 5** on the new spawn and **44.47 by minute
3** on the old, and does not move again; `BALL_MAX_SPEED` never fires. Both spawns
reach the same envelope -- the old one is fractionally *higher*.

What settled it was sliding the test's own 60 s window along a 20-minute trace and
asking how often it would have passed. It fails at **25% of window positions on
the new spawn and 22% on the old**. It had been a coin flip on both all along. The
old spawn was green only because minutes 1 and 2 happened to land in a quiet
stretch (32.87, 33.88) before the trace reached its envelope in minute 3; measured
over minutes 2 and 3 the OLD spawn gives **1.345**, worse than the failure that
started the investigation. The spawn change did not break the test, it reseeded it.

Lengthening the window does not rescue it. Worst-case ratio over 8 configurations
(both spawns x levels 1-4) and every window start: 1.420 at 30 s halves, 1.485 at
60 s, 1.305 at 120 s, **1.216 at 180 s**. A maximum is an extreme-value statistic
and converges far too slowly to carry a 15% tolerance -- the tolerance was inside
the sampling noise of its own statistic, which is the whole defect.

The second half of this is worse, and was only found by trying to make the
replacement fail. A saturation test cannot discriminate here **because the
constraint ends in `limit_length(BALL_MAX_SPEED)`**: a runaway does not grow
without bound, it pegs at the clamp and looks saturated. Against deliberately
broken builds -- correct settles at ~44 m/s; the radial correction applied at a
gain of 1.6 settles at ~45 and is **not** caught by any saturation or ceiling test;
impact restitution raised 1.7 -> 2.6 pegs the clamp and is caught on the first
impact. The assertion that ever caught a runaway was the per-frame clamp check
sitting beside the ratio, not the ratio. The documented historical fault (snap the
ball's position, leave its velocity alone) does not even reproduce as a runaway --
re-introduced, it makes the chain *quieter*, 18.6 m/s against 44.

## The rule

Before believing a test that compares two statistics sampled from a simulated
trace, slide its window along a much longer run and count how often it would have
passed. If the answer is not "always", the number it reports is where you sampled,
not what you measured. A tolerance has to be wider than the sampling noise of the
statistic it is applied to, and the maximum of a window is the noisiest statistic
there is -- 30 s maxima from a trace oscillating between 32 and 44 m/s agree
within 15% about three times in four.

And check what a guard clamp does to the thing you are asserting. A value capped
by a `limit_length`, `clamp` or `min` saturates whether the system is healthy or
running away, so "it settles" proves nothing about a quantity that cannot exceed
its cap. Assert against the cap as well, say in the comment which faults the test
does and does not separate, and verify that by breaking the code deliberately and
watching the test go red -- a replacement assertion nobody has seen fail is a
guess.

## Replaces or contradicts

`TESTING.md`, "Rules for the suites":

> - **Assert saturation, not a hand-derived ceiling**, for physical stability.

That is too strong as written, and this game is the counter-example: the saturation
form was a coin flip at one in four, and could not have separated a real leak from
a healthy swing because a clamp caps both. Saturation is the right *question*; it is
only a usable *assertion* when the statistic is monotone (a cumulative maximum, not
a per-window one), when the run is long enough to reach the envelope (here 60 s
peaks at 34 against an envelope of 44 -- it took 240 s), and when nothing downstream
clamps the quantity being watched. Where a clamp exists, a recorded ceiling plus the
clamp check is the honest shape, and the comment must say what it cannot catch.
