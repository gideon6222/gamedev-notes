# An additive mesh inside an opaque one is depth-rejected, not blended

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** engine traps

A sight glass on a machine: a dark tube with a glowing column of fluid in it,
scaled to a level. Built the obvious way - fluid cylinder, slightly smaller
radius, same position as the tube.

It drew nothing. No error, no warning.

```js
// the tube: opaque, depth-written, drawn in the opaque pass
new THREE.MeshBasicMaterial({ color: 0x0a0f14 })
// the fluid: additive, depthWrite off, drawn in the transparent pass AFTER
new THREE.MeshBasicMaterial({ blending: THREE.AdditiveBlending, depthWrite: false })
```

`depthWrite: false` stops it writing depth. It does **not** stop it being depth
*tested*. The opaque tube has already written a nearer depth across every pixel
the fluid covers, so every fluid fragment fails the test and is discarded
before blending. A transparent object behind an opaque one is invisible, and
"inside" is "behind" for the front half of the object.

## The fix

Do not model it as contained. Make the opaque part the **backing** and put the
lit part in **front** of it:

```js
fluid.position.z = tube.position.z + 0.06;   // in front, not inside
```

Which is also how a real sight glass reads from the front, so the physical
model and the render order agree.

## The general rule

**Glass is not a container, it is a layer.** Anything additive or transparent
that is meant to be "seen through" something opaque has to be drawn in front of
it, or the opaque surface must be removed from where the transparent thing is.
`depthTest: false` is the other lever and it is worse - it makes the glow draw
through walls and through the player.

## How to spot it fast

The symptom is specific: **the object exists, is in frame, has no console
error, and contributes zero pixels.** If a probe says the mesh is in the
frustum and nothing draws, the next question is what is in front of it - and a
sibling you positioned at the same coordinates counts.
