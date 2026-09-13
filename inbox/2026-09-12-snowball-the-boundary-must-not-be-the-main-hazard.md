# The boundary costs speed or a signal, never the scored resource, and must not become the game's main hazard

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / Difficulty and balance

## What happened
Snowball's plan made the lane edge a shove: the ball bounced off, lost half its speed and shed 12% of its radius, "never a shatter". Measured with the balance probe over six seeds and six policies: every policy took 4 to 10 edge hits per run - more than any object hazard - and the reader's growth went as 0.88^5. The bots lean fully toward a lateral target and overshoot into the edge; a human thumb does the same. The boundary had become the game's main hazard, and it is the one hazard the level designer did not place. Changed to a RUB: the ball is held inside, its heading is squared up to the slope, it loses speed while it touches (0.9 per second as a fraction) and sheds nothing; the "shoved(edge = true)" signal still fires once per cooldown for the rumble. After the change the reader finished 6/6 seeds and edge contacts stopped costing growth.

## The rule
The play-space boundary costs something the player can feel (speed, a rumble) and never the resource the game is scored on. Count boundary contacts per run with the bots before counting hazard contacts; an unplaced hazard that fires ten times a run is the difficulty curve whether or not anyone designed it.

## Replaces or contradicts
- Everything dangerous lives inside the steerable band, routed through one lane helper. Write
