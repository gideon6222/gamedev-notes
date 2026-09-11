# In a hand-stepped headless harness there is no viewport and no global_transform

**Stillwater, 2026-09-11.** Writing a smoke guard for "the reel is actually on screen during
a fight" hit the same wall twice, in two different disguises.

**`unproject_position` needs a live viewport.** Headless, `cam.get_viewport()` is null. The
first version of the guard therefore threw, and the suite printed **"all passing"** with the
check having never run. A guard that cannot run in CI is not a guard, and this one failed
silently in exactly the environment it was written for.

**`global_transform` returns IDENTITY.** The harness instantiates the scene and steps it by
hand rather than running it, so Godot does not consider the nodes inside the tree. Every
position comes back as the origin, and the rewritten guard duly reported the reel as "behind
the camera" - a damning-looking result that was no measurement at all. The same thing bit a
standalone probe an hour earlier, where it showed up as a wall of
`Condition "!is_inside_tree()" is true` and every point reading BEHIND.

**Both fixes are to do the arithmetic yourself:**

```gdscript
## World transform without the tree: multiply local transforms up the parent chain.
func _world_of(node: Node3D, stop: Node) -> Transform3D:
    var t := Transform3D.IDENTITY
    var n: Node3D = node
    while n != null and n != stop:
        t = n.transform * t
        n = n.get_parent() as Node3D
    return t

## Projection without a viewport. Godot's default keep_aspect is KEEP_HEIGHT, so
## `fov` is the VERTICAL angle and the horizontal one follows from the aspect.
func _on_screen(cam: Camera3D, world: Vector3) -> Vector2:
    var local := _world_of(cam, cam.get_parent()).affine_inverse() * world
    if local.z >= -0.0001:
        return Vector2(-1.0, -1.0)          # behind: fails the bounds check too
    var half := tan(deg_to_rad(cam.fov) * 0.5)
    var ndc := Vector2((local.x / -local.z) / (half * PHONE_ASPECT),
                       (local.y / -local.z) / half)
    return Vector2(0.5 + ndc.x * 0.5, 0.5 - ndc.y * 0.5)
```

Doing it by hand is **better than the engine call**, not merely equivalent: it tests the
PHONE's aspect rather than whatever window a desktop run happens to open, and it runs in CI.

Verified by reintroducing the bad mount: the headless numbers came back at -1.25 and -0.91
against the windowed probe's -1.20 and -0.85, so the hand projection agrees with the real
renderer to within the swell.

A separate probe that must use the engine's own `unproject_position` can still do so - it
just has to run from `_process` rather than `_initialize`, after the tree has processed a
frame.

Related: [[a-construct-that-cannot-fail-is-untested]]
