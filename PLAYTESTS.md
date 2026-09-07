# PLAYTESTS.md

What Gideon actually said about each game, in his words, dated. Complaints are the most
valuable entries here. Append, never rewrite.

---

## Coreward — github.com/gideon6222/coreward

Live at https://gideon6222.github.io/coreward/

Dig toward a planet core, sell ore at the surface pad, buy upgrades, break the core and the
planet explodes, launch to a harder planet. Fuel and heat are the two pressures pushing you up.

### 2026-09-06 — first run
"the game looks like it runs great"

Ran well on the S26 Ultra in Chrome, installed as a PWA. No performance complaints.

### 2026-09-06 — first real session, reached 75m

"I can afford upgrades pretty early on for fuel and cooling so neither is a risk."
Both pressure systems were defused before they applied pressure. Lesson: price the upgrade
that counters a threat against the depth where the threat actually begins, not against the
first haul.

"Right now it doesnt say it costs anything, so it feels free."
The Return button charged fuel but never showed the cost, so it read as a free teleport.
Lesson: an escape hatch with an invisible cost is the same as no cost.

His redesign, better than mine: no return button, running dry gets you towed home for a cut
of the haul, Tow Insurance reduces the cut, and Autopilot is a separate expensive unlock.

"It is difficult to judge the price of the different blocks you are mining."
Cargo counted units, so dirt and rubies took the same slot. Lesson: if the player cannot
compare two things on screen, the choice between them is not a real choice. Fixed with
weight-based cargo and a manifest showing count, weight and value per mineral.

"The ship should turn to face the direction it is digging in."

### 2026-09-06 — autopilot and music

"Instead of having the autopilot backtrack my path, can make it find the most efficient way
back? Also it looks like it is just fast forwarding."
Retracing the breadcrumb trail was both slower than necessary and, because it stepped
linearly from cell to cell at high speed, it read as a fast-forward rather than as flying.
Fixed with a breadth-first search for the shortest tunnel route and a Catmull-Rom spline with
ease-in and ease-out. Lesson: high speed alone does not read as motion. Curvature,
acceleration and a heading that follows the velocity are what make movement look piloted.

"The music has random higher pitch beeps that I dont like."
The score picked melody notes at random from a pentatonic scale. Musically valid, and it
still sounded like beeps. Lesson: randomness cannot substitute for melody. Without repetition
there is no phrase for the ear to latch onto, so isolated notes register as UI noise rather
than music. Also, a fast attack on a high sine is literally the shape of a notification
sound, which is exactly what he was hearing.

Fixed by writing an actual 32-beat theme in A minor over i - VI - III - VII, playing it only
every other cycle, giving every note a 0.3s attack and a long release, dropping it into a
register below where it gets shrill, and running it through a delay. The ambient bed was
thickened underneath with a continuous low drone and filtered air.

### 2026-09-06 — after the build-step migration

"I pulled it up on my phone and it has the correct version. I tested it and it runs well."

"It all looks good. It runs smoothly and I don't see any issues."

No gameplay feedback, and that is the entire point of recording it. The game moved from five
hand-written files to a Vite build, a generated service worker, TypeScript and sixteen
modules, and he had nothing to say about it. A migration that is invisible to the player is a
migration that worked.

Worth keeping in mind for the next one: nothing here is evidence that the *feel* is intact,
only that nothing obvious broke. Hit-stop, the camera lerps and the autopilot spline live in
the frame loop and were never covered by a test at any point. If a future refactor touches
that loop, ask him specifically about weight on a valuable strike and about whether the
autopilot still reads as flying, because those are the two things he has already complained
about once and would notice again.
