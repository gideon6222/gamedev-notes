# One is not three: a long play finds cascades a unit test cannot

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites

## What happened

A campaign system where running a meter dry costs you a region of the map. The
unit test for it was careful and it passed:

```js
test('a collapse leaves a planet you can come back from', () => {
  // the meter is not left at zero, so the next drain does not take another
  // region immediately; the region comes back part-angry, not clean
});
```

Then a probe played a whole campaign through the shipping loop and stopped dead
on run 22: **one objective lit, three regions down, the meter pinned at zero,
eighteen credits, and nothing changing for six more runs.**

**The test proved a single collapse recovers and said nothing at all about
three.** Each collapse removes ground you earned in, which makes the meter
harder to fill, which takes the next region. The cascade has its own logic and
no single-step test can see it.

## The two fences it needed

1. **A floor on concurrent losses.** Three at once is as broken as the world
   gets; past that an empty meter is simply an empty meter.
2. **Never bury the objective.** A region holding an objective the player has
   not reached yet cannot be taken - burying it behind a price they may not be
   able to pay is a hazard taking the run. Once they have had their prize out
   of it, the region is fair game.

## The general shape

**A test that steps a system once proves the step. It cannot prove the
sequence.** Anything with feedback in it - a meter that costs you the means to
refill it, an economy that prices off its own output, difficulty that scales
with progress - needs a probe that runs the loop dozens of times, and the
assertion is *does it still have a way forward*.

Cheap version: run the pure system in a loop in a unit test until it stops
changing, and assert the terminal state is recoverable. That would have caught
this one without a browser.

## And the probe has to actually play

The same probe was useless twice before it was useful, both times because its
POLICY was not play:

- it dug down for a fixed two minutes every run, ran the tank dry, lost the
  hold, and banked nothing for eight runs - while the meter drained on
  schedule. It looked exactly like a balance problem. **It was ignoring the one
  warning the game shouts at you.** Given a "turn back when the game says
  danger" rule, the same build kept the meter full and climbed.
- it held the d-pad for `|dx| * 2 + 4` seconds to move `dx` columns, which at
  three cells a second is eighteen cells of overshoot. It spent thirty-three
  simulated minutes digging shafts eighteen columns from the thing it was
  aiming at.

**A bad player is a useful probe; an incoherent one is noise.** Write the
policy as the rules the game itself teaches, and drive movement to a
CONDITION rather than for a duration.


## The rule
A test that steps a system once proves the step, never the sequence. Anything with feedback
in it - a meter that costs you the means to refill it, an economy priced off its own output -
needs a probe that runs the loop dozens of times, and the assertion is "does it still have a
way forward". The cheap version is a unit test that loops the pure system until it stops
changing and asserts the terminal state is actionable; that runs in a millisecond and asks
the same question a browser probe took four simulated hours to answer.

And a probe's policy must be the rules the game itself teaches. A bad player is a useful
probe; an incoherent one is noise. Drive movement to a CONDITION, never for a duration.

## Replaces or contradicts
Extends this line in TESTING.md / Rules for the suites: "**Golden over a whole run, with
policies.** `test/policies.gd` is the definition of "playing well" and lives in the repo."
That says a policy has to exist; it does not say the policy must obey the game's own
warnings, and a policy that ignores them produces numbers that look exactly like balance
faults.
