# CRAFT.md

Design lessons that carry across games. Append dated entries, never rewrite.
Read this before designing anything. Write to it before ending a session.

---

## 2026-09-06 — Coreward, first build

**Stack that worked.** Static GitHub Pages PWA, three.js 0.166.0 from jsdelivr via importmap,
five files, no build step. Installed to the home screen from Chrome. Ran well on the S26 Ultra
on the first try. This is the default stack until something forces a change.

**Lighting values for three.js 0.166.** Physically based lighting means old tutorial numbers
render nearly black. Working set: AmbientLight 1.6 in the open falling to about 0.2 deep
underground, DirectionalLight 1.4 faded out below the surface, PointLight intensity 26 with
decay 1.3 carried by the player. Tying ambient intensity to a game variable such as depth is
the cheapest atmosphere available.

**Portrait camera math.** Aspect is about 0.46, so framing for a useful number of rows
vertically leaves only six or seven columns visible horizontally. Solve the camera distance
from the desired row count, then pan the camera horizontally within clamped limits. Keeping
the camera axis-aligned reads better in motion than a tilted one, even though tilt looks
better in a still.

**Progression numbers used.** Seven upgrade lines, nine levels each, cost multiplier around
1.9 to 2.1 per level. Named drill tiers rather than numbered levels. A permanent cross-run
bonus of 8 percent per planet cleared. Not yet validated by play, needs a note once he has
put real time in.

**Open question.** The opening is deliberately slow, twelve cargo and a bare drill. Suspicion
is that this is too slow for a phone game and the start should be more generous. Waiting on
his feedback before changing it.

**Technique not yet tried for him.** Instanced terrain, vertex colours, custom shaders,
shadow mapping. Pick one per new game and record the result here.
