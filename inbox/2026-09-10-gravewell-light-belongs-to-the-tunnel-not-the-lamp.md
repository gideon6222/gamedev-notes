# Light that "belongs to the ship" is any term with a radius measured from the lamp

**Game:** Gravewell, second lighting round. His words: *"Instead of thick air, this looks
more similar to a beam coming from the ship. Can you make it so that the there is a soft
dispersed light throughout the whole tunnel."*

The previous round already had a weak, long, direction-free term for the tunnel behind. It
still read as belonging to the ship, because **its falloff was a radius around the lamp**. A
radius centred on the light source reads as a pool however gently it falls and however far it
reaches: the shape is a disc, and a disc follows you.

## What fixed it

A propagated-lighting solver already computes the right quantity: the Dijkstra flood over
open cells, `exp(-att * (path - octile))`, which is **1 down an open passage however long it
is** and falls only where the route bends. Using it RAW, with no distance term of its own,
is light present in the tunnel rather than light thrown from a lamp. The tunnel lights to the
edge of the solved window and a side branch is dim because it bends, not because it is far.

Same move on the rock: give the wall term a reach longer than the solved window so it is
nearly flat across any frame, and let the spill's own falloff be the only falloff.

## The beam, separately

A beam in a one-cell shaft has no shape, because an angular cone test is constant across
something that narrow: it comes out a flat slab with a razor edge at each wall, which is an
object in the tunnel rather than light in the air. What gives it a shape is a profile ACROSS
the beam that widens with distance:

```glsl
float along = max(dot(away, lamp_dir), 0.0);
float off   = length(away - lamp_dir * along);
float w     = core_width + core_spread * along;      // 0.35 m, +0.30 m per metre
float core  = exp(-(off * off) / (2.0 * w * w));
```

Two more things that made it read as headlights rather than as a painted cone:

- **Scale the beam by the air density.** In clear air you see only what the lamp lands on;
  a visible shaft is entirely a fog effect. Tying it to the same density that drags the ship
  is what makes it read as cutting through something.
- **Cube the distance falloff, do not square it.** Squared, the beam was still at 148 of 255
  where it left the frame, so it had an end, and an end makes it an object.
- **Widen the shadow's soft edge with distance** (`0.25 + dist * 0.12`), or a far wedge is
  drawn crisper than the fan's own angular resolution and aliases into a staircase.

## Add the ambient and the beam, do not `max()` them

Fog scatters both at the same point in the same air and you see the sum. `max()` puts a
visible seam along the cone's edge where one term overtakes the other. `max()` is still right
for terms that are the same light counted twice, which is what the rock's three are.

## And it exposes whatever was hidden in the dark

Lighting the whole tunnel made a texture bug visible that had shipped for nine versions: the
normal map is projected in world XY, which is exactly parallel to every wall of a Z-extruded
mesh, so each wall's whole depth collapsed onto one line of texels and came out as vertical
streaks. **Selecting the projection by `abs(normal.z)` does not work**, because
`SurfaceTool.generate_normals()` smooths across the crease and a ceiling measures 0.87 there.
Select by the geometry instead: the front face is a plane at a known z.

**Expect this.** Any change that lifts the black floor of a dark game is also a change that
publishes every defect that darkness was covering. Budget a pass for it.
