# A held button settles at rise/decay, and if that lands inside the safe band the fight has no player in it

**Game:** stillwater  **Date:** 2026-09-10  **Belongs in:** `CRAFT.md` under difficulty and balance, beside the risk-dial line

## What happened

Stillwater's fight was tap-to-raise-a-needle, keep it in a green band. The player asked for a
dedicated hold button instead of tapping anywhere. Same arithmetic, one control: tension rises
at `HOLD_RISE` while held and decays at `DECAY * tension` while not.

`HOLD_RISE` was derived from the old tap rate so the pace would not change - a tap put 0.058 on
the needle about 2.4 times a second, so 0.139/s covers the same ground. Correct arithmetic,
and it broke the game: a held button settles where rise balances decay, `HOLD_RISE / DECAY`,
and that is **0.60 - inside the safe band**. Holding the button down parked the needle in the
green and landed the fish with no further input.

That is the "one correct sustained input" that had already killed an earlier version of this
same fight, arrived at from the opposite direction, while adding a feature meant to improve
things. The settle point is now above `TENSION_MAX`, so a held button always ends in a snapped
line and the player must modulate a duty cycle.

**What caught it was not a test of the mechanic.** It was the standing invariant that every
scripted policy must fail for a different reason: two bots that differ only in whether they
watch the warning posted an identical 5.83 caught / 0.00 lost.

**And the test that should have caught it could not.** `test_there_is_no_setting_that_wins_on_its_own`
checked two tap rates, zero and thirty, and passed. Swept across the whole range it would have
failed - tension settles in proportion to input rate, so SOME middle rate has always parked the
needle in the band. That was as true of the tapping version as of the hold; the test had simply
never been asked. It now sweeps eleven duty cycles.

## The rule

**Any control that raises a value against a decay has an equilibrium, and you own it whether or
not you chose it.** Compute `input_rate / decay_rate` before shipping and check where it lands
against the band the player is supposed to work to hold. If it lands inside, there is a setting
that wins and the minigame is decoration.

**When a control changes, the property to re-derive is the equilibrium, not the pace.** Matching
the old feel is the obvious thing to preserve and it is not the load-bearing one.

**A "no setting wins" test must sweep the range, not the extremes.** Two ends is what a fixed
input looks like when you already believe the answer; the failure lives in the middle, and it
is the same shape as any threshold-crossing bug.

**And a claim about difficulty must be measured on a fish that is difficult.** The same sweep,
run against the opening tutorial fish, reported a fixed duty landing it about as fast as active
play - which is what a tutorial fish is FOR. Pointed at a deep-water species it separated
cleanly.

## Replaces or contradicts

Nothing directly. It is the concrete case for the existing CRAFT line "one knob that swamps the
others is a design bug, not a tuning problem", extended to a knob nobody typed: the equilibrium
of a held control is a design constant that exists whether or not it appears in the file.
