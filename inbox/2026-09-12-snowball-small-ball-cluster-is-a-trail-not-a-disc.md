# When the avatar is small next to the field, put pickups in a line the player can follow, never in a scattered disc

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / Level and world design

## What happened
Snowball's plan put "clusters" of pickups in a 6 m disc on one side of the lane (5-9 things) for a ball of 0.5 m radius. Measured with the balance probe over six seeds: the greedy and reader bots took about ONE pickup per pass through a cluster, and the reader ended the whole 900 m mountain at 1.37 m with 19 lumps. The reason is geometric: a small ball sweeps a strip 2r wide (1.2 m) through a 113 m^2 disc holding 7 things, so the expected contacts per pass are under one. Rebuilt as a TRAIL - the same things in a line down the slope with jitter (0.4 m in the first band), sorted small to large so the ball grows up the line and what was a shove at the top is food by the time it arrives - the reader ended at 2.4-5.6 m with 80-140 lumps on the same seeds. The trail is also better design: a line the player finds and follows is a decision, a disc is a place you touch.

## The rule
For a ball small next to the field (0.5-1.0 m radius), put pickups in a line sorted small to large so the player finds and follows one path as they grow; never a scattered disc. Measure contacts per pass with a bot before placing growth thresholds: expect ~1 per disc pass vs 6-10 per trail pass, and end-radius will span 1.37 m (disc, 19 lumps) to 2.4-5.6 m (trail, 80-140 lumps).

## Replaces or contradicts
- Put the reward on the ground with extent, give the player a formation with lag, and let the
