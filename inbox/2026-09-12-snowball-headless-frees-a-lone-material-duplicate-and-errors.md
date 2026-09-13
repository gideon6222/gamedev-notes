# In a headless run, never let a MeshInstance3D hold the only reference to a material it was given

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Headless lifecycle

## What happened

Snowball's model loader forced every imported kit material to the game's roughness by duplicating it per MeshInstance3D (`get_active_material(i).duplicate()` then `set_surface_override_material(i, dup)`), so each node held the only reference to its copy. Headless (`--headless`, the dummy renderer), freeing such a node printed `ERROR: Parameter "material" is null. at: material_get_instance_shader_parameters (servers/rendering/dummy/storage/material_storage.cpp:264)` once per node - four per boot of the scene - and the test harness's error Logger turned every controls and bot-seam test red with "the body raised 4 engine errors". Reproduced with a twelve-line probe on rock.glb: overlay on, overlay off, a plain StandardMaterial override and a ShaderMaterial override all freed clean; only a duplicate held solely by the node errored, at `free()`. The material's RID is released before the instance stops asking for it. Fix: one unified duplicate per SOURCE material, cached in a static Dictionary keyed by the source's instance id and shared by every instance, which is also fewer materials. No error since, on the desk or in CI.

## The rule

In a headless run, never let a MeshInstance3D hold the only reference to a material it was given; keep duplicated or generated materials in a cache that outlives the nodes, and when the harness reports engine errors at `free()`, look for a material the freed node owned alone.

## Replaces or contradicts

nothing
