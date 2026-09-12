# Wildform's creature shader: model-space uniforms, a flat-shaded rim, and the two debug modes

**Game:** Wildform (Godot 4.7, Forward Mobile, imported glTF creatures) · **Status:** shipped · **Read when:** writing a shader for an IMPORTED model; a pattern that reads as uneven lighting; a fresnel rim that reads as panels rather than a line; a shader whose output is wrong and whose code all looks right

Three findings from one shader, and all three are about the gap between the model the shader was
written for and the model the importer handed over. A uniform consumed in model space has no
fixed relationship to world scale, so the same constant means something different on every
creature. A fresnel written for smooth geometry does something else entirely on flat shading.
And a shader has no `print`, so the screen is the only instrument it has.

**Generalisable takeaways**

- **Tune a uniform in the space it is CONSUMED in.** `VERTEX` is model space, so a frequency
  uniform is tuned against `mesh.get_aabb()`, never against the node's world scale - an imported
  model relates the two by a different unknown factor each.
- **Assert the feature COUNT (`uniform * extent`), not the frequency.** The count is what the
  player sees and it is the same number on every model. The frequency is not.
- **A shader's only readout is the screen, so render the value.** Keep the debug render modes in
  the one-object screenshot script permanently rather than adding them each time a shader lies.

---

## A uniform consumed in model space is tuned off the mesh AABB

The creature bodies carry a noise pattern generated in the vertex/fragment shader from `VERTEX`,
which is in **model space**. The scale uniform was first derived from the node's world scale -
`26.0 * model_scale` - on the reasoning that a bigger creature should carry a proportionally
bigger pattern.

It gave **0.3 to 1.7 bands across a body** depending on which creature was on screen. At 0.3 bands
the body is inside a single noise cell, so the pattern is one smooth gradient over the whole
creature and reads as **uneven lighting**, not as a pattern - which sent the diagnosis at the
lights and the normals first.

The cause is that an imported model relates model space to world space by whatever factor its
author and its exporter agreed on, and that factor is different for every model in the table.
`model_scale` is the number that makes the creature the right size on screen; it says nothing
about how large one model-space unit is.

The fix is to tune against the extent in the same space the uniform is consumed in:

```glsl
// scale = <features wanted across the body> / model-space extent
uniform float noise_scale;
```

```gdscript
mat.set_shader_parameter("noise_scale", 4.0 / mesh.get_aabb().size.length())
```

`4.0 / mesh.get_aabb().size.length()` gives **4.0 bands on every model** (M), which is the point:
the derived quantity is stable across the content table while the raw uniform is not.

**The mesh AABB is useless for DRAW SIZE on a skinned mesh and is the correct and only source for
model-space extent.** Those two facts sit one line apart and are easy to read as contradicting each
other. They do not: `mesh.get_aabb()` describes the mesh resource, which is exactly what a
model-space uniform is consumed against, and says nothing about what the skinned, armature-scaled,
node-scaled result draws at. The draw-size half is in `ASSETS.md` (set it as a measured constant
per model in the content table and check it by eye against something).

**Assert the feature count, not the frequency.** `uniform * extent` is the claim - "between two
and eight bands across a body" - and it is a pure test over the content table with no GPU in it.
Asserting `noise_scale == 26.0` passes on the bug.

---

## On flat-shaded low poly a soft fresnel is a patchwork, not a rim

Inverted-hull outlines do not work on a `MultiMeshInstance3D` at all - the hull draws over the
object even six centimetres inside it - so the rim is a fresnel term in the material:

```glsl
float e = smoothstep(ink_width, ink_width * 0.35, abs(dot(NORMAL, VIEW)));
```

written so that **zero width means no line**, which is what makes the effect switchable for a
diagnosis.

At power 2.6 - a normal choice on smooth geometry - the creature rendered as a **patchwork of
light and dark panels** rather than as an outlined shape. On flat-shaded low poly every facet has
exactly one normal, so `dot(NORMAL, VIEW)` takes one value over the whole facet and a soft falloff
just paints each facet a different flat tone. The rim never gets a chance to be a rim.

**Power 4.5 or steeper** restricts the term to facets genuinely turned away from the eye, which is
the silhouette again, and the patchwork disappears. The general shape: a falloff that is smooth
across a surface on smooth geometry is a per-facet constant on flat geometry, so any exponent
tuned on a sphere has to be re-tuned on a low-poly body.

---

## The two debug render modes that belong in every screenshot script

**When a value is computed correctly and displayed wrongly, RENDER THE VALUE.** A shader has no
`print`, so the screen is its only readout:

```glsl
ALBEDO = vec3(f.g, f.r, 0.0);
EMISSION = vec3(f.g, f.r, 0.0);
```

One screenshot of that ruled out the solver, the upload, the world-position mapping and the
texture format at once, after three plausible hypotheses had each fitted the symptom and none of
them was true.

Two modes earn a permanent place in the one-object screenshot script rather than being written
again each time:

| mode | what it draws | what it answers |
|---|---|---|
| **`flat`** | every material one magenta, unshaded | if the picture does not change, the shader is not drawing at all |
| **`pattern`** | black body, white light | the only way to see what `EMISSION` alone is doing |

`flat` is the cheaper of the two and is the one to reach for first, because "the shader is not
running" and "the shader is running and computing the wrong thing" have identical symptoms and
completely different fixes.

This is `CRAFT.md`'s "attribute an artefact to a layer before touching the maths" one level down,
and it is the FIRST move, not the fifth. Related: **a shader that computes its own lighting must
say so with `render_mode unshaded`**, or `ALBEDO` is the base colour that lights multiply and a
surface excluded from every light renders black at every value of every constant (`GODOT.md`).
