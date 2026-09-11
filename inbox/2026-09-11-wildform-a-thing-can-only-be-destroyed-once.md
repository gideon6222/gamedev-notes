# Damage that outlives its target is an income, and only a loop simulation finds it

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `CRAFT.md` under progression and
economy, and `TESTING.md` beside the invariance-test rule.

## What happened

An ability called Ember sets a burn on whatever the player shoots: the target keeps taking
damage for three seconds after the shot moves off it. The burn loop ticked every target with
a live timer and applied damage through the same function the shot uses.

The destroy branch looked like this, and had since the day crates were added:

```gdscript
"crate":
    target["hp"] -= dealt
    if target["hp"] <= 0.0:
        target["broken"] = true
        coins += Tuning.coins_per_crate(bought)
```

There is no guard on `broken`. With only a shot hitting it that never mattered - the shot
retargets the instant a crate breaks, so the branch is entered exactly once. **A burn does
not retarget.** It kept ticking the same broken crate, hp went further negative every frame,
and the payout fired **sixty times a second for three seconds.**

Measured: one run of world 4 came home with **19,128 coins against the ~340 it should have
earned**, and the next world clear converted the pile into **1,729 gems** at 100:1. A crate
was paying 675 coins instead of 4.

## Why nothing caught it

Every test in the repo passed. The goldens passed, because they were recorded before the
ability existed and the policies that play them do not own it. The whole-run tests passed,
because **inside one run every number agreed with every other number** - the coins in the
purse really were the coins that had been awarded.

What found it was the balance probe that plays the META loop: run, bank, buy, next world,
forty times. The bug is visible there as one row, and it names its own cause, because the
explosion begins on the exact run Ember was bought.

> A price next to an income is the first thing that shows the income is wrong.

## The rule

**A thing can only be destroyed once, and the check belongs on the thing, not on the
shooter.** Any target that can be destroyed refuses further damage once it is gone - a broken
crate, a passed gate, a taken pickup. Guarding the caller works only for the callers that
exist today.

**And the corollary, which is the part that generalises past this bug: any damage-over-time,
aura, burn, poison or chain effect is a SECOND caller into a path that was written assuming
one.** When a verb changes which callers a payout path has, grep for every payout it can now
reach. This is the same shape as the Gravewell lesson about a new verb changing which states
the player spends time in, applied to code paths instead of states.

## Testing it

**Assert the RATE, not the total.** Coins per crate broken is the quantity the bug changed,
and it is invariant to the layout, the seed and the world:

```gdscript
var per_crate := float(s.coins) / float(broken)
t.approx(per_crate, float(Tuning.coins_per_crate(s.bought)), 0.001, ...)
```

Run it for every combination of abilities that can reach the path, not just the default.
Verified by removing the guard with the test in place: it reported 675 coins per crate.

**And keep a probe that plays the whole meta loop**, not just a run. Dividing a late price by
early income measures a player who never got better; simulating play-bank-buy-next is the
only thing that sees an economy inflate.

## Replaces or contradicts

Extends `CRAFT.md`'s "Contaminated-state bugs need an invariance test". That rule catches a
reward reading state it should not see. This is the sibling: a reward being PAID more times
than it should be, which an invariance test does not catch because both runs inflate equally.
The rate test is what separates them.
