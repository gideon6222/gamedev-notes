# The best pressure is one the player causes, and the arithmetic should be the physical story

**Game:** Gravewell, building Drown, the water world.

Every other pressure in the game arrives on a schedule — the air thickens with depth, the hull
drains past a threshold, the collapse rises on a clock. All of them happen whether the player
acts or not, so none of them is a decision. **Drown's water rises because the player cut the
rock**, and sitting still costs exactly nothing. That single inversion makes over-digging a
real cost and makes the way home worse than the way down.

**Derive the number from the physical story and the tuning writes itself.** Saturated rock
releases the water it was holding into the void network; the network is a shaft about a metre
across; so a cell's worth of released water raises the level by roughly the cell's water
fraction. Fifteen per cent puts a full descent at about twenty metres of rise. No playtest was
needed to pick it and the comment explaining it is the derivation.

**Derived, never stored.** The table is a constant and the rise is a count times that number,
so filling a room back in puts the water back exactly where it was and no state can drift.

**Count against the ORIGINAL threshold, not the moving one.** Counting cells below the RISEN
surface makes the rise feed itself: every metre the water climbs past counts as newly opened
under it and raises it again. A flood with no upper bound, from one word.

## The recurring fault, for the third time: asking whether a cell is "open"

`submerged_at` asked whether the metre the ship was in was open. **The metre a ship is standing
in is the metre it is cutting**, and that one is never finished — so the ship drilled twenty
metres under the surface and the game called it dry.

This is the same shape as two earlier faults in the same repo: a lamp buried in the rock it was
cutting got no light because the spill only took from open neighbours, and a ship was wedged
by slivers because collision asked about whole metres. **Once a mechanic puts the player INSIDE
material, every "is this cell clear" test written before that mechanic is suspect.** The right
question is usually simpler: the ship can only ever be somewhere it fits.

## And an unlit surface needs to still be a surface

Flat rectangles had been appearing over the rock and survived four layer toggles. They were not
geometry at all: the light spill carries one cell onto a wall, so beside a one-metre shaft the
lit band has a hard edge, and beyond it only the ambient floor was left — **a flat colour with
no normal map on it**. Unlit rock therefore had no relief, and the boundary read as dead colour
laid over stone rather than as the limit of the lamp.

Put the surface term on the ambient as well as on the lit part. The edge of the light then
becomes a change in brightness instead of a change in whether the rock exists.

Found by rendering the spill straight to ALBEDO. The layer-toggle rule narrows it down; a term
dump is what actually ends it.
