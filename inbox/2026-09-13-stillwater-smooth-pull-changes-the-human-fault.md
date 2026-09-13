# When a mechanic stops punishing reflexes, re-derive the human bot's fault or it becomes an expert.

**Game:** stillwater  **Date:** 2026-09-13  **Belongs in:** CRAFT.md / Difficulty and balance

## What happened
Stillwater's seventh fight replaced the run's one-frame kick with a pull that ramps over half a second and rises at most 1.6 per second. The HUMAN bot's only faults were a 0.3 s reaction lag, a 0.15 s hand lag and a coarse thumb, all of which the earlier kick punished. Against a smooth pull, lag costs a little line and nothing else, so HUMAN held the rod to two hundredths under the red on every pull, which is expert play, and the balance table read 100% landed in five of six bands, including the Quarry at 88 to 100%. The instrument was reporting an expert, not a person. Moving HUMAN's let-go valve to twelve hundredths under the red (caution, the plausible fault against a slow rise) gave the ladder back: 100/100/100/100/92/54.

## The rule
When a mechanic changes what it punishes, rewrite the bot's faults before reading any balance number, and say in the bot's own comment which fault each measurement is verifying. Re-measure balance in the quantities the new mechanic charges, not the currencies that worked for the old one.

## Replaces or contradicts
- **When a binary control becomes proportional, re-measure balance in the quantity the new control moves** (strain, line given), not just land rates by band: the cost of ignoring a warning can migrate to a quantity that recovers between episodes, so land rates look fine while the risk model breaks underneath (Stillwater, M).
