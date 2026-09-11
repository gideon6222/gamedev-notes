# A ray fan's starburst is fixed by filtering the OUTCOME, never by more rays

**Game:** Gravewell. His words: *"there appears to be multiple separate beams when using the
light on certain settings rather than a glow that extends from the front of the ship"* and,
in the same message, *"the light also appears to get caught on the edges of tunnels that I
have made because they have random edges that stick out."* **Those are one artefact seen
twice**, and they had one fix each: a feathered dig brush removed the protrusions, and a
bearing filter removed the rest.

## The mechanism

A 256-ray shadow fan stores a distance per bearing. Sampling it with one linearly-filtered tap
blends the two nearest rays' DISTANCES. Two adjacent rays that hit different occluders store
wildly different distances, so the blend lands at a distance neither of them measured and the
boundary draws as a hard-edged wedge.

**Filter the lit-or-not ANSWER across several bearings instead** - percentage-closer
filtering, which is exactly what Godot's own 2D light shadows do (PCF5 / PCF13 plus a small
"Filter Smooth" post-blur). Five taps, spread a little under a ray each and widening slowly
with distance.

Measured on a field of single-cell pillars at nine metres:

| taps | worst jump between neighbouring bearings | boundaries stepping > 0.5 | first wall lit |
|---|---|---|---|
| 1 | 1.000 | 22 | 0.98 mean, **0.00 darkest** |
| 5 | 0.200 | 0 | 0.75 mean, 0.40 darkest |
| 7 | 0.143 | 0 | 0.72 mean, 0.43 darkest |

**Raising the ray count is not the fix.** The reference writeup reports 50 to 360 rays still
looking jittery, and it is the most expensive option on a mobile GPU, where the extra texture
taps are nearly free. Seven taps buy nothing anyone can see over five.

## Three things that only showed up in the measuring

**The mean was the wrong statistic.** Mean jump across the ring moves 0.092 to 0.082, because
the number of boundaries is identical either way. The WORST jump separates them cleanly. First
statistic tried, does not discriminate, nearly concluded the filter did nothing.

**The first attempt measured nothing at all**, because it was pointed at a freshly carved
tunnel - and the feathered brush from the same day had already made that smooth, so there was
no artefact left for the filter to be tested against. A fixture for an aliasing artefact has
to be deliberately ragged. A frame that shows no difference between two builds is not evidence
that they are the same.

**A filter that improves the picture will fail a threshold test that was passing.** The
existing "the first wall is lit, not in its own shadow" test counted samples over 0.5 and
allowed 5%; with a filter that answers in fifths it went to 10.4% and read as a regression on
a fan that had got strictly better. Worse, the single-tap version had been passing with the
darkest wall sample at **0.00** - genuinely black - hidden inside the allowed 5%. Assert the
mean and the DARKEST, not a count over a threshold: a binary count cannot tell a penumbra from
a hole.

## And expect the lighting change to publish the geometry

Lighting a previously black tunnel exposed a normal map projected in world XY, parallel to
every wall of a Z-extruded mesh, which had streaked every ceiling for nine versions. Any
change that lifts the black floor is also a change that publishes what the darkness covered.
