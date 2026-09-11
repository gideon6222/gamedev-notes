# Godot blend shapes cannot morph one creature into a different creature, at all

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `GODOT.md` under rendering traps;
the technique itself belongs in `techniques/` once Wildform has built it.

## What happened

Wildform needs a creature to visibly become a bigger, different creature several times per
run, reading in under a second on a phone. The obvious first idea - and the one a session
under deadline will reach for - is blend-shape morphing between the two rigged models.

**It cannot work, and the reason is structural rather than a performance cost.** Godot 4
blend shapes (`MeshInstance3D.set_blend_shape_value(idx, value)`,
`find_blend_shape_by_name()`) interpolate **vertex deltas within one mesh resource**: the
target shape must share vertex count and topology with the base. Two separately authored
glTF creatures never do. There is no API that morphs mesh A into mesh B.

Worth knowing before the deadline, because this fails at the point where you already have
both models imported and have written the tween.

## The rule

**Blend shapes are for variation WITHIN one mesh** (body-shape sliders, a face, an accessory
toggle), never for turning one model into another. To change what a character *is*, hide the
swap instead of interpolating it: a noise-threshold dissolve shader tweened out on the old
mesh, a one-shot particle burst and a white flash over the instant of the swap, then the new
mesh reforming from the same noise. About 0.3 s out, swap, 0.3 s in. It needs no
correspondence between the two rigs, which is exactly why it works.

Two traps that come with it:

- **`GPUParticles3D` draws nothing on the Compatibility renderer** - it needs compute
  shaders, and it fails with no error logged. Mobile (the template default) is fine.
- **Freeze both forms at a matching rest pose before the swap**, or the visibility change
  pops even under the flash.

Fallback if the shader proves expensive on device: keep only the flash and the hard swap.
It still reads as a transformation, and it is close to what Pokemon's own evolution does at
its cheapest.

Source: https://godotshaders.com/shader/dissolve-godot-4-x/ (MIT).

## Replaces or contradicts

Nothing. New entry.
