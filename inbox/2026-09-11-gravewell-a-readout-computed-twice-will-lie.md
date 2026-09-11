# A readout computed separately from the rule will eventually lie, and a picker needs to be an averager

**Game:** Gravewell, building the fourth world class.

## Two copies of one formula, in plain sight

`pressure_rate()` returned the hull drain per second for the HUD's readout and for the
vignette. `_pressure()` did the damage. **Both computed the same arithmetic independently**, and
nothing made them agree — so a new class with a different pressure rule would have been shown
one number and charged another, silently.

This is the third instance of the same shape in one repo: two thresholds for "gone", a ray fan
cast to one range and decoded against another, and now this. **The rule: one function computes
the quantity, one applies it, and the test asserts the applied equals the displayed.**

```gdscript
for id in ALL_CLASSES:
    var rate := sim.pressure_rate()
    # ... run exactly one second ...
    t.approx(hull_lost, rate, rate * 0.08, "%s shows %.3f and loses %.3f" % ...)
```

That test caught a second fault the moment it existed: `pressure_rate()` read a cached flag
that only `step()` refreshes, so **any caller outside the tick got last frame's answer** — a
test, a probe, a HUD built before the first frame. A derived quantity should be a pure function
of state, not of when you ask.

## A "most X" picker is a tie-break waiting to be seen

A vertex-colour sampler took the **single most solid** of the four cells touching a point, so a
mineral vein would hold its colour right up to the tunnel edge instead of being washed out by
the air beside it. Good rule, real reason.

But four untouched cells is a tie, broken by scan order — and that is most of a planet. It was
invisible for months because every cell was contoured and the vertices were dense enough to
blend anyway. The moment a performance pass drew untouched rock as **one quad per cell**, the
four corners each picked a different neighbour and the wall came out as a patchwork of
cell-sized blocks in colours nothing nearby was made of.

**Weighted average, not pick.** Weighting by how much material each cell still has keeps the
property the rule existed for — air weighs nothing, so the vein still holds its edge — and adds
the one it was missing: two neighbouring quads agree about the corner they share, which is what
makes a flat-shaded surface read as continuous at all. The special case that must win outright
(here, a cache showing through one layer of rock) is an override, not a tie-break.

**The general form: any "take the best of N" over data that is frequently uniform is a hidden
dependence on iteration order.** It will surface the first time the geometry that was hiding it
changes.

## And a sentinel needs its sign checked against the axis

"This world has no water" parked the water surface at -1e6. Depth grows *downward*, so that is
above the entire planet and every class rendered as submerged. Park a "never" sentinel at the
end of the axis it lives on, and assert it: the smoke run now checks the parking spot is below
the core rather than above the sky.
