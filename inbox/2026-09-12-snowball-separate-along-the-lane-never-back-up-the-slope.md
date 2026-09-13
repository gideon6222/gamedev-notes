# On a track with a direction of travel, a depenetration must never have a component against the direction of travel

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / Feel

## What happened

Snowball's ball is arithmetic in the sim (no physics body). When it overlapped a wall-class object it was pushed out along the contact normal by the overlap each frame - the textbook depenetration. Because the object was ahead of the ball, the normal pointed back UP the slope, so every frame the correction moved the ball uphill by the overlap and gravity moved it down again: a reader wedged between a boulder and the lane edge for over 200 seconds, "rubbing" the edge 343 times, never passing the boulder, and the run only ended at the 240 s cap. It read at first like a stuck policy. Fix: separate SIDEWAYS only - compute the lateral clearance needed at the current downhill position (sqrt(reach^2 - ds^2)), move across to it on the near side, and if the lane has no room there go round the other side - so the slope always keeps the ball moving. The wedge disappeared and the reader finished 6 of 6 seeds.

## The rule

On a track with a direction of travel, a depenetration must never have a component against the direction of travel. Resolve overlaps across the track only, and treat a bot that stops advancing while its inputs keep changing as a wedge, not a policy bug.

## Replaces or contradicts

Apply corrections as a velocity through the normal collision path, never as a position write,
