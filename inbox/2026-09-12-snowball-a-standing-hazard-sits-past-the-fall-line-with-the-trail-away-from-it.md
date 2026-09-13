# A hazard that must punish the do-nothing line sits just past that line, never on it, so the open side is guaranteed by construction rather than by luck, and the reward line for that stretch goes on the other side; the first such hazard comes after the first win.

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / Level and world design (beside "An obstacle anchored to the track edge guarantees its own gap")

## What happened
Snowball needed the fall line to be unsafe (doing nothing must lose), so a standing pine (footprint radius 2.5 m) was placed at the lane centre every third chunk, in a 12 m treeline lane. Measured over six seeds: it spanned five of the twelve metres, a 0.9 m ball had 1.7 m of room on one side, the chunk's pickup trail (placed on a hashed side) ran straight into it half the time, and the reader bot died on the tree's shoulder while the dodger froze under it with no candidate line clear. Two placement rules fixed it without touching a single tuning constant: the tree stands with its NEAR edge 0.4 m past the fall line (x = side * (size - 0.4)), so the fall line still clips it and the far side of the lane is always open by the whole lane width minus 0.4 m; and the chunk's trail goes on the side AWAY from its tree (side = -tree_side) so the greedy line and the hazard never share a side. Also the first one stands at chunk 6 (180 m, 16 s), after the first tier crossing has taught the rule; at chunk 3 it killed every fall-line bot at 11 s, before the first win.

## The rule
A hazard that must punish the do-nothing line sits just past that line, never on it, so the open side is guaranteed by construction rather than by luck, and the reward line for that stretch goes on the other side; the first such hazard comes after the first win. Measured: reader 3/6 finishes with the tree centred, 6/6 with it past the fall line; idle dies at 18 s either way.

## Replaces or contradicts
- An obstacle anchored to the track edge guarantees its own gap; its hitbox derives from the drawing.
