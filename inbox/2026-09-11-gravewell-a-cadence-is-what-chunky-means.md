# "Chunky" is a cadence, not a curve, and smoothing each step does not touch it

**Game:** Gravewell. His words after the first phone session: *"digging feels very rigid and
chunky. while I am digging, it takes large chunks out, slows me down, then speeds up. I would
rather dig at a more consistent speed ... instead of taking longer to destroy a chunk I would
like it to continously plow through but get slowed down on denser materials."*

The drill aimed at ONE grid cell, spent `fill * hardness / rate` seconds taking it to zero,
and refused to let the hull move until it was gone. Every individual step was already
smoothly interpolated. **He feels the period, not the shape of one step.**

**The rule: anything that gates the player's motion on completing a discrete unit of work
reads as chunky, however smooth each unit is.** Check for the gate before reaching for an
easing curve.

## Derive the speed from the bill

Advancing one metre removes one cell of fill, which costs `hardness` hit points, so

    plow speed = drill power / (hardness * HP_PER_METRE)

One identity, carrying three things that would otherwise drift apart: the deep is slower, the
power cost per metre is unchanged by the rework, and **the drill can never advance faster
than it clears**. Measured: 1.55 m/s against 1.26 before, with the deepest rock 4.6x slower
than the surface, which the genre research puts inside the readable 4:1 to 6:1 band (past
that, players report "stuck" rather than "slow").

## Two ways that identity got broken, both of which let the ship through solid rock

1. **A floor under the speed.** Added on the research's advice that a drill reaching zero
   reads as a dead input. It is a licence to move through material that has not been cut: a
   scripted miner drove straight through a planet's core without cutting it and ended forty
   metres below, the core sitting at fill 0.39. **A floor like that is a property the content
   table must KEEP and assert, never a clamp that is applied.**
2. **Sampling the hardness a metre ahead of the hull.** The reading fell back to ordinary rock
   the moment the ship was ALONGSIDE the hard thing rather than approaching it. Sample at the
   leading FACE: time-in-cell times power then equals the cell's cost by construction.

## Plowing means the hull is inside rock, and that needs depenetration with two bounds

The ordinary collision resolve has nothing to push against when the START position is illegal,
so it refuses every direction and the ship is wedged in its own tunnel the moment the player
lets go. Both first attempts were wrong:

- **Bound it to "the drill is off".** Letting velocity through as well let a miner cover 37 m
  in ten seconds and leave the whole shaft standing behind it, unpaid for.
- **Use a CONTINUOUS measure.** An overlap count is flat across most of a cell. An overlap
  AREA is flat too when the hull is smaller than a cell (0.76 m in a 1.0 m cell covers the
  same area wherever it sits). Measured: the ship escaped 0.2 m and then sat there with its
  velocity zeroed. Sampling the fill bilinearly at the hull's corners moves on every
  millimetre - and it is the lattice the contour already uses, so it is one source of truth.

## The effects that sell it

One number in the sim, `dig_load` 0..1, zero when not drilling, read by the drill loop's
volume/pitch/grit rate, the haptic cadence and the camera tremor. Four channels agreeing is
what makes effort read; four curves is mush.

**A continuous drill has to be a LOOP.** The old one-shot per bite fired once or twice a
second under a per-cell model and would be sixty a second under a plow. Android's own guidance
for continuous haptics says the same: one persistent effect that is modulated, never a
retrigger per hit. `Input.vibrate_handheld` has no amplitude stream, so the nearest honest
thing is a short pulse re-issued at a period that shortens with the load.

Generate the loop rather than sampling one: its pitch is driven every frame, and a recorded
drill has its own pitch baked in and fights the modulation.
