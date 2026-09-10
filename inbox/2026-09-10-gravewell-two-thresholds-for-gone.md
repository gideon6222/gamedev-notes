# Two thresholds for "gone" that do not agree, twice in one file, and the second one was invisible

**Game:** gravewell **Date:** 2026-09-10
**Belongs in:** `CRAFT.md` under deriving the picture and the score from one
state, and `TESTING.md` beside sweeping a parameter to find a gap.

## What happened

A destructible cell holds a `fill` from 1.0 (solid) to 0.0 (cut away). Two
different pieces of code decided when it was gone:

```gdscript
func is_open(x, d) -> bool:
    return fill_at(x, d) <= Tuning.OPEN_FILL      # 1e-4, a float tolerance

func cut(...):
    ...
    if fill[i] > 0.0:                             # exactly zero
        return out
    out["broke"] = true
    mat[i] = Ore.AIR
```

There is a gap between them. A cell whose fill lands in `(0, 1e-4]` is
**passable and has never broken**: the ship flies through it, the drill moves on
to the next cell, it never yields its ore, and `mat` still says what it was made
of forever.

Whether a cut lands in that gap depends on the arithmetic of `hp / hardness`
against the remaining fill, so it is a property of the numbers, not of the code.
It never happened on the first world class. It happened constantly on the second,
whose hardness multiplier is 0.5.

**The symptom was nothing like the cause.** A scripted miner on the new class
reached 15 m in forty seconds and mined nothing at all. It was ping-ponging
between two cells it had already dug out, because those cells still reported
themselves as iron and its "go toward the ore" rule kept sending it back and
forth between them. Three plausible explanations were reasoned about first: the
new class's falling ceilings trapping it, the ship ending up inside rock, and the
bot oscillating on a rounding boundary at a cell edge. All three were consistent
with what was on screen and none was true.

## The rule

**One threshold, named once.** If two pieces of code both decide whether
something has gone, they will disagree eventually, and the disagreement is a
value neither of them can see. The fix is not to make the numbers match; it is
for the second one to read the first one's constant.

This is the **second** time the same file got this wrong. The first was worse and
louder: passability used 0.5 while the drill broke at 0.0, so half-cut cells were
flyable, nothing in the game ever broke, and a miner dug to 86 m and mined zero
kilograms. Both times the failure was total, silent, and looked like a bug in
something else entirely.

## What actually finds it

**Sweep the parameter that decides whether the gap is entered.** The test that
catches this cuts every cell with eight different bite sizes across two classes
and five depths, and asserts the property directly:

> a cell that is passable has always broken, and a passable cell reports no
> material.

A single bite size passes, because a single bite size either lands in the gap or
does not. `TESTING.md` already says a construct that cannot fail is untested; the
companion is that **a construct that fails only for some inputs needs those
inputs enumerated, not sampled once.**

And the process half, which cost more than the fix: three rounds of reasoning
about plausible causes, then one print of the cells around the stuck ship, which
showed `mat=2 fill=0.00` and ended it immediately. Print the state before
theorising about it.
