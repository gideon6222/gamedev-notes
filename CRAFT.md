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
bonus of 8 percent per planet cleared.

---

## 2026-09-06 — Coreward, feel and audio pass

Research sources: Jonasson and Purho "Juice It or Lose It" (2012), Nijman "The Art of
Screenshake" (2013), Swink "Game Feel" (2008), and current Web Audio synthesis practice.

**Hit-stop is the highest value per line of code.** Freezing simulation for 35 to 80 ms on an
impact reads as weight. Identical animation with and without the pause feels like a different
game. Scale the freeze to the significance of the event: 35 ms for common rock, 75 ms for a
valuable strike. Freeze the simulation, not the render loop, and keep a separate raw delta so
camera and UI stay smooth through it.

**Layer three feedback channels on every action.** Visual, audio, and camera. A block breaking
fires debris particles in the mineral's own colour, a pitched sound, screen shake, and a
squash on the ship. None of these alone does much and together they change the feel entirely.

**Randomise pitch and filter cutoff on repeated sounds.** An identical sound fired twice per
second becomes noticeable and irritating within a minute. Vary playback rate 0.7 to 1.3.

**Audio must be fully synthesised here.** The GitHub connector cannot push binary files, so no
mp3 or wav will ever reach these repos. This turns out to be a feature: oscillators plus noise
buffers plus gain envelopes cover every effect, cost nothing to load, and work offline.
Structure: noise buffer built once, master gain into a DynamicsCompressor so overlapping
sounds cannot clip, separate music and sfx buses for independent muting.
The AudioContext must be created on a real user gesture or Chrome blocks it.

**Generative music beats a loop.** A chord bed of detuned oscillators through a lowpass, a
sine bass, and sparse pentatonic plucks scheduled with a 140 ms lookahead timer. Drive the
filter cutoff and the octave from a game variable, depth in this case, and the score darkens
as the situation does, with no transitions to author.

**Fake bloom with additive sprite halos.** EffectComposer bloom is too expensive on mobile and
affects the whole scene. A single 64px radial-gradient canvas texture on additive sprites,
parented to whatever should glow, gives the same read for almost nothing. Used on ore
crystals, cockpit, thrusters and pad lights. Pulse by animating sprite scale, not opacity,
since the material is shared.

**Gradient skies for free.** Render with alpha true and no scene background, then put a CSS
linear-gradient on the container element and update it from game state a few times a second.
Cheaper and better looking than a flat clear colour or a sky sphere.

**Spline flight beats stepping between waypoints.** Moving a vehicle along a CatmullRomCurve3
with an ease-in-out curve looks piloted. Stepping linearly from cell to cell looks like a
fast-forward, which is exactly what Gideon called it.

**Ideas still untried.** Instanced terrain, vertex colours, custom ShaderMaterial for
liquids, shadow mapping, a second orthographic scene for screen-space UI.
