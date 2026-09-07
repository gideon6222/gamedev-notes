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

---

## 2026-09-06 — Coreward, adding a build step

Supersedes the stack advice in the first entry. Coreward now builds with Vite and deploys
through GitHub Actions. TypeScript and the module split are not done yet.

**The no-build stack was not wrong, it was outgrown.** The first entry calls static Pages
plus an importmap the default until something forces a change. Nothing about it failed. What
forced the change was a single 1074 line app.js that needed types and module boundaries.
Still start every new game on the static stack: it ships in an afternoon and there is no
toolchain to argue with. Move to a build step when one file stops fitting in your head, not
because a build step feels more professional.

**A build step changes what a commit means.** Before it, pushing to main was the deploy, and
working straight on main was correct. After it, main serves raw source until the workflow
exists, and Pages has no preview environment to catch that. Tag the last good commit, branch
for the migration, merge only when the built output is verified. The tag is what makes the
branch safe, and it costs one command.

**Bundling three.js is smaller than loading it from a CDN.** Assumed the opposite. The
jsdelivr module is roughly 1.2 MB; the same version tree-shaken through Vite is 517 KB raw
and 135 KB gzipped, and it needs no network round trip on first load.

**Workbox cannot see a cache it did not create.** cleanupOutdatedCaches only removes
precaches matching its own naming, so the hand-rolled coreward-v5 cache survived the upgrade
and would have sat on the phone permanently: 1.31 MB, including the old CDN copy of three.js.
Delete legacy caches by pattern from the new worker's activate event. Not from the page:
during the handover the old worker is still serving the old index.html, which references a
path the new build no longer emits, so clearing from the page breaks the very load that is
supposed to hand over.

**A PWA is always one load behind.** The first launch after a deploy installs the new worker
while still serving the old app from cache. The second launch shows the new build. That is
correct service worker behaviour, not a failed deploy, and knowing it saves standing over a
phone wondering why nothing changed.

**Put a build stamp in the UI. This is the most reusable thing here.** A successful migration
makes the game look identical on purpose, and a PWA can be a load behind, so there is no way
to tell what is actually running on the phone. Every indirect check — storage size, cache
inspection, USB remote debugging — is slower and less certain than a dim line in the pause
menu reading the short commit and the build time. Inject it at build time, take the commit
from the CI environment, and mark dirty working trees so a local build can never be mistaken
for a commit that exists on the remote.

**Snapshot the pure functions before refactoring, and then make the snapshots fail.** Seeded
hash world generation is perfectly reproducible, so every cell of every planet can be pinned
before touching anything. Three traps found the hard way. JSON.stringify turns Infinity into
null, so bedrock's hardness vanished silently and the snapshot still compared equal to
itself; encode non-finite numbers explicitly. Git autocrlf rewrites golden files to CRLF on
checkout while the harness writes LF, so the suite breaks on the first fresh clone and in CI.
And a test that has never failed proves nothing: mutate a constant, confirm the right test
goes red, revert.

**On order-dependent algorithms, split the assertions into contract and canary.** The
autopilot BFS returns one of many equally short paths, chosen only by the order of an array
literal. Pinning the exact path makes a legitimate refactor fail for no reason. Assert what
actually matters — connected, passes through no solid rock, same length as an independent
search using a different neighbour order — and pin the exact path in a separate canary. If
only the canary fails, the change is safe. This needed a fixture with two symmetric routes to
work; the first fixture was insensitive to the reorder and quietly proved nothing.

**Vite hoists the entry script into head.** An error handler registered down in body is then
registered too late to catch a module that fails to load. On a phone with no devtools that
overlay is the only way to see a stack trace, so keep it the first script in the document and
verify it by deliberately breaking an import once.

**Still to come.** TypeScript, strict mode and the module split. Those lessons belong in a
later entry, once the game has actually been played on the phone afterwards.
