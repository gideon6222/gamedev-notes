# Distance from the lens decides the number, not taste

**Coreward, 2026-09-10.** A 3D shop on a portrait phone, one fixed camera, four
things at four different depths: a sign on a wall four metres back, a rack at
three, a counter at one, and a drawer half a metre from the lens.

Every layout number that had to be corrected in two rounds of this room was the
same mistake: a value that was right at one depth, reused at another.

- The counter arc was `+/-1.05` because the wall rack was. At the wall that is
  `+/-132` screen pixels; at the counter it is `+/-226`, and both outer plates
  hung off the edges of a 360-pixel-wide screen.
- A neon tube 3.2 units long is a neat lit line on the wall and an **880 pixel**
  full-width glare at the counter - wider than the phone.
- A light pool sized off the tube's length in BOTH axes threw a 4.8 by 1.8 metre
  haze over the whole counter. A real pool is long and thin because the fitting
  is.
- Six crates in a drawer at `+/-0.62` ran off both sides, while the same spread
  on the wall would have been comfortable.

## The number to measure once, per depth

**Screen pixels per world unit, at each surface the layout uses.** Project two
points one unit apart and subtract. In this room:

| surface | distance from camera | px per world unit (360 px wide) |
|---|---|---|
| back wall | ~7.6 | 122 |
| wall rack | ~7.3 | 126 |
| counter | ~4.0 | 215 |
| drawer front | ~3.6 | 245 |

Everything then follows: a plate 0.66 units wide is 136 px on the counter and
83 px on the wall, so it needs a different scale in each - and the counter's
cases have to be physically SMALLER in world units to appear the same size.

## The trap underneath it

A measurement harness that projects object CENTRES will pass all of this. The
centres were comfortably inside the frame while the plates were not. **Project
the bounding box** (`new Box3().setFromObject(o)`, then all eight corners) and
demand a margin, not a boundary.

And when the layout is vertical: measure the band the player can actually see
(under the header, above any tray) rather than the canvas. Two rows of crates
wanted 160 px and the band had 117.

Related: [[a-case-is-not-a-point]], [[the-fix-that-never-ran]].
