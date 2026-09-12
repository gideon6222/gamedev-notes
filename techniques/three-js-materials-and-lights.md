# three.js: materials, colour space and lights

**Game:** Coreward, Candle Gift (web / PWA builds) · **Status:** shipped; Coreward and Candle Gift are live on GitHub Pages · **Read when:** a surface reads too bright, too flat, or will not respond to being repainted; a metal renders black; deciding where the sky lives before adding a post pass; cel bands that smooth back to Lambert; fog that greys the whole picture; wondering whether a three.js lighting rule survives the move to Godot

Split out of `three-js-traps.md` on 2026-09-12, when that file went over the 30 KB limit. This
is the surface half of the web-stack list: what a material does to the shape of the lighting,
what an environment map and a colour-space flag do to its brightness, the two effects (bloom,
fog) whose cost and reach are both usually misjudged, how surface detail has to be sampled, and
the layer rules that decide which lights reach what. Two of these are exactly backwards on
Godot and are flagged where they appear, which is the reason the file exists at all: a Godot
session should be able to read this and know what *not* to port. The entry point for the rest
of the list is `three-js-traps.md`; the silent-failure half is in
`three-js-renders-as-nothing.md`.

**Generalisable takeaways**

- **Moving to a material with a specular lobe changes the SHAPE of the lighting, not its
  values.** Turning every light down is not the fix; ambient is the one light that reaches every
  surface equally, so in a dark-hole game it has to fall away much faster - Coreward went from a
  linear falloff to a squared one so the drop lands in the first third of the descent.
- **Colour space is a silent multiplier, and a metal with nothing to reflect is black.** A canvas
  environment map read as linear rather than sRGB comes back several times too bright, which
  presents as "the metal is blown out" and sends you hunting through light intensities. Data
  textures (normal, roughness) must NOT be sRGB-decoded; colour textures must be. **If adjusting
  the obvious parameter changes nothing at all, a constant term is drowning the one you are
  moving - measure, do not tune harder.**
- **Measure the effect rather than reasoning about it, and check what the measurement is worth
  on the other stack.** `UnrealBloomPass` at half resolution cost 0.096 ms/frame and was never
  the problem; a `normalScale` of 0.45 was invisible where 3.0 read correctly. `Object3D.layers`
  not filtering lights is the one rule in this file that is the opposite on Godot, where
  `Light3D.light_cull_mask` does exactly what three.js will not.

---

## Sky, post-processing and bloom

**Fake bloom with additive sprite halos.** Post-processing bloom costs fill rate, a library, and a
pass. Additive quads with a soft texture cost one draw call, and if the camera never rotates a
quad in the XY plane always faces it — no billboarding needed.

*General lesson:* additive sprites are a cheap bloom on a stack where a post pass costs a library; on Godot glow is built into `Environment` and this trade-off does not exist.

---

**A gradient sky in CSS and real post-processing are mutually exclusive, and that is the thing to
decide first.** Rendering with `alpha: true` over a CSS gradient is free and looks great — until
you want an `EffectComposer`, at which point the scene renders into an opaque render target and
the sky it was compositing over goes black. Measured on Coreward: `UnrealBloomPass` at half
resolution cost **0.096 ms/frame** (0.357 → 0.453, 27% of a very small number) and was never
going to be the problem; the problem was that the sky vanished and the palette shifted — brown
rock to grey, a cyan beam to green. `OutputPass` fixes the colour-space half and does nothing for
the alpha; `RenderPass.clearAlpha = 0` does not rescue it either, because the bloom composite is
additive and destroys alpha inside the chain. **If a game might ever want a post pass, put the
sky in the scene from the start** — a fullscreen gradient quad is barely more code than the CSS
and does not have to be unpicked later, along with everything calibrated on top of it.

*General lesson:* decide whether the game will ever want a post pass before choosing where the sky lives; put the sky in the scene from the start. (The earlier line "Gradient skies for free. Render with `alpha: true` and no scene background, then put a CSS gradient behind the canvas" is the superseded rule, kept in the original file by accident.)

---

## Materials: Standard, metals, environment maps, colour space

**Moving from Lambert to MeshStandardMaterial changes the SHAPE of the lighting, not just its
values.** Standard adds a specular lobe, so every light now contributes a highlight as well as a
diffuse term and the old intensities read as a bright plastic wash. Turning everything down is not
the fix: **ambient has to fall away much faster**, because ambient is the one light that reaches
every surface equally, which is the exact opposite of a lamp in a dark hole. Coreward went from a
linear falloff to a squared one so the drop lands in the first third of the descent where it can
be felt.

*General lesson:* moving to a material with a specular lobe changes the shape of the lighting, not just its values; ambient is the one light that reaches every surface equally, and in a dark-hole game it has to fall away fast.

---

**A metal with no environment map has no diffuse term at all** — a metal's colour comes entirely
from what it reflects, so with nothing to reflect it is specular hotspots and black. Lowering
metalness looks like the fix and is not; the fix is giving it something to reflect. A 64px canvas
gradient standing in for "dark ground below, faint light above", run through `PMREMGenerator`,
costs nothing and ships no bytes. Apply it **per material, not as `scene.environment`** — as a
scene environment it lights the terrain too and puts back exactly the flat fill a darkness pass
just removed.

**And set `colorSpace` on it.** A canvas env map read as linear rather than sRGB comes back about
four times too bright, which presents as "the metal is blown out" and sends you hunting through
light intensities. The same rule catches normal and roughness maps from the other side: those are
DATA, not colour, and must NOT be sRGB-decoded.

*General lesson:* a metal with nothing to reflect is black plus hotspots; give it an environment, per material, not per scene. Data textures (normal, roughness) must NOT be sRGB-decoded; colour textures must be.

---

**A metal gets its colour almost entirely from its environment map.** A high-metalness material
has essentially no diffuse term, so with a dark albedo the environment IS the visible
brightness - and a `CanvasTexture` used as one defaults to `NoColorSpace`, which decodes an
sRGB gradient about two and a half times too bright. The symptom is an object that will not
respond to being repainted. **If adjusting the obvious parameter changes nothing at all, stop
adjusting it: that is the signature of a constant term drowning the one you are moving, and the
next move is to measure, not to tune harder.**

*General lesson:* if adjusting the obvious parameter changes nothing at all, a constant term is drowning the one being moved - measure, do not tune harder. (The original file gives the colour-space error as "about four times" in one place and "about two and a half times" in another; both are the same fault.)

---

**When a render looks wrong, measure it rather than staring at it.** Hide the object and see if
the problem goes; `gl.readPixels` the actual pixel; recolour materials one at a time to find which
mesh is which. Coreward's "white ship" was blamed on four different things in turn, and the mesh
everything was pinned on turned out to be a small cap at the top while the pale mass was a
different material entirely — whose values were ordinary mid-greys that only read as white against
very dark rock.

*General lesson:* when a render looks wrong, measure it: hide the object, read the pixel, recolour materials one at a time.

---

## Toon shading and outlines

**Cel shading is a three-line texture, and ambient light is what kills it.** A `DataTexture` of
four grey steps as `MeshToonMaterial.gradientMap`, with `NearestFilter` on *both* `minFilter` and
`magFilter` or the bands smooth back into Lambert. Then turn the ambient down — it is the one
light that reaches every surface equally, which is precisely the distinction banding exists to
make.

**An inverted-hull outline must be sized from the geometry, not scaled by a factor.** Multiplying
every instance by 1.08 gives a 0.036-unit edge on a large object and 0.003 on a small one, both
sub-pixel. Treat the parameter as a world-unit thickness, read the geometry's bounding box, and
derive a per-axis scale of `1 + 2*t/size`. Prefer a scaled hull to a normal-pushed one when the
geometry is boxes: hard per-face normals split at the corners and the outline develops gaps.

*General lesson:* banding needs `NearestFilter` on both filters and an ambient turned down; an outline is a world-unit thickness derived from the bounding box, never a scale factor. On a Godot MultiMesh the inverted hull does not work at all - see the fresnel rim in `GODOT.md`.

---

## Fog, normal maps and displacement on a flat world

**Fog is not distance in a 2.5D game.** `FogExp2` measures distance from the *camera*, and a
camera twenty units back looking at a flat plane is equidistant from everything in it. Turning fog
up to fade the far edges instead puts an even grey wash over the whole picture. The thing that
falls off across the plane is a **point light**.

*General lesson:* any effect applied by distance hits the background hardest and is flat across a plane seen from a fixed camera; what falls off across a 2.5D plane is a point light.

---

**A normal map is how a photographed texture gets into a stylised game.** It carries no colour,
so the hand-tuned palette survives intact and every surface gains relief. Take the normal map out
of a CC0 PBR set and leave the colour map behind - that half is style-neutral, and the other half
is the join that shows in the first frame. Coreward's flat-shaded facets went from folded paper
to rock for 46 KB.

**Sample it on world position, for the same reason as the displacement below.** Mapped to each
cube's own UVs the detail restarts at every cell and the wall reads as a stack of identical
boxes. In three.js `vNormalMapUv` is an ordinary varying, so overwriting it with world XY in the
vertex shader is the entire change and everything downstream is stock.

**Expect to need a far higher `normalScale` than usual over flat shading, and measure it rather
than reasoning about it.** At 0.45 Coreward's was invisible; at 3.0 it read clearly with the
facets completely intact. Spreading one tile over several cells is what does it - only the
texture's low-frequency component survives, so the value that looks "wrong" is the correct one.
Check it lit by a moving lamp, not on a static screenshot of a flat-lit surface: the whole effect
is in how light rakes across it.

**Displacement keyed on world position is what makes stacked boxes read as rock.** Per-cell
displacement makes neighbours disagree at the seam. `flatShading` then derives normals from the
displaced surface for free.

*General lesson:* sample surface detail on world position so it does not restart at every cell; expect a much higher `normalScale` over flat shading and measure it under a moving lamp. In three.js `vNormalMapUv` is an ordinary varying you can overwrite in the vertex shader.

---

## Lights and layers

**Do not light the player's vehicle with the gameplay light.** Coreward's lamp is a point light on
the ship, so the ship sat four times closer to it than the rock it lit and rendered white whatever
its hull was painted. The real problem was worse than the look: lamp range is an UPGRADE, so
buying a Scanner level changed how the ship looked. Put the vehicle on its own layer with its own
small key light, and its material reads the same at every depth and every upgrade level.

*General lesson:* do not light the player's vehicle with a light whose range is an upgrade; give it its own key.

---

**`Object3D.layers` does not stop a light from reaching an object.** Layers decide what a
CAMERA draws. three.js collects a scene's lights once and hands all of them to every lit
material - there is no per-object light filtering in the forward renderer. Coreward put its
ship on its own layer specifically so the world's lamp would not reach it, and the comment
saying so survived three versions while a point light of intensity 44 sat on the ship lighting
it. The hull rendered pure white however dark it was painted.

**Excluding a light from an object means a second render pass**: draw the world with the
camera's layers excluding the object, then draw the object alone with that light's intensity
set to zero and `autoClear` off so the depth buffer survives. It costs no extra draw calls -
the same objects are drawn either way. Set `renderer.info.autoReset = false` and reset by hand
at the top of the frame, or every draw-call budget test silently starts measuring only the last
pass.

*General lesson:* **this one is backwards in Godot**: `Light3D.light_cull_mask` and `VisualInstance3D.layers` do filter lights per object, so a Godot session must not build a second pass for this. On three.js, if you do render twice, turn `renderer.info.autoReset` off or the draw-call budget only measures the last pass.

---

**A second scene does not inherit the first one's layer decisions.** Coreward's ship sits on its
own layer so the gameplay lamp cannot blow it out; moving it into the shop scene made it vanish,
because that scene's camera did not render the layer and its lights did not reach it. Anything
that reparents an object across scenes has to carry the layers, the lights and the background with
it — and a background especially, since a scene deliberately left transparent will show the wrong
thing through it somewhere else.

*General lesson:* anything reparented across scenes has to carry its layers, its lights and its background with it.

---
