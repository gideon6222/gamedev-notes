# When you invert "camera moves to object" into "object moves to camera", delete the old follow — or the two chase each other

**Game:** stillwater  **Date:** 2026-09-10  **Belongs in:** GODOT.md / cameras and rigs, or CRAFT.md / first-person interaction

## What happened

Stillwater read its logbook by flying the camera down over a book lying in the boat, with a
per-frame branch that recomputed the eye's pose from the book every frame (needed, because
the arrival was a sequence and sequences end). Gideon asked for the book to be **picked up**
instead.

The inversion is elegant: `frame_pose` already computes where a camera must stand to fit the
whole spread, so taking the camera-to-book transform that implies and hanging the BOOK off
the live camera by it frames it identically while leaving the player's head free. Two lines.

It sent the book and the camera sixteen metres out of the boat, to the gate, within two
hundred frames. Because the old per-frame follow was still there: the book was now positioned
from the camera, and the camera was still being positioned from the book. Each frame added a
small offset and re-fed it, so it was not drift, it was **positive feedback with a gain just
over one.** Nothing errored, the gate stayed green, and the smoke suite passed - the book
still opened, paginated and hit-tested correctly, because all of that is relative.

What found it was printing the camera's world position after two hundred frames. What would
NOT have found it is any assertion about the book, because the book was in perfect shape
relative to a camera that was in the wrong county.

## The rule

Inverting a follow is a two-part edit and the second part is a deletion. Whenever you change
"A is positioned from B" into "B is positioned from A", **grep for every other place A is
written to in the same frame** and remove it. A leftover follow in the other direction is a
feedback loop, and a feedback loop is silent: it produces no error, and every relative
assertion between the two objects still passes because they are moving together.

Test it with an ABSOLUTE assertion, not a relative one — "the camera is still within 25 cm of
the seat", not "the book is in front of the camera". The second passes forever in a runaway;
it was the first that failed.

## Replaces or contradicts

Nothing today. It is a specific, cheap instance of the pattern that also produced the
hull-and-head lesson from the same session: one value driving two things that must differ, or
here two things each driving the other. Both are structure faults that present as tuning
faults, and both were invisible to a suite that only asked relative questions.
