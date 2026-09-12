# A discrete verb made continuous: the plow, its granularity, and the numbers that moved

**Gravewell, 2026-09-11, three rounds.** His words across two phone sessions: *"digging feels
very rigid and chunky ... instead of taking longer to destroy a chunk I would like it to
continously plow through but get slowed down on denser materials"*, then *"it looks like that
broke something. the ship just drives directly through now without slowing down"*, then *"it
looks like it am still breaking through too quickly. im not sure if the ticks need to be
smaller or of you can make the rock break into smaller chunks."*

**Read when:** a core verb is being made continuous; a "chunky", "rigid" or "it just drives
through" report; a feel parameter that reads zero where the player starts; a destruction or
terrain system whose granularity does not match how it is drawn; a balance probe that averages
a run nobody has had.

**Takeaways:** (1) chunkiness is a cadence, not a curve - find the gate, not the easing;
(2) derive the verb's speed from the bill it pays, so the picture and the cost cannot drift;
(3) destruction granularity is a RATIO against character width, and the rendering style decides
what ratio reads.

---

## 1. Chunky is a cadence

The drill aimed at ONE grid cell, spent `fill * hardness / rate` seconds taking it to zero, and
refused to let the hull move until it was gone. Every individual step was already smoothly
interpolated. **He feels the period, not the shape of one step.**

**The rule: anything that gates the player's motion on completing a discrete unit of work reads
as chunky, however smooth each unit is.** Check for the gate before reaching for an easing curve.

## 2. Derive the speed from the bill

Advancing one metre removes one cell of fill, which costs `hardness` hit points, so

    plow speed = drill power / (hardness * HP_PER_METRE)

One identity carrying three things that would otherwise drift: the deep is slower, the power
cost per metre is unchanged by the rework, and **the drill can never advance faster than it
clears**. Measured: 1.55 m/s against 1.26 before, with the deepest rock 4.6x slower than the
surface - inside the readable 4:1 to 6:1 band the genre research gives (past that, players
report "stuck" rather than "slow").

Two ways that identity got broken, both of which let the ship through solid rock:

1. **A floor under the speed**, added on the research's advice that a drill reaching zero reads
   as a dead input. It is a licence to move through material that has not been cut: a scripted
   miner drove straight through a planet's core and ended forty metres below it, the core
   sitting at fill 0.39. **A floor like that is a property the content table must KEEP and
   assert, never a clamp that is applied.**
2. **Sampling the hardness a metre ahead of the hull.** The reading fell back to ordinary rock
   the moment the ship was ALONGSIDE the hard thing rather than approaching it. Sample at the
   leading FACE: time-in-cell times power then equals the cell's cost by construction.

## 3. Plowing means the hull is inside rock

The ordinary collision resolve has nothing to push against when the START position is illegal,
so it refuses every direction and the ship is wedged in its own tunnel the moment the player
lets go. Both first attempts were wrong:

- **Bounding it to "the drill is off"** let velocity through as well: a miner covered 37 m in
  ten seconds and left the whole shaft standing behind it, unpaid for.
- **An overlap count or an overlap AREA is flat** across most of a cell (a 0.76 m hull in a
  1.0 m cell covers the same area wherever it sits). Measured: the ship escaped 0.2 m and then
  sat there with its velocity zeroed. Sampling the fill bilinearly at the hull's corners moves
  on every millimetre - and it is the lattice the contour already uses, so it is one source of
  truth.

## 4. One feel parameter, four channels

`dig_load` 0..1, zero when not drilling, read by the drill loop's volume, pitch and grit rate,
the haptic cadence and the camera tremor. Four channels agreeing is what makes effort read;
four curves is mush.

**A continuous drill has to be a LOOP.** The old one-shot per bite fired once or twice a second
under a per-cell model and would be sixty a second under a plow. Android's own guidance for
continuous haptics says the same: one persistent effect that is modulated, never a retrigger
per hit. `Input.vibrate_handheld` has no amplitude stream, so the nearest honest thing is a
short pulse re-issued at a period that shortens with the load. Generate the loop rather than
sampling one: its pitch is driven every frame, and a recorded drill has its own pitch baked in
and fights the modulation.

## 5. The four faults the aggregate hid

The balance probe reported a healthy 1.55 m/s mean over a 200 m descent and it shipped on that.
That mean averages five depth bands of a descent **he has never once completed**. Ten seconds
of the stretch he actually plays:

```
  t= 1 s  depth  1.85 m  this second 1.85 m/s  load 0.00
  t=10 s  depth 29.75 m  this second 3.10 m/s  load 0.00
materials in the first 40 m: { ROCK: 312, IRON: 42, COBALT: 6 }
hardness the drill sees for each: 1.00, 1.00, 1.00
```

- **There was nothing to be slowed by.** Hardness came from the DEPTH BAND alone, so every
  material in a band cut identically. Fix: derive hardness from the material's WEIGHT, already
  in the table as `kg`, so the number the player reads in the hold is the number that slowed
  them getting it.
- **The effect channels were off in exactly the range he plays.** `dig_load` mapped the softest
  band to 0, and the softest band IS the first forty metres. Half of "it just drives through"
  was silence, not speed. A 0..1 parameter normalised across a content table reads zero at the
  bottom of that table, which is where every player starts. Give it a floor.
- **The pace was set from the mean.** 3.10 m/s against 7.00 m/s flying is not digging.
- **The new verb broke a system two files away.** The light solver's spill took light only from
  OPEN neighbours, so a lamp inside rock had no lit neighbour, every face returned zero, and the
  light went out exactly while the player was digging - which is now most of the time. The flood
  already gave the lamp's own cell a value of 1; the spill was the one place refusing to read it.

**Print the first ten seconds, per second, with the derived feel parameters beside the numbers.
Twenty lines of probe would have caught all four before the build went out.**

## 6. Granularity has to match the rendering style

Character width against terrain cell width, from primary sources:

| game | ratio | reads as |
|---|---|---|
| Worms, Liero | ~18:1 | continuous erosion |
| Noita | ~32:1 | continuous |
| SteamWorld Dig | ~1:1 | blocky, by its designer's own account |
| Terraria | ~0.5:1 | blocky, on purpose |
| Starbound | ~0.25-0.5:1 | blocky, on purpose |

**Block games get away with 1:1 because their whole visual grammar is squares.** Gravewell sat
at 0.76:1 while drawing smooth interpolated marching-squares contours, which promises Worms and
delivers Dig Dug. That mismatch was the complaint, not the metres per second: the drawn face
receded at 2.43 ship-widths a second in steps from 0.000 to 0.360 m, with facets a metre across
snapping between frames.

**It also rules out the other half of his guess.** A brush that accumulates continuously into
the field between mesh rebuilds is already sub-tick; a finer TICK changes nothing. Marching
squares cannot draw anything smaller than its own lattice whatever the simulation does. The
limit is spatial, always.

**Only the SHAPE needs to get finer.** Material, hardness, yields and light are metre-scale
facts; one array goes sub-metre and every coarse answer is DERIVED from it in one direction,
through caches exactly one function writes. **Pick the factor by measuring the mesh, not by
taste:** four times finer measured 18.1 ms of mesh rebuild a tick against a 16.7 ms frame;
three times is 6.7 ms. Genuinely continuous destruction is a per-pixel simulation and is not
reachable from a marching-squares contour in GDScript at any setting - the honest offer is "a
third the step size", not "like Noita".

What a sub-cell field breaks, all of which needed a measurement to find:

- **The two lattices will be offset.** Metre `x` is centred on `x`, so its fine cells start at
  `x - 0.5`. Getting it wrong does not look like an offset: the ship rides the edge of every
  block it clears (`0.02 0.16 0.57 1.00` across a carved metre) and no cell ever becomes
  passable. Write ONE `fine_centre(n)` and its inverse and use them everywhere.
- **A round brush cannot clear the corners of a square cell**, so "this cell is worked out"
  becomes a coarse threshold of its own - and it must be DERIVED from the subdivision, never
  typed in. At 3x3 one leftover corner is 1/9 = 0.111; a literal 0.10 that had been fine at 4x4
  meant nothing was ever finished.
- **Ask the COARSE cell whether it is done, after the carve.** Firing the payout when a fine
  cell hits exactly zero misses the case the threshold exists for.
- **Collide against the isovalue the surface is DRAWN at**, so the picture and the collision are
  one fact. It also means rock stops blocking before a cell is finished, so anything governing
  speed through material has to become an explicit clamp.
- **Missing beats stale in any chunked rebuild queue.** Sorting purely by distance starves the
  holes: the chunk under the player is dirty every tick and always nearest, so a chunk entering
  the window is never built and half the screen goes black. Missing chunks get a larger budget.
- **A colour cache keyed on position destroys per-vertex sampling.** Memoise the arithmetic
  behind the cell the sampler CHOSE, never the sample itself.
