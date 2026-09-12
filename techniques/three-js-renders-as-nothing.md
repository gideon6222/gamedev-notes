# three.js: the traps where something renders as nothing

**Game:** Coreward, Wick (web / PWA builds) · **Status:** shipped; Coreward is live on GitHub Pages · **Read when:** an object is in the scene and contributes no pixels; half a feature works and the other half silently does not; an effect vanished after a material was cloned or a second shader patch was added; "I cannot see it" on a phone

Split out of `three-js-traps.md` on 2026-09-12, when that file went over the 30 KB limit. This
is the silent-failure half of the web-stack list: the traps where WebGL raises nothing, the
console is clean, every property worth inspecting says the object is fine, and the frame is
still empty. They belong together because they share a diagnostic order rather than an API -
check what is already in that slice of z, then enumerate the defaults you never configured,
then read the compiled artefact back out of the driver - and because the last one in the file
is not a rendering problem at all. The entry point for the rest of the list is
`three-js-traps.md`; the material, colour-space and lighting half is in
`three-js-materials-and-lights.md`.

**Generalisable takeaways**

- **Enumerate the defaults you never set.** A plane facing the wrong way, a uniform declared and
  never supplied, an additive mesh depth-tested against the opaque shell it sits inside - none of
  these error. They render as nothing, or as half a feature, and **half a feature working is the
  worst possible symptom** because it reads as a tuning problem and sends you off measuring lamp
  intensities.
- **Assert against the compiled artefact, not the object you configured.** Pull the
  `uniform ... name;` declarations out of `gl.getShaderSource(program.fragmentShader)` for
  everything in `renderer.info.programs` and assert the material supplies every one. The material
  is always fine; it is the compile that lost the injection. Any injection point that is a single
  assignable slot - `onBeforeCompile` - will silently drop somebody else's patch, and
  `Material.clone()` drops all of them.
- **When a probe says the object is in the frustum and nothing draws, the next question is what
  is in FRONT of it.** On a phone that is usually the HUD, which lives outside the 3D scene where
  nothing in the 3D debugging toolkit can see it: Coreward's missing building sat at 24% across a
  portrait screen behind an action-button column that occupies 16-32% of one.

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

**An additive mesh inside an opaque one is depth-rejected, not blended.** A sight glass on a
Coreward machine — a dark tube with a glowing column of fluid in it, scaled to a level — was built
the obvious way: fluid cylinder, slightly smaller radius, same position as the tube. It drew
nothing. No error, no warning.

```js
// the tube: opaque, depth-written, drawn in the opaque pass
new THREE.MeshBasicMaterial({ color: 0x0a0f14 })
// the fluid: additive, depthWrite off, drawn in the transparent pass AFTER
new THREE.MeshBasicMaterial({ blending: THREE.AdditiveBlending, depthWrite: false })
```

`depthWrite: false` stops it writing depth. It does **not** stop it being depth *tested*. The
opaque tube has already written a nearer depth across every pixel the fluid covers, so every fluid
fragment fails the test and is discarded before blending ever happens — and **"inside" is "behind"
for the front half of the object.**

The fix is not to model it as contained. Make the opaque part the **backing** and put the lit part
in **front** of it — `fluid.position.z = tube.position.z + 0.06` — which is also how a real sight
glass reads from the front, so the physical model and the render order agree. `depthTest: false`
is the other lever and it is worse: it makes the glow draw through walls and through the player.

The symptom is specific and worth memorising: **the object exists, is in frame, has no console
error, and contributes zero pixels.**

*General lesson:* glass is not a container, it is a layer. Anything additive or transparent meant to be "seen through" something opaque must be drawn in FRONT of it, or the opaque surface removed from where the transparent thing is. True of any depth-buffered renderer, Godot included.

---

**When a 3D object "isn't rendering", check the HUD before the shader.** A new building was placed
beside Coreward's landing pad and did not appear. Twenty minutes went into shader theories — was
the custom light injection returning zero above ground, had `onBeforeCompile` failed silently, was
the material black against a black sky — before the arithmetic got done. The object was rendering
perfectly. It was behind four opaque HUD buttons.

The arithmetic takes thirty seconds:

```
halfHeight = distance * tan(fov / 2)
halfWidth  = halfHeight * aspect
screenFrac = 0.5 + (objectX - cameraX) / (2 * halfWidth)
```

Camera 17.7 units back, 52° vertical fov, 0.46 aspect (portrait phone): the visible world is about
eight units across, the object at x = -2.2 sat at **24% across**, and the action-button column
occupies **16–32%** of a portrait screen.

The diagnostic order that would have been faster:

1. **Is it in the scene, visible, and in the frustum?** Walk `scene.children`, print positions and
   `visible`, project the object's `Box3` centre with `.project(camera)` and check `z < 1`. Two
   minutes, and it said the object was fine.
2. **Does the console have a shader error?** It did not — so the material compiled, and every
   theory about the shader was already dead.
3. **Then it is occlusion**, and on a phone the occluder is usually the HUD.

Step 1 reported "in frame at screen (287, 366)" and the search still went to shaders, because "I
cannot see it" *feels* like a rendering problem. It was a LAYOUT problem, and the HUD is not in
the 3D scene, so nothing in the 3D debugging toolkit can see it.

Underneath it is a design rule: on a portrait phone the left column is usually action buttons and
the bottom is usually a d-pad and gauges, so **the largest clear area is upper-right**. Anything
that has to be looked at while docked or standing still belongs there, and "where the last thing
stood" is not a reason — the last thing may have been just as hidden and nobody noticed, because
it carried no information. The portrait projection arithmetic in full is in
`techniques/coreward-shop-room-and-hud.md`.

*General lesson:* when a probe says the object is in the frustum and nothing draws, the next question is what is in FRONT of it — a sibling at the same coordinates, or a HUD that lives outside the 3D scene entirely. Also: the screenshot that "proved" it was missing had the camera somewhere else, because the fixture had flown the ship across the world and never brought it back. Assert the subject is in frame before judging the photograph.

---
