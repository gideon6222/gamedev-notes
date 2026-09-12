# Godot rendering traps

**Game:** all of the Godot games  **Status:** every item measured and paid for
**Read when:** something is in the scene and contributes no pixels, a surface is too bright or too
flat, an outline or a depth read misbehaves, a shader's output is wrong and its code looks right,
or a draw loop reads as a hang. The web counterparts are `techniques/three-js-renders-as-nothing.md`
and `techniques/three-js-materials-and-lights.md`; several of these rules invert between the two
engines, so read the Godot one before porting anything.

Split out of `GODOT.md` at the 2026-09-12 digest, which needed the room. The standing rules most
worth remembering are still listed there; everything below is the detail, the constants and the
dead ends.

Two takeaways that generalise past rendering:

- **When a value is computed correctly and displayed wrongly, render the VALUE.** Two frames
  answer what reading the code does not, and the debug-term uniform belongs in the shader
  permanently rather than being added each time the question comes up.
- A default you did not set is still a decision the engine made for you. `fog_sky_affect` at 1.0
  and QOA on WAV import are both defaults, and both cost a session.

## The traps

- `rendering/textures/vram_compression/import_etc2_astc = true` is **required** for an Android
  export, and changing it does not re-import existing textures - delete `.godot/imported` and
  `--import` again. `config/icon` is required or the export errors.
- **The file Godot loads is not the file you committed: verify the artefact the engine
  produced, never the one you wrote.** A plain texture imports `compress/mode=0` (lossless) with
  no mipmaps, and Godot writes BOTH an `astc` and a `bptc` variant, so what ships has no
  relationship to what the source weighs and `ls -laS .godot/imported` is the only place the cost
  shows. Mipmaps are not optional on ground at a grazing angle. The measured costs and the bulk
  `.import` recipe are in `ASSETS.md`, which owns them.
- **WAVs import as QOA**, so `AudioStreamWAV.data` is compressed bytes: read as PCM, a 1.30 s
  generated fanfare measured 0.26 s and every "not silent" assertion had been passing on
  compressed noise. Measure the PCM off the file with `FileAccess` and the RIFF chunks, then
  assert SEPARATELY that `get_length()` and `mix_rate` match the header. Lengths, never samples.
- **Inverted-hull outlines do not work on a `MultiMeshInstance3D`** (the hull draws over the
  object even six centimetres inside it). Use a fresnel rim in the material, written so that zero
  width means no line, and **on flat-shaded low poly take the power to 4.5 or steeper** - every
  facet has one normal, so a soft falloff paints panels rather than a rim.
  `techniques/wildform-creature-shader.md`.
- **`DEPTH_TEXTURE` is corrupt on Forward Mobile with MSAA**, and turning MSAA off is not the
  answer. When a shader wants to know something about the world the simulation usually already
  owns it: upload the heightfield as a small texture and sample by world position - exact,
  testable headlessly, and the picture cannot disagree with the rules.
- **The mesh AABB is useless for draw size on a skinned mesh and is the correct and only
  source for model-space extent.** For draw size nothing you can ask describes what is drawn, so
  set it as a measured constant per model in the content table and check it by eye against
  something - `ASSETS.md` has the four ways of asking and what each one returned. But a uniform
  CONSUMED in model space is tuned against `mesh.get_aabb()`, never world scale, because `VERTEX`
  is in exactly that space and an imported model relates the two by a different unknown factor
  each. **Assert the feature count, `uniform * extent`, not the frequency.**
  `techniques/wildform-creature-shader.md`.
- **Godot blend shapes cannot morph one creature into a different creature**, at all:
  `set_blend_shape_value` interpolates vertex deltas WITHIN one mesh resource, so the target must
  share vertex count and topology, which two authored glTF models never do. To change what a
  character IS, **hide the swap instead of interpolating it** - dissolve out, flash over the
  instant, reform, 0.3 s each way, both forms frozen at a matching rest pose.
  `techniques/wildform-evolution-transform.md`. **`GPUParticles3D` draws nothing on the
  Compatibility renderer** - it needs compute shaders and logs no error; Mobile, the default, is
  fine.
- **Four ways a quad "is not drawing" that are not the quad**; print its position in CAMERA
  space first. Writing `Node3D.rotation.y` rebuilds the WHOLE basis from `(0, y, 0)`, discarding
  the transform that laid it flat - keep a rest transform and compose. **`render_priority` only
  orders TRANSPARENT materials**, so two opaque quads with `no_depth_test` draw in undefined
  order; `transparency = TRANSPARENCY_ALPHA` (alpha still 1) makes it apply. A **`QuadMesh` faces
  its own +Z**, so a basis reused from a flat surface puts a wall board face-up at the ceiling, a
  one-pixel strip edge-on; a vertical surface wants `Basis(Vector3.UP, PI)`. And
  **`SubViewport.get_texture().get_image()` returns black** from a script. An untextured
  `QuadMesh` particle is a hard SQUARE - a `GradientTexture2D`, `FILL_RADIAL`, alpha to zero,
  costs no file and no APK bytes.
- **`Basis.scaled()` scales the WORLD axes**, not the mesh's own. A cylinder rotated to lie
  along X is scaled `(length, radius, radius)`. Getting it backwards looks like a layout bug
  and is a transform one.
- **`TorusMesh` has no arc parameter**; a curved arm is a post and a leaning boom.
- **A procedural surface can be the expensive thing.** Thirteen octaves of noise over a third
  of the screen cost 1.60 ms a frame; two samples of a 36 KB texture cost 0.82 ms, within noise
  of a flat material (M, vsync off). Build the cheap case with the SAME uniforms.
- **Do not derive a normal from `dFdx`/`dFdy` on a surface seen at a grazing angle**: it is a
  speckle generator.
- **`fog_sky_affect` defaults to 1.0, so depth fog repaints the SKY.** The sky is at infinity, so
  a fog tuned on the water covers the whole sky in the fog colour, and a flat cream wall where a
  dawn gradient should be reads as a *missing skybox* - which sends you into the sky material
  hunting a fault that is not there. Drop it to about **0.2 (T)**. General form: any effect
  applied by distance hits the background hardest, so check the sky FIRST when tuning fog.
  `techniques/stillwater-fishing-fight.md`.
- **Data textures (normal, roughness, AO, masks) must NOT be sRGB-decoded; colour textures must
  be.** A data map decoded as colour comes back with its dark end lifted, and the surface reads as
  washed out or flat rather than as a broken import. `compress/normal_map=1` is the Godot half of
  it; the rest of the `.import` recipe is in `ASSETS.md`.
- **`Light3D.light_cull_mask` and `VisualInstance3D.layers` really do exclude a light from an
  object** in Godot - one flag, not a second pass. The opposite rule in
  `techniques/three-js-materials-and-lights.md` is a three.js limitation.
- **Walking a path once per follower is quadratic and reads as a hang**; one backward walk
  emits every follower as it crosses each threshold.
- Anti-aliasing on a phone: MSAA 2x at most, or FXAA. Keep `scaling_3d/scale` around
  0.75-0.85 for a heavy scene while the UI stays crisp.
- **A shader that computes its own lighting must say so: `render_mode unshaded`.** `ALBEDO` in
  a lit `shader_type spatial` is not the colour that reaches the screen, it is the base colour
  that LIGHTS MULTIPLY - so a surface excluded from every light (`light_cull_mask`) has nothing
  to multiply it by and renders black at every value of every constant. Go `unshaded` and write
  the finished colour to `ALBEDO`, or write the computed light to `EMISSION`. Nothing warns.
- **When a value is computed correctly and displayed wrongly, RENDER THE VALUE.** A shader has
  no `print`, so the screen is its only readout: `ALBEDO = vec3(f.g, f.r, 0.0); EMISSION = same;`
  ruled out the solver, the upload, the mapping and the texture format in one screenshot, after
  three plausible hypotheses had each fitted the symptom. Keep the `flat` and `pattern` debug
  render modes permanently in the one-object screenshot script
  (`techniques/wildform-creature-shader.md`). It is the first move, not the fifth.

