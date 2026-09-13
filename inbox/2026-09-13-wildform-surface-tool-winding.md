# A SurfaceTool mesh that draws nothing is a winding order, and it looks exactly like fog

**Game:** wildform  **Date:** 2026-09-13  **Belongs in:** GODOT.md / the section on things that fail silently

## What happened
Wildform built a horizon backdrop—two long jagged ridge strips at 185 m and 270 m ahead—with SurfaceTool, PRIMITIVE_TRIANGLES, an explicit `set_normal(Vector3(0, 0, 1))` on every vertex, and a plain StandardMaterial3D. Nothing appeared on screen. The natural reading was "it is beyond the fog": the biome's fog density is 0.006 to 0.012 per metre, which at 185 m leaves between a third and a tenth of the colour, so a faint ridge was expected and a missing one looked like a tuning problem. The way to tell the two apart in one shot: colour the layers something that cannot occur in the scene (magenta and cyan), take a screenshot at the phone's aspect, and scan the pixels for either hue. Fog moves a colour toward the fog colour, but a magenta ridge at 185 m would still be the most magenta thing in the frame. The scan found neither—the strongest "magenta" in the upper third of the frame was rgb(135, 42, 60), which is a red hazard box on the track. So the mesh was not being drawn at all. The cause was the triangle winding order against the default CULL_BACK. `set_normal` does not decide which face is front—the vertex order does, and the normal being right is what makes the mistake invisible in code review. Setting `cull_mode = BaseMaterial3D.CULL_DISABLED` made both ridges appear immediately.

## The rule
When a SurfaceTool or ArrayMesh draws nothing, suspect the winding order before the material, the position, or the fog. `set_normal()` is not what decides the front face; the vertex order does. For a backdrop or any mesh seen from one side only, `CULL_DISABLED` is the right answer rather than a workaround—the overdraw is trivial and it removes a whole class of silent failure. To diagnose "drawn and faint" versus "not drawn": paint the mesh a colour that cannot occur in the scene and scan the screenshot for it, rather than staring at the frame.

## Replaces or contradicts
nothing
