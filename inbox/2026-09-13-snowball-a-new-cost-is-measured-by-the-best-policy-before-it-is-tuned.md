# A new cost is measured by the best policy before it is tuned

**Game:** snowball  **Date:** 2026-09-13  **Belongs in:** CRAFT.md / stakes / pressure the player causes, or balance measurement and TESTING.md / policies as the definition of playing well

## What happened
Snowball added "a sled aboard makes the ball slide a little wider" (plan addition (a)): a stuck sled lowers the heading rate by SLIDE_WIDEN times its share of the ball. The first number, 0.35 (a quarter slower turn with one sled on a 1 m ball), read as "a little" in the code and killed the best policy: the reader, which finished six seeds of six with a mean of 551 snow before the change, lost seed 1 to a wall at 466 m and fell to 393. Two things worth keeping. (1) The golden test caught it in the same run as the change, but the golden only says "the simulation changed"; the balance probe (run_probe.gd, every policy over six seeds) is what said how much and for whom, in one table, and comparing three settings (off, 0.35, 0.2) took three probe runs of about two minutes. At 0.2 (14% per sled) the reader finishes six of six at 555. The human policy was chaotic across the three (2, 4, 2 finishes) and said nothing, which is a reason to read the reader, not the human, for a balance question. (2) The first hypothesis was that the reader's planner did not know about the slide, so the planner was given the sim's real turn rate (one function, Sim.steer_rate_now, read by the step and the bot) and the reader died at exactly the same state to three decimals. That identity proved the mechanic, not the plan, was the cause, and it is the cheapest experiment available: change the observer, and if the outcome does not move the observer was not the problem.

## The rule
When adding a new cost or constraint, measure its impact using the best policy over a full probe's seeds before the constant is kept. A constant whose comment says "a little" or similar unquantified language must have a probe comparison row next to it, because that language reflects the developer's intuition, not data. Read the automated policy for balance questions, not the human player trace, because human play is chaotic and obscures the actual effect.

## Replaces or contradicts
7. **Measure, do not guess.** If a rule reads like a caution, measure the number and replace
