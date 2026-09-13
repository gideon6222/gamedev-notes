# Snow depth reads through ambient occlusion and normals, not albedo, under soft sky light

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** techniques/godot-rendering-traps.md / rendering

## What happened

A carved trail (SubViewport depth map, ground shader dips vertices and tilts normals from its gradient, plus a 20% darker albedo in the rut) rendered as a one-pixel crease on white snow under a soft dusk sun and an HDRI sky, though the map was correct. Rendering the value (uniform int debug: EMISSION = vec3(depth, uv stripes)) proved the map, the mapping and the width in ONE screenshot (a 1.7 m rut for a 1.16 m ball, continuous), so the fault was in how the trough was lit, not in the data. On near-white snow the sky light is most of the light, so an albedo change is divided away by tonemapping and bloom; the lever that reads is AO (AO = 1 - 0.45*depth, AO_LIGHT_AFFECT 0.3) plus a bluer packed-snow albedo (0.74, 0.80, 0.96) and the normal tilt doubled. After that the rut read as a blue groove with a round bottom at 26 m camera distance.

Second half of the lesson: a vertex dip at a 1.5 m ground grid fell between vertices for a 1 m rut and came and went; the grid went to 0.75 m (7,200 tris per 30 m chunk, seven chunks live) and the fragment gradient carries the small ball's rut. Keep the debug uniform permanently and drive it from an environment variable (SNOWBALL_DEBUG_TRAIL=1) so the shot script can render the value without a code edit.

## The rule

On high-albedo surfaces under soft sky light, depth reads through ambient occlusion and normal adjustment, not through albedo changes alone; the vertex grid must be finer than the feature width, and use debug uniforms tied to environment variables to render intermediate values without code edits.

## Replaces or contradicts

- **When a value is computed correctly and displayed wrongly, render the VALUE.** Two frames
