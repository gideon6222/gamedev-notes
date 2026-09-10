# A shader that owns its own light model must be `unshaded`, because `ALBEDO` is what Godot's lights multiply

**Game:** gravewell **Date:** 2026-09-10
**Belongs in:** `GODOT.md` under rendering traps, next to `light_cull_mask`.

## What happened

Gravewell lights its rock from a solved light field rather than from a Godot
light: a flood fill over open grid cells, uploaded as a small texture and sampled
per pixel. The rock is deliberately excluded from the only `Light3D` in the
scene, because that light exists to light the SHIP and the world's light is an
upgrade the hull must not inherit.

The shader computed the field correctly and wrote it to `ALBEDO`. **The screen
was black.** Not dim, black, at every value of every constant. Two rounds went
into the falloff curve and the exponent, and neither changed the picture at all,
which is itself the tell: a complaint that survives a correct fix is about
something else.

`ALBEDO` in a lit `shader_type spatial` is not the colour that reaches the
screen. It is the base colour that **lights multiply**. A surface excluded from
every light in the scene has nothing to multiply it by, so `ALBEDO` is
irrelevant: the output is ambient times albedo, and the ambient in a game whose
whole subject is darkness is nearly zero.

## What found it

Not reasoning. Rendering the buffer: `ALBEDO = vec3(f.g, f.r, 0.0); EMISSION =
vec3(f.g, f.r, 0.0);` and a screenshot. The field appeared exactly where it
belonged, correctly shaped and correctly scaled, which ruled out the solver, the
upload, the world-position mapping and the texture format in one frame. Hiding
the additive haze layer ruled out the second candidate in a second frame.

Before that, three plausible and completely wrong hypotheses had been reasoned
about in a row: a half-texel UV offset, `source_color` sRGB-decoding a data
texture, and a wrong `field_side` uniform. All three were consistent with a black
screen and none of them was true.

## The rule

**If a shader computes its own lighting, say so in the render mode.** Either
`render_mode unshaded` and write the finished colour to `ALBEDO`, or write the
computed light to `EMISSION` and accept that `ALBEDO` is doing nothing. Silently
relying on `ALBEDO` while excluding the object from every light produces a
correct calculation and a black screen, and nothing in the engine warns.

The corollary is the one that generalises past shaders: **when a value is
computed correctly and displayed wrongly, render the value.** A shader has no
`print`, so the screen is the only readout it has, and one diagnostic frame
answered a question that two rounds of arithmetic could not.

And the third time this shape has cost time here: `CRAFT.md` already says to
attribute an artefact to a LAYER before touching any maths, by toggling
`.visible` per candidate. That works for "which of my objects is doing this".
Rendering the buffer is the same move one level down: **which of my numbers is
wrong.** It should be the first move, not the fifth.
