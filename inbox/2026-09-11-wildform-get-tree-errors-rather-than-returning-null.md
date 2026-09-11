# `get_tree()` outside the tree pushes an ERROR and then returns null

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `GODOT.md` under headless lifecycle.

## What happened

A pause sheet does the obvious thing:

```gdscript
get_tree().paused = on
```

The smoke test drives it, and the run failed with `Parameter "data.tree" is null` from
`get_tree`. The first fix was the natural one:

```gdscript
var tree := get_tree()
if tree != null:
    tree.paused = on
```

**That still failed.** `get_tree()` on a node outside the tree does not quietly return null -
it pushes an engine error FIRST and returns null afterwards. The guard ran, the assignment
was skipped, every assertion passed, and the suite still failed, because **an engine `ERROR:`
line is a test failure here even when nothing asserts**.

The correct guard is on the node, never on the result:

```gdscript
if is_inside_tree():
    get_tree().paused = on
```

## Why it comes up at all

A node added during `SceneTree._initialize()` is not inside the tree until the first
processed frame, which is exactly how every harness in this studio boots the real scene. So
this is not an edge case here, it is the default path for the smoke test.

## The family

This is the fourth member of a family that keeps costing time, and they are all the same
shape - **an API that needs the node to be in the tree, called from a harness where it is
not:**

| call | what it does outside the tree |
|---|---|
| `Node3D.look_at` | errors; use `Transform3D.looking_at` |
| `Camera3D.unproject_position` | errors and returns a meaningless vector |
| `Control.is_visible_in_tree()` | answers false for a control that is perfectly well built |
| `Node.get_tree()` | errors, THEN returns null |

**The rule: guard on `is_inside_tree()` before the call, not on what the call gives back.**
And when a claim can be made with arithmetic instead - a camera cone rather than a projected
point, a `visible` flag and a parent rather than a tree walk - make it with arithmetic, since
that works in a harness and needs no GPU.

## Replaces or contradicts

Extends the existing `GODOT.md` entries on `Transform3D.looking_at` and on `_ready` being
deferred, by naming the shared cause and adding the two members that were not listed.
