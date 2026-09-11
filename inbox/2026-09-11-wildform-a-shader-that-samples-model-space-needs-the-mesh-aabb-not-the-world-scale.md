# A shader that samples model space must be tuned against the mesh AABB, and that is the one question the mesh AABB answers honestly

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `GODOT.md` under shaders and
rendering traps, next to the existing note that a skinned mesh does not know how big it is.

## What happened

The creature shader draws glowing markings from a noise field sampled in **model space**
(`varying vec3 model_pos = VERTEX` in `vertex()`), because sampling in view space makes the
pattern swim across the body as the camera moves and reads as static rather than as markings.

The frequency was set from the creature's **world** size: `vein_scale = 26.0 * model_scale`,
one number per creature, reasoning that a band should be the same number of centimetres on
every body. Every renderer number looked fine. The picture was sixteen creatures in flat
blotchy paint with no markings on them at all.

The quantity that was wrong is the **band count**, not the frequency. Multiplying it out:

| | bands across a whole body |
|---|---|
| `26.0 * model_scale` (world-derived) | **0.3 to 1.7** |
| `4.0 / mesh.get_aabb().size.length()` | 4.0 on every model |

Most creatures sat **inside a single noise cell**. There were no bands; there was one soft
gradient across the whole body, which reads as uneven lighting and not as a design.

The reason the world-derived number could not work: these models are imported FBX, and each
one's local vertex coordinates are in whatever unit it was authored in, scaled back to game
size by a node above the mesh. Model space and world space are related by a **different,
unknown factor per model**. A frequency picked in world units lands somewhere arbitrary in
the space the shader is actually sampling.

## The rule

**A uniform consumed in model space is tuned against `mesh.get_aabb()`, never against the
node's world scale.** This studio's other note says the mesh AABB lies about how big a skinned
creature draws - it does, by a hundred times, because of the armature above it. But it is not
lying: it is reporting the mesh's extent **in the mesh's own coordinates**, which is exactly
and only the space `VERTEX` is in. Right answer, wrong question, the first time.

So: `uniform_value = <how many features you want across the body> / mesh.get_aabb().size.length()`.

**And assert the feature count, not the frequency.** A frequency assertion passes on any
number. `vein_scale * extent` is bands-across-a-body, a quantity with a readable range (2 to 8
here), and it failed instantly on the old formula. Store the extent as metadata on the material
so a headless test can recompute it.

## Two more, from the same renders

**A fresnel rim does not read as a rim on flat-shaded low poly.** Every facet has one normal,
so a soft fresnel (`power 2.6`) gives each facet one flat value and the body becomes a
patchwork of light and dark panels. Power 4.5 or steeper restricts it to facets genuinely
turned away from the eye, which is the silhouette again.

**An untextured `QuadMesh` particle is a hard SQUARE.** Twenty-six of them around a creature
read as missing art. A generated `GradientTexture2D` with `FILL_RADIAL` and alpha falling to
zero costs no file, no import and no APK size, and turns each one into a soft dot. Worth
generating once and using for every billboard particle in the game.

## The tool that settled it

Two debug modes on a one-creature screenshot script, and they should be standard:

- **`flat`**: paint every material one magenta. If the picture does not change, the shader is
  not drawing, and no amount of tuning was ever going to help. This ruled out the leading
  theory (that the models' own materials were winning) in one render.
- **`pattern`**: black body, white light. The only way to see what emission is doing rather
  than guess from a body the sun has already brightened. The blotchy facets and the missing
  bands were both obvious in it and invisible in the normal render.

## Replaces or contradicts

Extends `2026-09-11-wildform-a-skinned-mesh-does-not-know-how-big-it-is.md`, which says the
mesh AABB cannot be used to compute draw size. True, and it should not be read as "the mesh
AABB is useless" - it is the correct and only source for model-space extent.
