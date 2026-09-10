# three.js / WebGL / DOM traps from the web-stack games

**Game:** Coreward, Captain Run, Wick, Candle Gift (web / PWA builds) · **Status:** shipped; Coreward and Candle Gift are live on GitHub Pages · **Read when:** working on a three.js or browser build; porting a web-stack lesson to Godot and wondering whether it still applies; something renders as nothing, or half of a feature works

The first four games were built on Vite, TypeScript and pinned three.js, installed as PWAs
from GitHub Pages. Most of the lessons in `CRAFT.md`'s "Graphics that carry on a phone" and
"Traps that have cost time more than once" sections are specific to that stack: three.js
defaults, WebGL's silent failures, and browser scheduling and storage. New games start on
Godot, where several of these traps do not exist and one of them (`Object3D.layers` and
lights) is exactly backwards. This is the reference list, kept so a web session does not
rediscover them and a Godot session does not import them by mistake. Each entry is the
original text followed by the one lesson that survives the API.

**Generalisable takeaways**

- **Enumerate the defaults you never set.** A missing uniform, a plane facing the wrong way, a
  texture read in the wrong colour space, a rotation composed in the wrong order - none of
  these errors; they render as nothing, as too bright, or as half a feature.
- **Assert against the compiled artefact and the frame, not the object you configured.** Read
  the shader back out of WebGL; drive real pointer events and check where the avatar is in
  normalised device coordinates; count what the renderer actually drew.
- **Budgets measured on one renderer are regression detectors, not hardware limits.** Draw
  calls were 5.0 us each on a desktop; fill rate and thermal throttling are what a phone
  charges for.

---

## Instancing and per-instance data

**Instancing is the whole game** — but not for the reason usually given. Coreward went from 207
draw calls to 35 by instancing terrain; Captain Run draws 26 vikings, 18 draugr, a boss, 420 loot
chunks and all scenery in 42–55 calls. What instancing actually buys is that **the draw count
stops being a function of how much content exists**, which is what keeps it from drifting as a
game grows.

**The "50 to 100 draw calls on mobile" rule of thumb is off by more than an order of magnitude,
and it is worth knowing that before designing around it.** Measured on Coreward: 5.0 microseconds
per call, linear from 79 to 2,519 calls, so about 3,200 calls to miss 60 fps on a desktop and the
high hundreds at worst on a phone. The game uses 60. A budget set at that guideline is a
regression detector wearing a hardware limit's clothes — useful, but do not let it talk you out of
a feature. **Fill rate is the real cost on a phone**, because that is what a heavier shader
charges and what feeds thermal throttling: Coreward's PBR terrain cost 0.098 ms/frame at an
unchanged draw count, which is more than a hundred extra draw calls would have.

*General lesson:* the draw count must not be a function of how much content exists. Godot's equivalent is `MultiMeshInstance3D`, and `visible_instance_count` is the number to assert a render path against. The 5.0 us/call figure was measured in WebGL on a desktop; the phone figure is inferred, and fill rate is the real mobile cost.

---

**Instance the body parts, not the character.** One `InstancedMesh` per part — leg, torso, arm,
head, helmet, weapon, shadow — with matrices recomputed each frame from a procedural animation
cycle. Crowd size then stops being a performance question at all, and a boss is the same rig at
3.3× with a different colour: a whole boss for zero extra draw calls.

**Instance the bolt-on hardware too, not just the crowd.** Coreward's upgrade parts started as
thirteen separate meshes and took the worst case from 55 draw calls to 67 against a budget of 70 —
three from failing CI, for what is four copies of two shapes. One `InstancedMesh` per KIND with
`count` as the lever is exactly the semantics an upgrade ladder wants (show the first n), and it
stops the draw count moving with how upgraded the player is, which is otherwise a budget that
fails only for veterans.

*General lesson:* one instanced mesh per KIND with `count` as the lever is the semantics an upgrade ladder or a crowd wants; a draw-call budget that only fails for veterans is not a budget.

---

**`setColorAt` is what makes one layer look like many objects.** Per-instance colour over a white
base material gives every unit its own cloak and shield, and drives a weapon's colour straight
from its tier — all from a single mesh.

**Per-instance data can never fade across a boundary.** Learned twice on Coreward: seams between
cells, then glow that stopped dead at a cell edge. If an effect has to be continuous across the
world, it belongs in a shader keyed on world position, not in instance data.

*General lesson:* per-instance data cannot fade across an instance boundary; anything continuous across the world belongs in a shader keyed on world position.

---

## Rotation order

**Two rotations on one object compose in an order, and the default is rarely the one you
want.** Coreward's ship carried its facing on `rotation.z` and its bank on `rotation.y`. Under
three.js's default `XYZ` the facing composes first and the bank then turns the already-turned
ship about the **world** vertical - a roll about the drill when pointing down, which is right,
and a swing of the nose toward the camera when pointing sideways, which reads as the ship
flipping out of the screen plane. `rotation.order = 'ZYX'` composes the other way, so the bank
applies in the ship's own frame and the facing turns the result: a roll in every facing. One
line, and it is worth checking the moment a second rotation is added to anything.

**A bank must read off the lateral axis in the object's own frame.** The same bug had a second
half: it was driven by `vx` regardless of which way the ship pointed, so flying left or right
banked the ship for going *fast* rather than for going sideways. Whichever axis the object is
not pointing along is the one that means "drifting".

*General lesson:* two rotations compose in an order; check it the moment a second rotation is added to anything. Godot's `Node3D.rotation_order` defaults to YXZ, so the fix is different but the check is the same. And a bank must read off the lateral axis in the object's own frame.

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

*General lesson:* banding needs `NearestFilter` on both filters and an ambient turned down; an outline is a world-unit thickness derived from the bounding box, never a scale factor. On a Godot MultiMesh the inverted hull does not work at all - see the fresnel rim in `PIPELINE.md`.

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

## Things that render as nothing

**When something new renders as nothing, check what is already in that slice of z before you touch
its colour.** Two parallax layers were invisible even in pure red, because an opaque backdrop
plane sat in front of them.

**And check the defaults you did not set, not the properties you did.** Wick's gate labels were
invisible; every property worth inspecting said they were fine - visible, positioned, textured,
renderOrder above the curtain, a texture with 27,000 opaque pixels. A `PlaneGeometry` faces `+z`,
that camera looks along `+z`, so the player only ever saw the back face and `FrontSide` culled
it. Papering over it with `DoubleSide` then rendered the text mirrored, which is the same bug
wearing a second symptom. Rotate the plane `Math.PI` about Y. **When something renders as
nothing, enumerate what you never configured.**

*General lesson:* when something renders as nothing, check what is already in that slice of z, then enumerate the defaults you never configured. `PlaneGeometry` faces +z in three.js; Godot's `PlaneMesh` faces +y.

---

**A uniform that is declared and never supplied is not an error, a warning, or a visible
failure.** GLSL gives a missing sampler texture unit zero and a missing vector all zeroes, so
the shader compiles, runs, and silently ignores whatever depended on it. Coreward's shadow fan
was added to the shader source and to one material's hand-written uniform list but not to the
other's, so the terrain rendered with no shadows at all while the light in the tunnels had
them. **Half a feature working is the worst possible symptom**, because it reads as a tuning
problem and sends you off measuring lamp intensities.

Two rules from it: **pass uniforms by iterating one shared object, never by naming keys in more
than one place** - a loop cannot forget - and **test it by pulling the `uniform ... name;`
declarations out of the compiled shader and asserting the material supplies every one.**
`renderer.properties.get(material).uniforms` against
`gl.getShaderSource(program.fragmentShader)`. Nothing else can see it.

*General lesson:* half a feature working is the worst symptom; pass uniforms by iterating one shared object, and test the compiled shader, not the material.

---

**A material has exactly ONE `onBeforeCompile`, and assigning it is how you silently delete
somebody else's shader.** Coreward patches stock three shaders in three places — world-space
displacement, world-space map UVs, and the propagated light. Each one wrote
`m.onBeforeCompile = ...`, so applying two to the same material kept whichever went last and
threw the other away. Nothing fails. The material compiles, renders, and is simply missing an
effect. Route every injection through one `chainCompile(m, patch, tag)` that calls the previous
handler first and appends its tag to `customProgramCacheKey`, and the order stops mattering.

**And `Material.clone()` copies neither `onBeforeCompile` nor `customProgramCacheKey`.** A clone
comes back as stock three with every injection gone. Coreward clones exactly one material — the
block currently being drilled — so the symptom was one cell in the whole world lit differently
from the rock it was cut out of. Found by eye, which is the expensive way.

**The test that catches both reads the compiled shader back out of WebGL.**
`gl.getShaderSource(program.fragmentShader)` on everything in `renderer.info.programs`, asserting
the injected call is present in every program that carries the other injection. Asserting on the
material proves nothing — the material is fine; it is the compile that lost it.

*General lesson:* any injection point that is a single assignable slot will silently drop somebody else's injection; chain it, tag the cache key, and test the compiled artefact.

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

## Cameras and coordinates

**A chase camera behind the player, looking along +z, mirrors the x axis - and it will invert
your controls.** Putting the camera at a *lower* z than everything it looks at is a 180-degree
rotation about Y, so world +x projects to screen LEFT. Measured in Wick: world +2 lands at NDC
-0.31. Mapping a rightward drag to increasing x - the obvious thing - therefore moves the
avatar the wrong way.

Captain Run shipped with this for its entire life and nobody noticed, which is the part worth
remembering: **every test drove the steering seam in world coordinates, which is exactly the
layer the bug lives under.** A test that says "steer(1.5) put x at 1.5" passes happily on
inverted controls. The only thing that catches it is driving real pointer events and then
asking where the avatar *is in the frame*, in normalised device coordinates. Every game with a
chase camera needs that one test.

Either move the player along -z so the camera keeps its default orientation, or flip the sign
where the drag meets the world and comment it loudly. Do not "fix" it later by flipping
something else as well.

**Take the first option.** Wrecking Crew draws the street along -Z while the simulation
counts distance upward, through one `wz()` helper called everywhere, so the camera is never
turned around and screen right IS world +X by construction - no sign flip anywhere near the
input. A flipped sign is a fact that has to stay true through every future change to the
camera; an axis convention is one that cannot come apart. Keep the NDC test either way, and
**verify it by turning the camera around and watching it fail** - it should name the
consequence ("a rightward drag will move the rig the wrong way"), not the geometry.

*General lesson:* every game with a chase camera needs one test that drives real pointer events and asserts where the avatar lands in normalised device coordinates. Prefer an axis convention (draw along -z) to a sign flip. Godot's camera looks along -z by default, so the trap is inverted there but the test is the same.

---

**A raycast reads world matrices, and those are only refreshed by a render.** Tap something in the
same tick a 3D screen opens — before it has ever been drawn — and every object is still at the
identity matrix, so the ray misses everything and the tap silently does nothing. It starts working
the instant one frame has gone by, which means it reproduces on a fast tap and nowhere else. Call
`updateMatrixWorld(true)` at the top of the pick.

*General lesson:* world matrices are only refreshed by a render; refresh before a pick. Godot's `global_transform` outside the tree returns identity rather than erroring, which is the same trap with a quieter symptom.

---

## Browser scheduling, storage and arithmetic

**Use `requestAnimationFrame` to draw, never to undo.** Anything that reverses itself on the next
frame sticks forever if the tab is hidden at that moment. An impact flash cleared from a rAF
callback stayed at 0.75 opacity over the whole UI — a "the CSS is wrong" symptom with a scheduling
cause. `setTimeout(..., 20)` instead.

*General lesson:* never schedule an undo on a frame callback; a hidden tab stops frames and the undo never comes.

---

**Ship a headless tick seam.** Split the loop into `frame(now)`, which computes dt and calls rAF,
and `tick(dt)`, which does everything else — then expose `tick` behind a `?debug` query param. A
whole run compresses into `advance(56)` plus a screenshot, deterministically and faster than real
time. It costs one `if`, and every balance number in Captain Run was set that way.

*General lesson:* split `frame(now)` from `tick(dt)` and expose the tick; this is the seam every balance number and every screenshot tool depends on, on both stacks.

---

**`localStorage.clear()` plus a reload does not clear anything** if the game saves on
`visibilitychange` — the outgoing page writes it straight back. Freeze `Storage.prototype.setItem`
first. Three sessions, three times.

*General lesson:* a game that saves on `visibilitychange` writes over any seed you plant; freeze `Storage.prototype.setItem` first.

---

Two follow-ons worth having in advance. **A 32-bit multiply needs `Math.imul`**: `x * 374761393`
is ~2^62, past what a double holds exactly, so the low bits a later xor-shift mixes down are
rounded away before use. And **balance tuned against a broken random source is tuned against a

*General lesson:* JavaScript numbers are doubles; a 32-bit hash multiply needs `Math.imul`. GDScript ints are 64-bit and do not have this problem. Test the random source itself.

---

- Chrome **refuses to create an `AudioContext` outside a user gesture**. Build the graph on
  first touch, and build it atomically — publish the whole graph or none of it, so one null
  check narrows everything.

*General lesson:* build the audio graph on the first gesture, atomically.

---

## DOM

**One scroll region per screen.** Giving an inner list its own `overflow-y` inside a flex column
quietly clips it at the fold — an entire category looked like it held one item, and another looked
like it did not exist.

*General lesson:* one scroll region per screen; Godot's `ScrollContainer` has its own failure (it does not scroll from a finger - see `PIPELINE.md`).

---

**For analog gauges in the DOM, use SVG and `pathLength="100"`.** It renormalises a path so its
length is exactly 100 regardless of the real geometry, so "show 62 per cent" is
`stroke-dasharray: 62 100` and nothing needs to know the radius. Needles are one transform
each. It stays crisp at any pixel density with no redraw, and the drawn fraction is directly
readable from a test - which is what lets an assertion follow a value from a bar to a dial
without becoming a lie.

*General lesson:* an analog gauge should expose its drawn fraction to a test; on Godot that is `_draw()` and a value on the node.

---

## The preview server serves the previous build

(From `PIPELINE.md`.)

- **`npm run preview` serves the service worker, so a driven browser can test the build BEFORE
  the one you just made.** The PWA registers its worker on the first visit and then answers
  navigations from cache, so a rebuild is one load behind - and unlike the phone, where this is
  expected and the build stamp is checked, nothing prompts you to doubt it locally. It cost an
  hour: a fix was verified as "still broken", diagnosed as a wrong diagnosis, and was actually
  correct all along. **Check the hashed filename, not the behaviour**, and clear it before
  trusting anything:
  ```js
  [...document.querySelectorAll('script[src]')].map(s => s.src.split('/').pop())
  // then, to start clean:
  for (const r of await navigator.serviceWorker.getRegistrations()) await r.unregister();
  for (const k of await caches.keys()) await caches.delete(k);
  ```
  A test suite is immune - Playwright gives each test a fresh context - which is exactly why the
  suite disagreed with the browser and the browser was wrong.

*General lesson:* check the hashed filename, not the behaviour, before trusting a locally served PWA build.

---
