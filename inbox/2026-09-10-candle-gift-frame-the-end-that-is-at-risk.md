# A framing probe must measure the end that is at risk, and a "worst" search must order its ties

**Game:** candle-gift  **Date:** 2026-09-10
**Belongs in:** `TESTING.md` beside the confounder rule, and `CRAFT.md` / Camera

## What happened

The contact sheet showed the player's batch cut off by the bottom of the screen. The camera
sat a hand-tuned distance behind the LEADER (`11.5 + tail * 0.45`, `tail` clamped at 16 m)
while the batch trails BACKWARD toward the lens and is 18 m long at full size - so the lens
pulled back 18.7 m for something 18 m long and the tail hung off the frame.

Three separate mistakes on the way to the fix, and each is a general shape.

**1. The probe measured the leader.** Written as "how far down the frame is the batch", it
took `Vector3(sim.x, 0, sim.distance)` - the leader - and reported a comfortable 0.71 across
three levels while the sheet plainly showed clipping. The leader is the FURTHEST candle from
a chase camera. The end at risk was the other one. A probe that disagrees with a picture you
are looking at is measuring the wrong quantity, and the picture wins.

**2. `get_global_transform()` on a node that is not in the tree returns IDENTITY** after
printing `Condition "!is_inside_tree()" is true`. A scene added to `root` during
`_initialize` is not in the tree until the first processed frame, so the first draft measured
every point against a camera at the origin and reported a uniform, confident 9.0 - "behind
the lens" - for the whole level. The repo already had the rule for the writing side
(`Transform3D.looking_at`, never `Node3D.look_at`); it governs reading too. Use `transform`,
or wait three frames the way the smoke suite does.

**3. A "worst" search whose sentinel is flat picks the wrong element.** Points behind the
lens all returned a flat `9.0`, so they compared EQUAL, and `if f > worst` kept the FIRST one
found - the candle nearest the leader rather than the one furthest off screen. The camera
then solved its framing against a candle several metres in front of the one actually hanging
off the edge. It held to level six and broke at level ten. Returning `9.0 + local.z` keeps
the ordering true through the whole range.

## The rule

**Name the end at risk before measuring.** For anything trailing a chase camera the nearest
element is the last one, not the first, and the two differ by the whole length of the thing.

**A sentinel value used inside a max or min must stay ordered.** A flat "way off" constant
turns a search for the worst case into a search for the first case. Order it by how far off
it is.

**And state the promise instead of tuning two numbers toward it.** Framing was `11.5` plus
`tail * 0.45` - two constants keeping one promise between them, which never holds across a
range. Replaced by one constant that says how far down the frame the last element may sit,
and a sixteen-step bisection on the pullback that meets it. Deterministic, so the golden and
the contact sheet still agree; monotonic, so it converges; lower-bounded at the old value, so
a batch of one is framed exactly as before.

**Ease such a solve asymmetrically.** Out fast, in slow. Pulling back is the frame keeping up
with something that just got longer, and lagging there IS the clipping the solve exists to
prevent - measured at 1.37 down the frame on level ten with one symmetric rate, 0.95 with
9.0 out and 1.6 in. Coming back in is only comfort, and doing it quickly right after an
obstacle takes half the batch snaps the world at the moment the player is already being
punished.

Measured, worst position of any candle down the frame while weaving (1.0 is the bottom edge):

| | L1 | L3 | L6 | L10 | L14 |
|---|---|---|---|---|---|
| before | 0.98 | 1.08 | 1.42 | 1.37 | - |
| after | 0.95 | 0.95 | 0.95 | 0.95 | 0.96 |

**Check framing at the size where it breaks.** Level one was 0.98 - just inside the edge -
and hid this for four rounds. A fixture where the bug barely shows reports the bug as tuning.

## Replaces or contradicts

Sharpens `GODOT.md`'s `Node3D.look_at` invariant, which is stated for the writing side only.
Extends `TESTING.md`'s confounder rule: here the test did not measure a confounder, it
measured the wrong END of the right object, which reads identically from outside - a
plausible number that moves when the game changes and is never the number in question.
