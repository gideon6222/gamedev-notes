# A scripted policy has ONE decision-maker; a reflex layered over a planner disagrees at the boundary and the bot dithers there

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** techniques/human-bot-policies.md / sweep the bot's parameter before the game's

## What happened

Snowball's reader policy had two decision-makers: a planner scoring thirteen lateral candidates across the lane (food gain, penalties for anything non-food the ball would sweep through on the way, with a time-to-clear check), and a reflex on top ("a wall on my current line inside the lookahead: lean fully away"). Traced frame by frame on seed 1 at 27 s: the planner decided to cross in front of a standing pine with 34 m to spare, the reflex fired at 32 m and aborted the crossing, the planner re-planned it, and the wanted strip flipped between -1 and +1 every 0.7 s until the ball met the pine on its shoulder at full speed. The pure reader died on 3 of 6 seeds this way; the same trace showed the lean never settling. Removing the reflex and letting the planner's time-aware penalties be the only judgement (the lean it asks for is the brake) made the reader finish 6 of 6 and the dodger 5 of 6. A second version of the same fault: penalising every crossing regardless of time left a dodger frozen under the first tree because every candidate scored the same and "prefer not to move" won the tie - the penalty had to scale with the shortfall so the least-bad line still wins.

## The rule

A scripted policy has ONE decision-maker. A reflex layered over a planner disagrees with it at the boundary of the thing it reacts to and the bot dithers there. Put every consideration into the planner's score, scale penalties by how badly a line fails rather than binary, and trace a death frame by frame (position, speed, wanted input, applied input, the objects ahead) before touching any game constant.

## Replaces or contradicts

Sweep the bot's parameter before touching the game's.
