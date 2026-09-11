# Lighting a dug tunnel: ambient that belongs to the passage, and a beam that belongs to the air

**Gravewell, 2026-09-10, two rounds.** Builds on
`techniques/coreward-propagated-lighting.md`, which is the flood/spill/fan solver this
uses. This file is about what the shaders do with the solved field, which is where both
rounds of his complaint actually lived.

He restated the system from scratch twice. Per `INDEX.md` rule 9 that means the model was
wrong, not the tuning, and it was: round one fixed a ratio, round two fixed a shape.

## Round one: "the light seems to be coming from the back of the ship in a small beam"

The beam was fine. **The complaint was about a ratio, and nobody had measured one.**
Sampling the screenshot with PIL at fixed points: the air up the shaft read 150 of 255 while
the rock the beam was pointing at read 103. The brightest thing on screen was behind him.

Target ratios that came out of it, on a 460x996 frame:

| where | reads | why |
|---|---|---|
| the pool the beam lands in | ~100 | the lamp points here |
| the tunnel behind | ~25 | the way home stays visible |
| air in the shaft | ~50 | between the two |

At 6:1 the tunnel behind goes black, which throws away the route out. At 1.65:1 there is no
direction at all. 3:1 to 4:1 is the band.

## Round two: "a soft dispersed light throughout the whole tunnel", "headlights cutting through the thick air"

### A lamp-centred radius always reads as light belonging to the ship

Round one already had a weak, long, direction-free term for the tunnel behind, and it still
read as a pool that follows you. **A disc centred on the light source is a disc however
gently it falls and however far it reaches.**

The flood already holds the right quantity. `exp(-att * (path - octile))` is exactly 1 down
an open passage however long it is, and falls only where the route bends. Used RAW, with no
distance term of its own, it is light present in the tunnel rather than light thrown from a
lamp: the passage lights to the edge of the solved window, and a side branch is dim because
it bends away rather than because it is far off.

```glsl
float ambient = flood * ambient_gain * mix(ambient_shadow, 1.0, shadow);
```

`ambient_shadow` is 0.35, not 0: air in a shadow is still air, and a black wedge in fog is a
hole cut in the fog.

Same move on the rock. Give the wall term a reach LONGER than the solved window (4x the
lamp's reach) so it is nearly flat across any frame and the only falloff left is the spill's
own.

### A beam in a corridor narrower than its cone has no shape

An angular cone test is constant across a one-cell shaft, so the beam renders as a flat slab
with a razor edge at each wall: an object in the tunnel rather than light in the air. What
gives it a shape is a profile ACROSS itself, widening as it travels, which is what
"dispersed" means:

```glsl
float along = max(dot(away, lamp_dir), 0.0);
float off   = length(away - lamp_dir * along);
float w     = core_width + core_spread * along;   // 0.35 m, +0.30 m per metre
float core  = exp(-(off * off) / (2.0 * w * w));
```

Three more things, each measured:

- **Scale the beam by the air density.** In clear air you see only what the lamp lands on; a
  visible shaft is entirely a fog effect. Tying it to the same density that drags the ship
  and muffles the audio is what makes it read as cutting through something.
- **Cube the distance falloff, do not square it.** Squared, the beam was still at 148 of 255
  where it left the frame, so it had an end, and an end makes it an object.
- **Widen the shadow's soft edge with distance** (`0.25 + dist * 0.12`). A fixed band is
  drawn finer than the ray fan's own angular resolution far out and aliases into a staircase.

### Add the ambient and the beam; do not `max()` them

Fog scatters both at the same point in the same air and you see the sum. `max()` leaves a
visible seam along the cone's edge where one term overtakes the other. `max()` is still right
for terms that are the same light counted twice, which is what the rock's three are (beam,
proximity, wash).

## Two faults found by replacing a term rather than reading it

Keep a `uniform int debug_term` with one branch per term, permanently. Both of this file's
faults were found in one frame each and neither was visible in the code:

1. A beam that was not directional at all: `mix(0.18, 1.0, smoothstep(...))` over a 2.4-radian
   cone saturated almost everywhere, so the term came out flat.
2. A black stretch of shaft that looked like a broken shadow. Replacing `shadow` with 1.0 said
   the shadow was the limiter; a headless probe then said the shadow was CORRECT and the
   column above the ship was open for four cells and then ceiling. The fault was in the mental
   model of the geometry.

## One number for the fan, at both ends

The fan is cast further than the light reaches, so a corner beyond the last lit pixel is
still in it. That multiplier is one constant (`Tuning.FAN_REACH_MULT = 1.8`) used by both the
cast and the shader's decode. It shipped as 1.8 in one place and 1.0 in the other, so every
shadow began at 55% of its true distance. The smoke run asserts the uniform equals what the
cast used.

## Lighting the tunnel publishes everything the darkness was covering

Budget a pass for this on any game that lifts its black floor. Gravewell's normal map is
projected in world XY, which is exactly parallel to every wall of a Z-extruded mesh, so each
wall's 3 m of depth collapsed onto one line of texels and came out as vertical streaks on
every ceiling. It had shipped for nine versions.

**Selecting the projection by `abs(normal.z)` does not work.** `SurfaceTool.generate_normals()`
smooths across the crease where the front face meets the wall, so a tunnel ceiling measures
0.87 there and every wall takes the face projection anyway. Found by rendering `abs(n.z)`
straight to ALBEDO. Select by the GEOMETRY instead: the front face is a plane at a known z,
passed in as a uniform and asserted against the mesh builder's constant.
