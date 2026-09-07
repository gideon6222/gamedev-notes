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

---

## 2026-09-06 — Coreward, TypeScript and the module split

Completes the entry above. One 1093 line app.ts is now 16 modules under strict TypeScript,
deployed and played on the phone with no change to how it plays.

**Convert in two moves, not one.** Rename to .ts with strict off first, fix only what the
compiler refuses to parse, and ship that. Then turn strict on in a single switch and work
through the pile. Tightening flags one at a time sounds gentler and is worse: each small
batch gets absorbed as noise, whereas one loud switch-on of 317 errors forces every one to be
looked at. The rename pass found six pieces of real looseness on its own — a number assigned
to style.opacity, isNaN called on a Date, two functions called with fewer arguments than they
declared.

**Check whether the library actually ships types.** three.js does not. Until @types/three was
installed, every three call in the render layer was silently any, and strict mode over that
layer would have bought nothing while looking like it had. Pin the types to the same version
as the runtime dependency.

**With verbatimModuleSyntax, `import type` is load bearing.** A plain namespace import used
only in type positions is still emitted. Writing `import * as THREE` in a types file would
have given the pure config, state and world modules a runtime dependency on three.js and
broken the headless tests. The word `type` is the whole difference.

**What strict actually caught, as opposed to ceremony.** A fog handle typed as the union
FogBase, where only one member has the `density` the frame loop writes every frame. A
direction held as an unconstrained string being assigned into a four value union. A sound
function whose signature demanded a number while its own body defended against undefined —
the signature was the liar, not the call site. Three empty array literals inferred as
never[]. None of these were crashing. All of them were wrong.

**Opting out honestly beats a fake green.** The audio module builds every node lazily on the
first user gesture, behind guards the compiler cannot follow through a function call.
Threading a narrowed context through 34 call sites would have been a real refactor of a
module with no null bugs, so those fields are typed non-null and the invariant is written
down in the file and in CLAUDE.md: the runtime guards protect this module, not the types.
Suppressing a check is fine. Suppressing it quietly is not.

**You cannot assign to an imported binding.** This is the thing that shapes how a single file
splits. State written in one module and read in another has to live on one mutable object,
the way a game state singleton already does. Do that promotion as its own pass before moving
any code. State that only one module touches should stay there — resist the urge to sweep it
all into the shared object because it looks tidier.

**Separate the module that renders from the module that wires.** Keeping DOM event handlers
out of the ui module is what stopped a cycle: the pause menu needs the hard reset action, and
the actions module already needs ui. The fix is layering, not a circular import workaround.

**Compare bundle sizes across a refactor.** This is the most valuable line in this entry. The
split silently dropped the last line of the file, the requestAnimationFrame call that starts
the loop. The game booted, drew one frame and sat there. Nothing caught it: the golden tests
only cover pure functions, the typecheck passed, the build succeeded. What caught it was the
bundle shrinking by 7463 bytes, because every function reachable only from the frame loop had
been tree-shaken away as unreachable. A build that gets smaller for no reason has lost
something.

**Type erasure gives a free proof.** After a pure typing pass the emitted bundle should be
nearly identical, so any delta has to be nameable. Phase 5 came out 110 bytes larger with
exactly one new string literal in it, the error message of the one helper that was
deliberately changed. That is a stronger statement than any test.

**The golden tests never once failed.** Across three phases of renaming, splitting and typing
they stayed green the whole way, and the only real bug was found by a bundle size. That is
not an argument against writing them. Their value was permission — being able to move a
thousand lines and know within seconds that world generation, prices and pathfinding were
still bit for bit identical. Tests that never fail during a refactor are the refactor going
well, not the tests being useless. But do not mistake them for coverage of what they do not
touch, and do check they can fail before trusting them.

**Findings that came from noticing, not from tooling.** The dropped line, the stale cache
that made a good deploy look broken, and a play test that showed a frozen game because the
browser tab was in the background and does not run requestAnimationFrame when hidden. Each
looked like a serious bug and only one was. Confirm what a symptom actually means before
acting on it.
