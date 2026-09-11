# A layout fix that measures the DOM must run after the DOM is visible

**Coreward, 2026-09-10, round six.**

A 3D shop is drawn on a full-screen canvas with an HTML tray laid over the
bottom of it. The camera was framing for the whole canvas, so the front row of
display cases was drawn under the tray. The fix: measure the tray and the header
with `getBoundingClientRect()`, and shift the camera's frustum by half the
difference so the room is composed into the band that is actually visible.

It shipped. It looked right. **It had never once run.**

```js
resizeStation();                          // measures the tray
buildShop();
ui.shop.classList.remove('hidden');       // ...which is still display:none
```

A `display:none` subtree measures zero on every axis, so the "if nothing is laid
out, use the whole screen" guard fired on every single open, and a camera angle
that had been hand-tuned against the BROKEN framing was quietly doing the job
instead. The tuning worked, so nothing looked wrong.

## How it was caught

Not by looking. By rule 11: verify a regression test by reintroducing the bug.
Deleting the framing fix did not fail the test that guards it - which is the
signal, because a test that passes with and without the code it protects is
testing nothing.

Two more things fell out of chasing it:

**The e2e viewport was right and the test still could not fail**, because the
composition had been tuned around the inert code. A test written after a
hand-tuned fix can be measuring the tuning.

**`setViewOffset` is a SHIFT, not a rescale.** Passing the visible band's height
as `fullHeight` does not move the composition up, it redefines the field of view
as covering only the band, and the whole room comes out at 47% of its size. To
slide the image without changing scale, keep the canvas size on both and put the
offset in: `setViewOffset(W, H, 0, (trayH - headerH) / 2, W, H)`.

## The rules

- **Anything that measures the DOM runs after the element is visible.** Unhide,
  then measure. The reverse order fails silently and forever.
- **A "nothing is laid out yet" fallback must be loud or rare.** A guard that
  fires on every call is not a guard, it is the implementation.
- **Suspect any fix you cannot make fail.** If deleting it changes nothing
  observable, either the test is wrong or the fix is.

Related: [[a-case-is-not-a-point]], from the same afternoon and the same room.
