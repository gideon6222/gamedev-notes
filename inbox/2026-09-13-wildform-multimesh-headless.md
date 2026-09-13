# MultiMesh instance transforms read back as identity under --headless, so a smoke test cannot check where an instance was placed

**Game:** wildform  **Date:** 2026-09-13  **Belongs in:** GODOT.md / things that fail silently / headless traps (cross-reference TESTING.md / a construct which cannot fail is untested)

## What happened

wildform added a roadside prop belt drawn with three MultiMeshInstance3D nodes. A smoke assertion was written to read each visible instance's transform back with `MultiMesh.get_instance_transform(i)` and prove none had landed inside the 4.0-unit steerable lane. It failed immediately with "a prop was drawn 0.00 units from the centre line". The picture was correct - a screenshot at 460x996 showed a forest either side of the road, nothing in it - so the assertion was wrong, not the code.

Measured both ways with the same scene, the same seed and the same code. With `--headless`: 36 canopies, 36 trunks, 17 rocks, and EVERY origin.x read back as exactly 0.00. With a real rendering device (`godot --path . --resolution 460x996`, Vulkan Forward Mobile): the same counts, and origin.x values of 26.08, -12.42, -33.04, 13.49, -4.61 for the canopies and -4.68, 22.64, -4.02 for the rocks. Zero identity origins.

The reason is that MultiMesh instance data lives in the RenderingServer, and the dummy server a headless run uses keeps no instance buffer to read back. `visible_instance_count` is a CPU-side property and IS correct headless; the per-instance transforms and colours are not.

## The rule

Under `--headless`, `MultiMesh.visible_instance_count` can be trusted and `get_instance_transform` / `get_instance_color` cannot - they return identity and white. A headless smoke test may assert HOW MANY instances are drawn, never WHERE they are. Placement belongs in a pure test on the arithmetic that decides it (make the placement function static and pure so it can live in the pure suite), plus a screenshot for the picture. This assertion is not merely weak headless, it is false: it fails on correct code, which is the worst kind of check because the first instinct is to "fix" the code.

## Replaces or contradicts

nothing
