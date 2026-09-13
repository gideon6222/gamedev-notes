# A scripted policy may not move an input faster than the filmed thumb is allowed to

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** techniques/human-bot-policies.md / modelling the input device

## What happened
Snowball's six scripted policies drive the sim through `Sim.steer_to(strip)` and the filmed bot drives it through `scripts/replay_player.gd`, which clamps a drag to 54 px per frame on a 1080 px width (a third of a second to cross). The pure suite measured the reader finishing every seed; the same reader filmed through the real thumb seam died at 27 s on a tree the pure one cleared, on every attempt, because the pure policy set the strip from -1 to +1 in one frame and the thumb needs 18. Every balance number - shatter threshold, trail spacing, tree placement - had been measured for a thumb that teleports. Fixed by giving `Policies.apply` the same clamp as the driver, derived from the driver's constant through the game's own `drag_by` conversion (`THUMB_STEP = 54 / 1080 * 2 / 0.9` strip units per frame), so the pure suite and the film agree by construction. Re-measured: the reader still finishes 6/6, the dodger 5/6, the human 2/6, and the wall-contact median moved from 10.3 to 11.1 m/s, which moved V_SHATTER.

## The rule
Take the rate limit from the same constant the film driver uses, converted through the game's own handler, and re-measure every balance number after adding it - the pure and filmed players must be the same player. Measured: pure reader 6/6 finishes vs filmed reader 0/8 shots before the clamp; median wall-contact speed 10.3 before, 11.1 after.

## Replaces or contradicts
(model the input device, not just the decision; memory that lags reality by a reaction time;
