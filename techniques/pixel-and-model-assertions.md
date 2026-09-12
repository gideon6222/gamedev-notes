# Pixels versus the model: what to assert about a picture, and what to assert about the world

**Game:** Coreward (the map layer), Stillwater (the rod mount, the pool, the sign), Candle Gift (name plates) · **Status:** all four checks are in their repos; the map-layer one took three versions to become falsifiable · **Read when:** writing any check that reads a rendered frame; a layout assertion that keeps passing while the screenshot looks wrong; deciding whether a geometry bug is a pixel question or a model question

Two different instruments, and picking the wrong one is most of the cost. The model is exact,
needs no GPU, and its failure names the object. Pixels are the only thing that can see everything
going wrong at once. The recurring failure in both is the same: a check that would pass with the
feature deleted.

**Generalisable takeaways**

- **Test the PICTURE with pixels and the PLACEMENT with the model.** A geometry bug written as a
  number in the model is exact and free; the same bug chased through frame metrics is neither.
- **Measure BOUNDS, not origins, and demand a margin rather than a boundary.**
- **When a pixel assertion passes with the feature deleted, the fix is a narrower question, never
  a bigger threshold.**

---

## Bounds, not origins

**Measure BOUNDS, not origins, and demand a margin rather than a boundary.** A harness that
projected object **centres** against a 24-pixel margin passed a layout with two of five 136-pixel
name plates hanging half off the screen: the origins were comfortably inside, and the plates were
not.

Project all eight corners of the bounding box and take the screen-space rect. Anything carrying
text needs this, because a label's origin is nowhere near its edges. And `x > 0` passes for a
plate flush with the screen edge, which reads as unfinished - so the assertion wants a margin, not
a boundary.

## Which instrument for which bug

Two geometry bugs - a pool rendering striped, a sign hung at eye height - burned **three discarded
frame metrics** before being written as numbers in the model, where they are exact, need no GPU,
and the failure names the object. What frame statistics are for is everything going wrong at once,
which the model cannot see: an all-black scene, nothing drawn, a solid silhouette.

**Screen position near the lens is violently non-linear.** A rod butt half a metre from the camera
moved about a third of a screen per centimetre of mount, and two of three hand sweeps overshot
clean past the frame and out the other side. Sweep a near-camera mount as measured numbers, never
by eye - the eye is being asked to interpolate something that is not close to linear.

## A measurement over a WHOLE picture can be satisfied by the wrong part of it

Three versions of "did the map layer draw", each one verified by deleting the layer:

| version | what it counted | what satisfied it instead |
|---|---|---|
| 1 | non-background pixels | a survey grid drawn across the whole canvas on purpose |
| 2 | pixels in the layer's colour range | three full-width ruler lines, alone |
| 3 | a **difference at known positions** - a surveyed tile's centre against an unsurveyed one, same canvas, same scale, gap required | nothing else could |

Only the third is a real check. **When a pixel assertion passes with the feature deleted, the fix
is never a bigger threshold - it is a narrower question**: a named position, a control sample, or
a statistic that a handful of pixels cannot move.

And **take the MEDIAN, never the brightest.** The player's marker sits on a dug cell by
definition, so it is the maximum on its own and a max-based check is really a check that the
player exists.

## What makes a pixel check worth running

- Measure first, set the threshold from the measurement, then **break the build on purpose and
  watch it fail**.
- Give the runner a `--report` mode that prints and asserts nothing, so the numbers can be read
  without a pass/fail argument attached.
- **Sample every second or two across the whole level and judge the worst frame.** A handful of
  chosen moments is not a sweep.
- **Keep it local.** Thresholds derived on Vulkan do not transfer to a GPU-less CI runner, and two
  sets of numbers for one check is how a check stops meaning anything.

## Projecting by hand, and why it is better than `unproject_position`

- **Project by hand rather than calling `unproject_position`, and it is better, not merely
  equivalent.** Headless there is no viewport and `global_transform` is IDENTITY, so a guard
  written for CI either throws (suite prints "all passing", check never ran) or reports every
  point BEHIND the camera. Multiply local transforms up the parent chain and project with
  `tan(fov/2)` against the PHONE's aspect (`keep_aspect` is KEEP_HEIGHT, so `fov` is vertical):
  that tests the aspect the player has, not whatever window a desktop run opened, and it runs in
  CI. Verified against the windowed probe, -1.25/-0.91 by hand against -1.20/-0.85 rendered.

Moved out of `TESTING.md` at the 2026-09-12 digest; the one-line rule stays there.
