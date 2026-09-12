# Camera and light on a portrait phone

**Cross-game, distilled from Coreward, Gravewell, Stillwater and Candle Gift.** These are the
presentation rules that used to sit in `CRAFT.md`; they were moved here on 2026-09-12 when that
file went past its size limit, because they are read at the polish pass rather than at plan
time. `CRAFT.md` keeps the headline of each; the arithmetic, the constants and the measured
numbers are here.

**Read when:** placing anything in a portrait 3D scene; a camera that makes the motion read
wrong; any lighting complaint; a "circle of light", "beam", "too dark" or "cartoony" report.

**Deeper still:** `coreward-propagated-lighting.md` (the flood/spill/fan solver),
`gravewell-tunnel-light-and-beam.md` (what the shaders do with the solved field),
`stillwater-fishing-fight.md` (the first-person rig and the water),
`candle-gift-reference-runner.md` (the framing solve),
`coreward-shop-room-and-hud.md` (portrait layout arithmetic).

---

## Camera

- Portrait's horizontal cone is tiny (58 deg vertical is ~28 deg horizontal; 46 is ~22). Compute
  visible width at the distance a thing sits before placing it, and rack shops vertically.
- **Measure screen pixels per world unit at EVERY depth the layout uses.** Coreward's shop: 122
  px/unit at the 7.6 m wall, 215 at the 4.0 m counter, 245 at the drawer front, on a 360 px
  screen (M) - so a neat lit tube on the wall is an 880 px glare at the counter, and things
  nearer the lens must be physically SMALLER. Project the bounding BOX, not object centres.
  `coreward-shop-room-and-hud.md`.
- Horizontal detail wants a low camera, vertical detail a high one. The angle is part of the art.
- Seat a first-person camera at seated height and draw the vehicle as an edge (gunwales).
- **A first-person camera carried by a moving object gets its own transform, derived from the
  carrier rather than parented to it.** Inherit ~0.9 of POSITION, 20-30% of ROTATION, damped at
  0.5-1 s so the head lags the deck. Bolted to the hull, honest motion is invisible ("the boat is
  flat"). Stillwater: 20.0 deg peak-to-peak at 41.9 deg/s before, 1.1 deg at 3.1 deg/s after,
  hull MORE visible (M). **Peak angular RATE predicts discomfort.** Check the water too.
  `stillwater-fishing-fight.md`.
- **Name the end at risk before measuring a frame.** For anything trailing a chase camera the
  nearest element is the LAST one. A probe that disagrees with a picture you are looking at is
  measuring the wrong quantity, and the picture wins. **Check framing at the size where it
  BREAKS** - level one measured 0.98, just inside the edge, and hid it for four rounds.
- **State the framing promise and solve for it; do not tune two constants toward it.** One
  constant for how far down the frame the last element may sit, plus a bisection: worst position
  went 0.98 / 1.08 / 1.42 / 1.37 to 0.95 at every level (M). Ease it out fast and in slow, since
  lagging on the way out IS the clipping it prevents.
  `candle-gift-reference-runner.md`.
- **Inverting a follow is a two-part edit, and the second part is a deletion.** When "A is
  positioned from B" becomes "B is positioned from A", grep every other place A is written in the
  same frame and remove it. Stillwater's pair were sixteen metres outside the boat within two
  hundred frames (M), silently - every RELATIVE assertion passed. Test an ABSOLUTE claim.
- A tight frame reads as "camera too close" unless darkness justifies it. Make framing an upgrade
  and let the light's reach explain it.
- Any end-of-run camera move is a second placement pass over everything near the finish.
- Re-shoot after any change to a length. Framing calibrated on old dimensions is wrong.
- Pick the axis convention so no sign flip sits near the input (draw the street along -Z so
  screen right IS world +X), and assert it in `test_controls.gd` rather than here.
- Cull scenery against the camera position, not the player. A chase camera sits ten metres back.

## Lighting

- A point light does not know the geometry is there. Light through a grid must propagate through
  open cells (flood fill), the field uploaded as a small texture.
  `coreward-propagated-lighting.md`.
- Surface light and air light are two lights. A corner shadow belongs only to the air term.
  Combine beam and bounce with `max()`, never by multiplying two floors - except in the AIR,
  where fog scatters ambient and beam at the same point and you see the SUM.
- **A lamp-centred radius always reads as light belonging to the player.** Any term whose falloff
  is measured from the source is a disc, and a disc follows you. For "the whole tunnel is lit",
  use the propagated flood RAW with no distance term of its own: it is 1 down an open passage
  however long and falls only where the route bends.
- **A beam in a corridor narrower than its cone has no shape.** Give it a profile ACROSS itself
  (a Gaussian on perpendicular distance, widening with distance travelled), scale it by air
  density, and CUBE the distance falloff, or the beam has an end and an end makes it an object
  (squared, still 148 of 255 where it left the frame, M).
  `gravewell-tunnel-light-and-beam.md`.
- **A shadow fan's starburst is fixed by filtering the lit-or-not ANSWER across bearings, never by
  more rays.** Five taps a little under a ray apart took the worst jump between neighbouring
  bearings from 1.000 to 0.200 and stepping boundaries from 22 to 0; seven buy nothing over five
  (M). Assert the mean AND the darkest sample, never a count over a threshold. A fixture for an
  aliasing artefact has to be deliberately ragged.
- **A lighting complaint is about a RATIO, so measure two places.** 100 ahead / 25 behind / 50 in
  the shaft reads as directional while leaving the way home visible; 6:1 blacks out the route and
  1.65:1 has no direction at all (M).
- **Any change that lifts the black floor publishes every defect the darkness was covering.**
  Budget a pass for it: lighting Gravewell's tunnel exposed a normal map that had streaked every
  wall for nine versions.
- **Unlit does not mean untextured.** Where the lit band ends, an ambient floor with no normal map
  reads as flat colour laid over stone rather than as the limit of the lamp. Put the surface term
  on the ambient as well.
- A lighting multiplier is linear and then sRGB-encoded, so its dark end lifts. Square it. Dim
  emissive things on a gentler curve than surfaces.
- Ambient is the one light that reaches every surface equally, the opposite of a lamp in a hole.
  Make it fall away fast. Three stops in a vignette.
- Do not light the player's vehicle with the gameplay light - its range is an upgrade. Give it its
  own key light and exclude the world's; the engine flags are in `GODOT.md`.
- Put the sun *ahead* of the camera for anything wet. A specular streak is sun, surface, eye.
- Any effect applied by distance hits the background hardest. Check the sky first when tuning fog
  (`GODOT.md` for the setting).
- Keep light fields at several texels per cell, brightness and shape in separate channels. The
  one-toggle diagnosis is switching to nearest filtering.
- A metal with nothing to reflect is black plus hotspots. It needs an environment; import settings
  for data textures are in `ASSETS.md`.
- A normal map is how photographed texture enters a stylised game. Sample by world position and
  expect a much higher strength than usual, judged under a moving lamp.
- Ambient particles are anchored in the world and wrapped around the player, lit on a harder
  curve, drawn behind terrain, faded wherever the beam is not the light. Dust you can see needs a
  dark room and a beam.
- Post-processing (vignette, animated mid-tone grain, a touch of aberration, blacks lifted toward
  the scene colour) is the cheapest mood tool there is. Put it under the HUD.
- A fix that improves every scene equally is a dimmer switch, not a fix. Attribute an artefact to
  a *layer* (toggle `.visible` per candidate) before touching any maths; when the toggles run out,
  render the suspect term straight to ALBEDO.

