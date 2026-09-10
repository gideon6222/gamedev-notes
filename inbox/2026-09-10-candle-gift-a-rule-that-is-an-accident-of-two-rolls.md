# A rule that depends on two independent rolls agreeing is not a rule, and both ways of writing it fail

**Game:** candle-gift  **Date:** 2026-09-10  **Belongs in:** `CRAFT.md` / difficulty and balance

## What happened

Money in Candle Gift became three denominations off the reference's own price tags, with one
rule attached: **a tag above the smallest is never lying in open road.** Money should be a
decision, not something you drive over.

That rule was written twice and both versions were wrong in opposite directions.

**First: the tier read an intent flag.** `guarded` was rolled before the obstacles and the
tier read it. But the barrier that does the guarding has its own independent chance and does
not spawn at all before chunk five, so a note could be marked guarded and lie on empty track.
Big tags on open road.

**Then: the tier read the outcome.** Made to depend on a barrier that had actually spawned, it
now needed three rolls to agree - cash, guard, barrier - and big tags stopped appearing at all
across four whole levels.

Both are the same mistake. The rule was an emergent property of two decisions that did not
know about each other, so it was either violated or never satisfied, and tuning the numbers
moved it between those two failures without ever making it true.

**The fix is to invert the causality.** Roll the tier first, and let a tier above the smallest
PLANT its own barrier whatever the ordinary barrier roll says. The rule is then true by
construction and there is no number that can break it.

## The rule

**When a design rule says "X is always accompanied by Y", one of them has to cause the other.**
If X and Y are decided by separate rolls, the rule holds only when they happen to agree, and
the frequency of the exception is a number nobody chose. Decide the one the player cares about
first and let it create the other.

The diagnostic: if the rule can be stated as "X and Y both happened", it is not a rule. A rule
reads "X, therefore Y".

**And the test has to look at the ground, not at the hash.** `test_every_big_tag_is_behind_a_
hazard` plays four levels and checks what actually exists near each tag. A test that re-derived
the pairing from the same hash the spawner uses would have agreed with both broken versions.

It also needs its own fixture assertion. The second failure - big tags never appearing - was
caught only because the test asserts the thing it is about was present at all ("no big tag
appeared across four levels"), which is the standing "a construct that cannot fail is untested"
rule applied to the fixture rather than to the code.

## A second thing, about scope

The test's first draft flagged tags lying in open road that were fourteen metres BEHIND the
batch. A barrier sits a metre nearer than the tag it guards, so it retires one frame earlier,
and for that frame the note has no obstacle beside it. That is a real transient and not the
rule breaking.

**State a rule over the range where it means something.** This one is about tags the player can
still choose to go for, so it judges tags ahead of the batch. A guard that fires on states the
player can no longer act in trains people to widen thresholds until it stops meaning anything.

## Replaces or contradicts

Nothing states this. It is adjacent to `CRAFT.md`'s "name the setting where a condition fires
about half the time before building it" - the same family, where the honest question is not
what the number is but which decision owns it.
