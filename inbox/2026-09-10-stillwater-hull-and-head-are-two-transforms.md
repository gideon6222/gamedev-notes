# In a first-person vehicle, the hull and the head are two transforms — never one

**Game:** stillwater  **Date:** 2026-09-10  **Belongs in:** CRAFT.md / feel and camera, and GODOT.md / first-person rigs

## What happened

Stillwater's camera was bolted to the boat's transform. That produces a trap with a
false floor, and the game fell all the way through it before anyone noticed.

Because the camera rode the hull exactly, honest hull motion was INVISIBLE: the gunwales
and the horizon moved together, so nothing on screen appeared to move, and the report was
"the boat is flat the whole time". The only lever available was to exaggerate the hull, so
pitch was multiplied by 4.2 until the horizon finally swung. Measured later with a probe:
**20 degrees of camera pitch peak-to-peak at 0.55 Hz, peaking at 42 deg/s.** The next
report was "the movement has felt odd."

Both reports were correct and the fix for each made the other worse, which is the signature
of a missing degree of freedom rather than a bad number. A person in a boat does not rotate
with it - the neck and the vestibulo-ocular reflex hold the head level whether they like it
or not - so the passenger sees the GUNWALES swing against a horizon that stays put, which is
the exact opposite of what a hull-locked camera renders.

Splitting them settled both at once:

|  | hull p2p | camera p2p | camera peak rate |
|---|---|---|---|
| before | 20.0 deg | 20.0 deg | 41.9 deg/s |
| after | 5.0 deg | 1.1 deg | 3.1 deg/s |

The hull now moves *more* visibly than before against a steady horizon while the view is
still, and as a free consequence it was possible to put the hull back to what a dinghy
actually does - rolling about twice as far as it pitches, where the exaggeration had made
pitch the larger of the two.

## The rule

**Any first-person camera carried by a moving object gets its own transform**, derived from
the carrier rather than parented to it: inherit the carrier's POSITION almost whole (0.9 is
a good default - translation is what sells "afloat" and it does not make people ill), take
**20-30% of its ROTATION**, and damp it with a time constant of about 0.5-1 s so the head
lags the deck. Published first-person comfort guidance puts the rotational share in that
band; the cautionary case is Sea of Thieves, whose hull-locked camera is the longest-running
complaint on its own forums and which the developers have declined to make optional.

The diagnostic that generalises past cameras: **when the fix for one complaint reliably
causes another, stop tuning the number and look for the degree of freedom that is missing.**
Two things that must be different were being driven by one value.

Measure it with a probe that steps the game headless and reports peak-to-peak, RMS,
frequency and peak angular RATE - rate is the number that predicts discomfort, and it is the
one nobody looks at. `stillwater/scripts/probe_motion.gd` is forty lines and is the reason
any of the numbers above can be defended.

## Replaces or contradicts

Nothing states this today. It is the concrete case behind INDEX.md standing rule 8 ("when a
complaint survives a correct fix, stop tuning and start measuring") - here the complaint did
not survive a correct fix, it survived a fix that was correct given a structure that was
wrong, which is the harder version and worth naming separately.
