# Destruction granularity has to match the rendering STYLE, and the ratio is the number

**Game:** Gravewell. After two rounds of making the dig continuous he still said *"it looks
like it am still breaking through too quickly. im not sure if the ticks need to be smaller or
of you can make the rock break into smaller chunks."*

He was pointing at the right thing and the research names it. Character width against terrain
cell width, from primary sources:

| game | ratio | reads as |
|---|---|---|
| Worms, Liero | ~18:1 | continuous erosion |
| Noita | ~32:1 | continuous |
| Terraria | ~0.5:1 | blocky, on purpose |
| Starbound | ~0.25-0.5:1 | blocky, on purpose |
| SteamWorld Dig | ~1:1 | blocky, by its designer's own account |

**Block games get away with 1:1 because their whole visual grammar is squares.** Gravewell sat
at 0.76:1 while drawing smooth interpolated marching-squares contours, which promises Worms
and delivers Dig Dug. That mismatch was the complaint, not the metres per second — measured,
the drawn face receded at 2.43 ship-widths a second in steps from 0.000 to 0.360 m, with
facets a metre across snapping between frames.

**And it rules out the other half of his guess.** A brush that accumulates continuously into
the field between mesh rebuilds is already sub-tick; a finer TICK changes nothing. Marching
squares cannot draw anything smaller than its own lattice whatever the simulation does. The
limit is spatial, always.

## Only the SHAPE needs to get finer

Material, hardness, yields, light: none of those is a shape. An ore vein is a metre-scale fact
and so is a lit tunnel. One array goes sub-metre and every coarse answer is DERIVED from it in
one direction, through caches that exactly one function writes.

**Pick the factor by measuring the mesh, not by taste.** Four times finer measured 18.1 ms of
mesh rebuild a tick against a 16.7 ms frame; three times is 6.7 ms. Genuinely continuous
destruction is a per-pixel simulation and is not reachable from a marching-squares contour in
GDScript at any setting — the honest offer is "a third the step size", not "like Noita".

## What a sub-cell field breaks, all of which needed a measurement to find

- **The two lattices will be offset.** Metre `x` is centred on `x`, so its fine cells start at
  `x - 0.5`, not at `x`. Getting it wrong does not look like an offset: the ship rides the
  edge of every block it clears (`0.02 0.16 0.57 1.00` across a carved metre) and no cell in
  the game ever becomes passable. Write ONE `fine_centre(n)` and its inverse and use them
  everywhere.
- **A round brush cannot clear the corners of a square cell**, so "this cell is worked out"
  becomes a coarse-scale threshold of its own — and it must be DERIVED from the subdivision,
  never typed in. At 3x3 one leftover corner is 1/9 = 0.111 of the cell; a literal 0.10 that
  had been fine at 4x4 meant nothing was ever finished.
- **Ask the COARSE cell whether it is done, after the carve.** Firing the payout when a fine
  cell hits exactly zero misses the case the threshold exists for: the sum falls under the
  line with no single cell landing on zero that tick.
- **Collide against the isovalue the surface is DRAWN at.** That is the one place the picture
  and the collision can be the same fact instead of two. But it also means rock stops blocking
  long before a cell is finished, so anything that governs speed through material has to
  become an explicit clamp — otherwise the player flies through half-cut rock at full speed.

## Two general ones

**Missing beats stale in any chunked rebuild queue.** Sorting purely by distance starves the
holes: the chunk under the player is dirty every tick and is always nearest, so with a small
budget it wins every frame and a chunk entering the window is never built. Half the screen
went black. Missing chunks get their own, larger budget.

**A colour cache keyed on position destroys per-vertex sampling.** Memoising the vertex colour
per cell for speed re-created a bug this repo had already documented and commented against:
every vertex in a cell gets one answer, the triangles have nothing to interpolate, and the
terrain becomes a grid of flat tiles. Memoise the arithmetic behind the cell the sampler
CHOSE, never the sample itself. Found by rendering the vertex colour straight to ALBEDO after
four layer toggles had ruled out everything else — the layer-toggle rule works, and the term
dump is what ends it.
