# A fixture where everybody wins cannot tell you who is better, and a meta-loop probe finds the walls no single run can

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `TESTING.md` under policies and
fixtures, and `CRAFT.md` under progression and prestige.

## What happened

Adding dual-type bosses to worlds 5-8 needed one balance test: *does the reading policy still
separate from the greedy one?* That is the claim the whole game rests on.

The first version picked one seed, gave all four policies a fully bought-out loadout, and
compared boss damage. It reported **all four dealing byte-identical damage, to eight decimal
places** - reader, greedy, gatherer, and the dodger that never feeds a gate at all.

Nothing was broken. At a bought-out ladder every policy kills an 864 HP boss, so every run
ends at the same number: the boss's health. The fixture had no headroom left to measure in.

Re-measured at the loadout a player **actually arrives at that world with** - coin ladder wiped
by the clear that got them there, gem tree as far as the progression probe says it is - the
spread came straight back: reader 254.8, greedy 249.3, gatherer 214.5, dodger 208.0, meaned
over twelve seeds.

## The rules

1. **A fixture where every policy succeeds measures nothing.** Before trusting a policy
   comparison, check that the losers actually lose in it. Identical results across policies
   that differ sharply elsewhere is the tell, and it means the fixture, not the game.
2. **Give a policy the loadout its player would really have at that point**, taken from the
   progression probe rather than from what seems fair. Over-equipping flattens the field;
   under-equipping makes everything fail. Both read as "no difference".
3. **Never compare policies on one seed.** One seed's gate layout can offer no real choice at
   all, so two different policies converge on the same arrival type and deal the same damage.
   Mean over a spread; assert the ORDER of the whole field, not a single gap.

## The other half: a probe that plays the meta loop finds walls no run can

The same session's progression probe - play a run with the reading policy, bank, buy what is
affordable, repeat, for eighty runs - reported something no single-run test could have:

> world 7, **thirty-two consecutive runs**, 1,134 damage against 1,574 needed. Coin ladder
> fully bought out. Every gem ability owned since run 30. **15,730 coins on hand and nothing
> on any shelf to spend them on.**

Every individual run was fine. Every unit test passed. The game had simply stopped having a
progression: the player's power had a ceiling and the difficulty did not.

**So: every prestige game needs one permanent rung with no top on it**, priced on a curve that
rises forever, bought with whatever currency the stuck player has too much of. And the
structural claim is a one-line test on two constants:

```gdscript
assert(BLOODLINE_PRICE_STEP < BOSS_HP_STEP)   # 1.30 < 1.35
```

If the permanent rung's price rises faster than the difficulty, every world buys fewer ranks
than the last and the player falls behind forever. Slower, and the wall is always eventually
breakable. That inequality is worth writing down in any game where difficulty compounds.

## Replaces or contradicts

Extends the existing rule that a late price must not be divided by early income but PLAYED.
The addition: play it far enough to find the point where the curve stops, not just far enough
to price the next purchase. Eighty runs found a wall that twenty did not - the old probe
stopped at world 5 because world 5 was the end of the content, and so it could never have
reported this.
