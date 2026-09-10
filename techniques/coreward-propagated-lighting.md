# Coreward: propagated tunnel lighting (flood fill, light field, air vs surface, shadow fan)

**Game:** Coreward (web / three.js, 2.5D grid miner) · **Status:** shipped, played through five rounds of lighting notes · **Read when:** a lamp has to respect geometry on a grid; a 'circle of light' artefact; light in the air vs light on walls; any lighting bug that survives a fix

Coreward is a 2.5D grid miner: the player's ship carries a lamp and digs tunnels through a
cell grid. A point light lit unopened rock and side tunnels exactly as brightly as the shaft
the player was in, because falloff is a function of distance and nothing else. Gideon asked
for light that "spreads from the ship", fills connected tunnels, leaves rock several cells
deep black, and casts a shadow down a branch it passes. What follows is the stack that
delivered that - a flood fill over open cells for propagation, a per-pixel falloff in the
shader, a ray fan for corner shadows, and a separate treatment for light in the air - plus
the artefacts each piece produced and how each was diagnosed. It took five rounds of playtest
notes on one artefact, and most of the lessons below are about why.

**Generalisable takeaways**

- **Split light into what the grid can know and what the shader can know.** Visibility and
  occlusion are properties of the geometry and belong in a small solved field uploaded as a
  texture; smooth distance falloff and per-pixel position belong in the shader. Keep the
  field at several texels per cell, keep brightness and shape in separate channels, and
  sample by world position.
- **Light on surfaces and light in the air are two different lights**, and a shadow belongs to
  only one of them. Sharing one number between them makes every side passage read as a hole,
  and makes every playtest note about the wrong thing.
- **A note that survives a correct fix is a note about something else; a fix that improves
  every scene equally is a dimmer switch.** When a symptom outlives two real fixes, stop
  tuning and measure: hide one layer at a time, print the buffer, run a positive control.

---

## The flood fill

**A point light does not know the rock is there, and on a 2.5D grid that is the difference
between "the picture got darker" and "I can only see where my lamp reaches".** Coreward's lamp
lit a side tunnel the player had never opened exactly as brightly as the shaft they were flying
down, because falloff is a function of distance and nothing else. The fix is a **flood fill over
the grid**: light travels through OPEN cells only, so what attenuates a cell is the length of the
path along the tunnel rather than the straight line. A shaft lights all the way down; a branch is
dim because the light went round a corner; unopened rock is black because there is no path to it.
It costs a Dijkstra over a few hundred cells, run only when the ship changes cell or the terrain
changes shape — microseconds, and no draw calls at all.

Four things make that work rather than merely run:

- **Store visibility, not brightness.** Per cell, keep `exp(-att * (pathLength - octileDistance))`
  — how much LONGER the light's real path was than a clear run would have been. Open space then
  comes out at exactly 1 and only geometry can darken anything. Subtracting Euclidean distance
  instead of octile puts a permanent haze over open ground, because eight-way steps do not add up
  to a straight line.
- **Split the continuous half out.** The grid cannot move smoothly and the ship can, so distance
  falloff belongs in the shader, evaluated per pixel from the ship's exact position. Leave it in
  the grid and the pool of light steps a whole metre at a time as you fly.
- **Upload it as a tiny texture and sample by world position.** 15×36 texels with `LinearFilter`
  is 2 KB and interpolates, so light fades ACROSS a rock face instead of stepping at cell edges.
  One `DataTexture`, one shared set of uniform objects wired into every material by reference, so
  a per-frame position drives thirty materials with one write.
- **Multiply `reflectedLight`, not the final colour, and clamp to at most 1.** Scaling
  `directDiffuse`/`indirectDiffuse`/`directSpecular`/`indirectSpecular` after
  `<lights_fragment_end>` leaves emissive alone, so ore keeps glowing in the dark — which in a
  mining game is the entire find-the-ore mechanic. Clamping to 1 means every lighting value
  calibrated by eye against the old renderer stays the ceiling it was.

## Corner shadows: a second solver

**A flood has no notion of an edge, and a corner shadow is an edge.** Light that turns a corner
in a flood arrives from that corner in every direction at once, so a tunnel crossing the
player's path lights along its whole length, gently, when what should happen is that the corner
throws a shadow into it. That is a question about straight lines from a point, so it wants a
second solver: **fan a few hundred rays out from the light by grid DDA and record, per angle,
how far light gets before something stops it.** One-dimensional, so it uploads as a 512-texel
texture; a fragment is in shadow if it is further from the light than the occluder on its own
bearing. Sharp by construction, exact for any geometry, and the wedge behind a corner widens
with distance for free, because that is what a fan of rays does. It has to run every frame
rather than on cell changes - the whole point is that the shadow moves as the player does - and
a few thousand grid steps does not show up in a measurement.

**Record the FAR side of the first wall the ray hits, not the near side.** A wall's face is the
surface the light is falling ON and has to stay lit; shadow starts behind it. The near side
puts every rock face in the game into its own shadow, which reads as "the lighting is broken"
rather than as an off-by-one.

## Two lights, not one

**Light on surfaces and light in the air are two different lights, and a shadow belongs to
only one of them.** Coreward ran one lighting number and handed it to both, so the ray fan -
which answers "can light get along this tunnel to here" - was also carving hard-edged wedges
across every rock face in the frame. A surface is lit by being NEAR a lit space, which is a
property of the surface; the air in a corridor is lit by light travelling along it, which a
corner can block. Same terms, one difference:

    SURFACE   flood x falloff x beam
    AIR       flood x falloff x beam x shadow

They also want very different ambient floors - a corridor is full of dust with light bouncing
off every wall in it, a surface the beam is not on is simply dark. Sharing one figure made
every side passage read as a hole.

**And the process lesson under it:** three rounds of playtest notes all pointed at this and
were all read as tuning requests, because each one described a symptom on a rock face. The
tell was that the complaint kept coming back after a fix that genuinely worked. **A note that
survives a correct fix is a note about something else.**

## The shadow-fan artefacts

**A shadow fan sampled by angle needs the FARTHEST CORNER of the cell it hits, not where the
ray leaves it.** Per ray, the exit distance is exactly right - a point inside the cell is always
between entry and exit. But the shader interpolates between the two nearest rays, and those may
have clipped quite different parts of the wall or missed it, so parts of a cell come out beyond
their own occluder and go dark. In Coreward that was thirteen per cent of every wall face, and
on screen it is a hard diagonal cut across every single block in the frame - it reads as every
rock casting a shadow on itself, which is what the playtester called it. The rule the fan
exists to express is "the first wall is lit", and a wall is a whole cell.

**The test for that has to interpolate the way the shader does, and assert a ratio.** A
nearest-ray lookup cannot see the artefact at all, because the artefact only exists once two
rays are blended; sampling cell centres cannot see it either, because a centre passes under
both rules. Sample across a wall face, blend the two nearest rays, and assert the fraction of
lit-face-in-shadow stays under a few per cent.

**Give the soft, omnidirectional half of a light its own falloff.** Sharing the beam's pool
means the ambient glow behind the player ends exactly where the beam does, with the same hard
edge - which is the one thing the soft half must not do. Longer reach, much gentler curve.

## Glowing things, bounce light and the sRGB trap

**Dim glowing things on a separate, gentler curve from surfaces.** Emissive and additive haloes
exempted from the light field entirely become the loudest thing on screen at any depth, so a
glowing pickup deep inside unlit geometry reads as clearly as one at arm's length; run through
the same curve as a surface, they switch off and take a discovery mechanic with them. A square
root over a small floor keeps the near ones bright and pushes the distant ones to a smudge.

**Combine a directional beam and an omnidirectional bounce with `max()`, never by multiplying
two floors.** Multiplying "how much survives behind the player" by "how much survives in
shadow" means anywhere that is both lands on the product - four per cent of four per cent,
which is black. In Coreward that erased the shaft the player came down, which is the way home.
One bounce term at about a fifth of the beam, gated by the same flood so it lights opened
tunnels and never solid rock, and take whichever is larger.

**A lighting multiplier scales LINEAR light and is then sRGB-encoded, so its dark end lifts
enormously.** Six per cent of the light displays at roughly a third of full brightness. A field
that is numerically correct therefore reads as a grey wash over everything, and every plausible
suspect - lamp intensity, ambient, fog, the background layers - measures innocent in turn.
Square the multiplier before applying it. This is not a fudge; the alternative is to keep every
constant honest and then hand the result to a display that disagrees.

**Rock must be relaxed but never expanded.** A wall next to a lit tunnel is lit; light stops
there. Let rock pass light on and a one-cell wall leaks a third of the lamp into the chamber
behind it, so every sealed pocket glows faintly and tells the player it is there before they have
dug to it. The fade INTO the mass is a separate pass that only ever writes to rock, so it cannot
leak into open air either.

## Light in the air

**Lighting a surface is only half of "light fills the tunnel".** A dug cell contains no geometry,
so there is nothing in it to light and the tunnel reads as an empty slot. One additive quad across
the frame, sampling a second channel of the same texture that is non-zero only in OPEN cells,
turns the void near the lamp into glow and leaves the far end black. One draw call, and it is the
single change that made the feature read.

**Store a per-cell light field at several texels per cell, not one.** With one texel per cell,
bilinear filtering interpolates between cell CENTRES, so every boundary in the lighting is a
soft ramp a whole cell wide - a single surface ends up half lit with a rounded edge curving
across it, and the player reads the shape of the grid instead of the shape of the world. Fill
each cell with a 3x3 block of identical texels and the filter has nothing to interpolate until
the one-texel seam at a cell edge: a third-of-a-cell transition, sitting exactly where the
world's own edges are. The solve stays per cell; it is a fill loop and a slightly bigger upload.

**The one-toggle diagnosis: switch the texture to NearestFilter.** If the blobs vanish and are
replaced by hard rectangles, the problem is the sampling resolution and not the data. That test
takes ten seconds and settles an argument that reasoning about screenshots will not.

**A per-cell mask sampled with LinearFilter bleeds a FULL CELL in every direction, and on a
one-cell feature that is a blob rather than a shape.** Coreward stored "is this cell open" as one
texel per cell; a one-cell-wide tunnel is therefore a single 255 surrounded by zeroes, and
bilinear filtering ramps that to zero only at the neighbouring texel's CENTRE. The tunnel glow
painted three cells wide and read as a circle of light bleeding through solid rock. It took
three rounds of playtest notes because two other things were genuinely making a circle too.

The fix is to keep **brightness and shape in separate channels** - one channel for the eased
light value, one hard 0/255 bit for openness - and re-normalise the filter's own ramp in the
shader: `smoothstep(0.5, 0.98, mask)`. Bilinear leaves exactly 0.5 at a cell boundary and 1.0 at
a cell centre, so that maps the glow precisely inside the cell. Sharpening a combined value
instead would crush every dim tunnel to black, because "dim" and "outside" are the same number.

**And the process half: when a symptom survives two correct fixes, stop fixing and start
measuring.** Printing fifteen numbers out of the buffer ended a three-round hunt in one call.

## Fakes that outlived the real system

**When you replace the reason for a workaround, delete the workaround in the same commit.**
Coreward bled a tunnel's glow half a cell onto the rock around it, to stop wall bulges reading
as unlit chips inside a lit shaft. A version later the real fix landed - the glow quad moved in
front of the terrain - and the bleed stayed, because nothing failed when it became unnecessary.
What it did instead was paint an additive wash over every rock face near the player: a circle,
over solid rock, softening the very shadow edges the shadow solver existed to draw. It took two
rounds of playtest notes to find, because a leftover workaround is indistinguishable from a
deliberate choice.

**When a lighting model lands, audit everything that emits light - not just the thing you set
out to replace.** Coreward had a wide additive halo sprite on the ship standing in for "there is
a lamp here". It predated the propagated light, it kept working, and because it was small enough
to read as part of the ship it survived three rounds of "the lighting still looks wrong". It was
the last object in the frame obeying different rules: additive quads know nothing about
geometry, so it painted a circle over solid rock. **A fake put in before the real system exists
does not announce itself when the real system arrives.**

**Delete the fake when the real thing arrives.** Coreward drew a volumetric cone from the drill
as a stand-in for a headlight. Once light actually propagated, the cone was a triangle drawn where
light was *supposed* to be — it passed through solid rock as happily as through air, and it
contradicted the thing next to it. What survived was the one job it was uniquely good at: the
Scanner upgrade having a silhouette. That moved to the size of the lamp's own glow.

**Put the source glow BEHIND the character, not in front.** An additive quad centred on a lamp
that sits in front of the ship washes straight over the hull, and the ship renders as a bright
blob with no facets — the exact fault that render layers were added to fix, arriving by a
different route. Behind it, the ship silhouettes against its own light, which is what a lamp on a
machine actually looks like.

## Ambient, vehicle lighting and the mood around it

**Moving from Lambert to MeshStandardMaterial changes the SHAPE of the lighting, not just its
values.** Standard adds a specular lobe, so every light now contributes a highlight as well as a
diffuse term and the old intensities read as a bright plastic wash. Turning everything down is not
the fix: **ambient has to fall away much faster**, because ambient is the one light that reaches
every surface equally, which is the exact opposite of a lamp in a dark hole. Coreward went from a
linear falloff to a squared one so the drop lands in the first third of the descent where it can
be felt.

**Do not light the player's vehicle with the gameplay light.** Coreward's lamp is a point light on
the ship, so the ship sat four times closer to it than the rock it lit and rendered white whatever
its hull was painted. The real problem was worse than the look: lamp range is an UPGRADE, so
buying a Scanner level changed how the ship looked. Put the vehicle on its own layer with its own
small key light, and its material reads the same at every depth and every upgrade level.

**When a render looks wrong, measure it rather than staring at it.** Hide the object and see if
the problem goes; `gl.readPixels` the actual pixel; recolour materials one at a time to find which
mesh is which. Coreward's "white ship" was blamed on four different things in turn, and the mesh
everything was pinned on turned out to be a small cap at the top while the pale mass was a
different material entirely — whose values were ordinary mid-greys that only read as white against
very dark rock.

**Fog is not distance in a 2.5D game.** `FogExp2` measures distance from the *camera*, and a
camera twenty units back looking at a flat plane is equidistant from everything in it. Turning fog
up to fade the far edges instead puts an even grey wash over the whole picture. The thing that
falls off across the plane is a **point light**.

**Make the framing an upgrade, then make the darkness justify it.** A tight frame alone reads as
"the camera is too close". The same frame with ambient nearly gone and the corners falling to
black reads as "this is as far as the light reaches" — the same picture, opposite meaning.

**Three stops in a vignette, not two.** A linear ramp from clear to black across the whole radius
reads as a grey wash. Holding the middle mostly clear and falling off hard in the last third reads
as light running out.

## Tests that aimed at the wrong layer

**A test that hard-codes a layout it did not choose breaks every time the layout moves, and it
breaks without saying why.** Coreward's lighting test indexed a texture as one texel per cell;
the day that became three texels per cell it failed with a number, not a reason. Derive the
shape from the artefact under test - `image.width / knownColumns` - rather than restating it.

**A threshold about how dark something LOOKS belongs on the post-gamma value, not on the field
that feeds it.** Two of Coreward's lighting tests asserted on the raw light field, and both
failed the moment the gradient was retuned to exactly what a playtest had asked for. A test
that fails when the code becomes more correct is aimed at the wrong layer - and the fix is not
to loosen the number, it is to assert in the units the person looking at the screen was using.

## Making an artefact less visible is not fixing it

(Filed as its own section in the original; it is the process story of the lighting rounds.)

A player reported angular shapes in the tunnel lighting. Hiding the fog layer proved the fog
was drawing them, so the fog's ambient term was cut hard. The shapes went away, and so did a
lot of the game's warmth. Next playtest: *"it looks like it is happening worse now than it was
and I liked the art style before better."*

Both halves of that were true, and the second half is the interesting one. The fog was only
REVEALING the artefact — the actual cause was upstream, in how the shadow data was recorded.
Turning the fog down made the artefact dimmer, not absent, while charging full price in every
scene that never had the problem in the first place. Once the real cause was fixed, the
brightness went straight back up and nothing came with it.

The tell, in hindsight: the change removed the symptom **everywhere**, including places where
the symptom's supposed mechanism could not apply. A fix that is aimed at a cause is usually
narrow. A fix that improves every scene equally is usually a dimmer switch.

So when a tuning value is about to be moved to make something stop looking wrong, ask what
would happen to that value if the artefact were fixed properly. If the answer is "it would go
back", the tuning is not the fix.

**Players describe mechanism, not just symptoms, and they are often right.** The same report
carried the actual diagnosis: *"it looks like you are creating the shadows by sending out
multiple cone shape beams ... since the light should be coming from one location it shouldn't
be split into more than one beam."* That was precisely correct — occluder distance was being
recorded per whole block, so one lamp quantised into a cone per block. Read the mechanism half
of a report as seriously as the symptom half.

## Diagnosing a rendering artefact: layer first, then maths

(From `PIPELINE.md`; both were learned on this feature.)

Five playtest rounds went into "there is a circle of light around the ship", and four
different causes were found and correctly fixed before the fifth one was the real one. Every
one of those rounds started by reasoning about which term in the shader could produce the
shape, and every one of them cost an afternoon.

The move that actually settled it took one call: hide the additive fog quad and re-render.
The artefact vanished and the terrain kept its lighting, which said the fault was in the air
volume and not in the shadows, the flood, the filtering or the terrain shader — ruling out
four modules at once. Only then was it worth asking which term.

So: when something looks wrong on screen, the first question is **which draw call is putting
those pixels there**, not which line of maths is wrong. Toggle `.visible` on each candidate
layer in turn. It is one call per layer and it partitions the search space; reasoning about
the shader does not partition anything.

Toggling one uniform, screenshotting twice and getting two identical images feels like a
result. It is not one — not until a **positive control** has shown that the path from the
change to the pixels actually works. Set something to a value that cannot possibly look the
same (a global gain to 0.02, so the frame goes near black), screenshot, and confirm it
changed. Only then does "no difference" mean "this is not the cause".

Cost of skipping it: two rounds of chasing a rendering artefact were spent on A/Bs that came
back identical, which was read as "not the cause" for one of them and as "the render is not
reaching the screen" for the other. Both readings were guesses. The control took one call and
settled it — the path was fine, so the null results were real, which immediately ruled out a
whole family of hypotheses instead of leaving them open.

The same rule covers the manual-render trap underneath it: if the page's own `rAF` is
stopped, whatever you call yourself is the frame; if it is running, it will overwrite you on
the next tick and your change may never be visible. The control tells you which world you are
in without having to reason about it.

## Ambient particles must be anchored in the world, not to the camera or the player

Coreward had a drifting dust field for months that nobody believed was dust. The instinct is
to blame the count or the sprite, and both were fine. The problem was one line: the point
cloud was positioned on the ship every frame, with a slow rotation on top.

A cloud that travels with you cannot move past you. You can fly a hundred metres down a shaft
and the same motes are in the same places on screen — so the eye reads it as a texture on the
lens, which is exactly what it is. Rotation does not help; it just makes the lens texture
spin.

The fix is to leave the motes standing still and wrap them around the player: keep a box of
world positions, and when a mote falls out of one side, add the box width to put it back on
the other. It costs a modulo per mote per frame and it is the entire difference between dust
and dirt on the screen. Motes now rise past you as you dive, which is the only cue that
mattered.

Two things that compound it, both cheap:

- **Light them with the same light model as the world**, on a harder curve than surfaces get.
  A mote outside the beam should be almost invisible and a mote inside it a bright speck. That
  contrast is what makes a beam look like a volume with something in it. A flat-lit mote field
  is noise over the picture.
- **Put them behind the terrain**, so a mote only ever shows down a space that is actually
  open. In front, they read as specks on the lens over solid rock — the same failure in a
  different costume.

And fade them out wherever the beam is not the light source (daylight, a lit interior), or you
get specks hanging in a bright scene. Dust you can see needs a dark room and a beam.
