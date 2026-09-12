# Anything the player holds up hangs off the CAMERA, and how far out is solved from the object's own measured size

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / Camera and light

## What happened
Stillwater lands a fish into the player's hands. The held fish sat at a fixed world position
chosen when the hold lasted 2.4 seconds on a timer, and it looked fine for 2.4 seconds. When
the hold became an untimed decision - keep it or put it back - the same position was measured
at 0.27 m from the lens and 0.40 m below the view axis, which is 56 degrees down against a
camera whose vertical half-angle is 37. The fish was off the bottom of the frame in the one
moment the game asks the player to look at it. Two things were wrong: it was parented to the
world rather than to the camera, so looking around moved it out of shot, and one distance
cannot frame a bluegill and a carp three times its length. The fix parents it to the camera
and computes the distance from the measured length, `d = 2.57 * L` clamped to 0.75-2.40 m,
which frames both by construction.

## The rule
An object the player is holding up to look at is part of the camera rig, not part of the
world: parent it to the camera so looking around cannot lose it. Solve its distance from its
own measured bounds and the camera's half-angle rather than picking a number, because the same
hold has to frame the smallest and the largest thing it can ever contain.

## Replaces or contradicts
nothing. It sits with CRAFT.md's "A first-person camera carried by a moving object gets its own transform: ~0.9 of POSITION, 20-30% of ROTATION, damped at 0.5-1 s" - that rule is about what the camera inherits, this one is about what hangs off it.
