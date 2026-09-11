# Two Godot traps that both present as "my quad is not drawing"

**Stillwater, 2026-09-11.** Building a page-turn animation and a chalkboard in the same day
hit the same symptom four times from three different causes. All four looked like the quad
was missing; none of them was.

## 1. Writing `rotation.y` destroys the rest of the basis

`Node3D.rotation` is the Euler decomposition of the WHOLE basis, so assigning one component
rebuilds the basis from `(0, y, 0)`:

```gdscript
_leaf.rotation.y = angle          # throws away the transform that laid the page flat
```

The turning page stood bolt upright in the middle of the boat at twice the size of the book.
Keep a rest transform and compose:

```gdscript
_leaf.transform = _leaf_rest * Transform3D(Basis(Vector3.UP, angle), Vector3.ZERO)
```

## 2. `render_priority` only orders TRANSPARENT materials

Opaque geometry sorts by depth and ignores it. With `no_depth_test = true` on both a page and
the leaf turning over it, the draw order was undefined and the page won - so the leaf was
present, visible, correctly angled, correctly textured and drawn UNDERNEATH the thing it was
supposed to be covering. Setting `transparency = TRANSPARENCY_ALPHA` (alpha still 1) makes
the priority apply.

## 3. A `QuadMesh` faces its own +Z, and a reused basis carries the wrong intent

The logbook's page lies flat on a book, so its surface transform contains a "lie flat"
rotation. Reusing that basis for a wall-mounted chalkboard put the prices face-up at the
ceiling: on screen, a one-pixel strip of text seen edge-on. A vertical surface the player
stands in front of wants `Basis(Vector3.UP, PI)`, nothing more.

## 4. `SubViewport.get_texture().get_image()` returns black

Trying to photograph a page before refreshing it, so the turning leaf could carry the words
just read, produced a solid black readback every time. The viewport's texture is not finished
at the point a script can ask for it. **The design fix was better than the readback anyway:**
lift a page off a real book and what comes up at you is its blank REVERSE, not its front. No
snapshot needed.

**The meta-lesson: when a thing "is not rendering", get its position in CAMERA space before
touching anything.** Three of these were chased with screenshots and guesses first. One probe
printing the pivot, both faces and the page in camera space ended it in a single run - and
revealed that the fourth cause was the screenshot TOOL, which was running its room-setup
block between the animation being set up and the shutter opening.

Related: [[headless-harness-has-no-global-transform]], [[an-instrument-is-code-and-can-be-wrong]]
