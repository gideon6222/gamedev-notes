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

---

## 2026-09-06 — Coreward, closing the gaps the migration exposed

The migration left three things it had itself proved were missing: nothing booted the built
game, nothing watched the bundle, and nothing covered the frame loop. Fixing those turned up
one real bug in the game that had been there since the beginning.

**Unit tests over pure functions cannot see a wiring bug. Boot the real build.** Playwright
loading the production artifact in headless Chrome catches everything the golden tests
structurally cannot: a dead frame loop, a broken import, a missing DOM id, a service worker
that precaches nothing. The single assertion worth the most is "hold a direction and check
the depth changes", because a frozen game passes every other check ever written. Headless
Chrome needs `--use-angle=swiftshader` for WebGL, and the whole suite runs in twelve seconds.

**Never sleep for a fixed time in a game test; wait on game state.** The frame loop clamps
its delta so a stutter cannot teleport the player, which also means that under load the game
advances in slow motion and three wall-clock seconds is not three game seconds. The first
draft of these tests failed for exactly that reason, on a game that was working perfectly.
Related: do not assert on a rounded readout. The HUD showed "DEPTH 0 m" while the ship was
still a cell above the pad, so waiting for it to detect a landing was a race.

**A size guard needs the right granularity to be worth anything.** Guarding total bundle size
at 3% was useless: the regression that started all of this removed 7463 bytes from a 506 kB
bundle, a 1.57% drop that sails through. One dependency dominating the bundle hides
everything else. Splitting three.js into its own chunk made the same regression a 22% shrink
of the 35 kB game chunk, which nothing lets through. It pays twice, because a gameplay tweak
now invalidates 35 kB of precache instead of 506 kB. Check the granularity by re-running the
mutation, not by reasoning about it.

**Test design intent, not just values.** A snapshot of the feel constants fixes the numbers,
which is worth having, but it says nothing about why they are those numbers and it has to be
re-recorded on every deliberate retune. Assertions like "ore must freeze longer than rock",
"the core giving way must be the biggest shake in the game" and "hit-stop must stay between
30 and 120 ms" survive retuning and are what actually encodes the design. Write both; the
second kind is the one that will still be true in a year.

**Wrap a browser API to observe what you otherwise cannot.** Nothing could see whether the
audio graph worked, because it is module-scoped and produces no DOM. Replacing AudioContext
in an init script and counting instances proved sound starts only after a user gesture, which
is what Chrome requires. But counting contexts alone would still have passed a graph that was
built and never published, since every sound would silently do nothing. Counting the buffer
sources created while drilling is what actually caught that mutation. Pick the counter that
fails for the reason you care about.

**`min(1, dt * rate)` is not frame-rate independent, and almost every game uses it anyway.**
One 100 ms step covers 60% of the distance to the target; ten 10 ms steps cover 46%. So
camera lag genuinely differs with frame rate, and with a delta cap a stuttering frame makes
the camera snap harder rather than merely lag. The correct form is `1 - exp(-rate * dt)`.
Found by writing a test asserting frame-rate independence and watching it fail against
working code. Left alone deliberately, with a test pinning the current behaviour, because
changing it changes how the camera feels and that is a decision rather than a tidy-up.

**A lazily built subsystem should be one nullable object, not many.** The audio graph is
created on the first user gesture and is null-or-complete, never partial. Typing it as
`Graph | null` means one check narrows every node at once, so the guards the code already had
became the guards the type checker reads, and every non-null assertion disappeared. Reach for
this before reaching for a suppression: an opt-out is sometimes right, but check first
whether the structure is simply better than the types were saying.

---

## 2026-09-06 — Read the game's own NOTES.md before trusting the shared pipeline

**The shared pipeline is now wrong about at least one game, and it will go wrong about more.**
The phone-game-studio skill describes every game as five files at the repo root with a
hand-written `sw.js` whose `CACHE` constant you bump on each deploy. That is still exactly
right for starting a new game. It is no longer true of Coreward, which has a Vite build,
sixteen modules and a generated service worker with nothing to bump. A session following the
pipeline there would go looking for a file that does not exist, and its fallback diagnosis
for "your change did nothing" points at a cache version when the real answer is the build
stamp in the pause menu.

So: **check the game repo's `NOTES.md` first, and let it override the shared pipeline.**
Coreward's now opens with a table of exactly where the two disagree. Any game that outgrows
the five-file stack should get the same treatment on the day it does, not later.

The general shape of this, worth remembering the next time anything is shared across
projects: a common how-to goes stale the moment one project outgrows it, and the project that
moved is never the one that remembers to update the shared doc. Put the per-project truth
inside the project, and make the shared doc defer to it. That way the document that is
easiest to keep correct is also the one that wins.

**Corollary about editing tooling.** The skill itself lives in a managed plugin cache that is
re-extracted and overwritten, so fixing it there does not stick. A fix that silently reverts
is worse than none, because you stop expecting the problem. When the tool cannot be fixed
where it lives, fix it where you do have control - in this case the two repos that the skill
already tells every session to read.

---

## 2026-09-06 — A threshold the player cannot see is not a mechanic yet

Coreward's heat pressure was rebuilt so that lingering deep escalates the damage rather than
depth alone deciding it. Playtest verdict: good mechanic, but "it doesnt seem very obvious
that there is a distinct line".

**The boundary has to be visible or the mechanic does not exist.** The rock band changed at
60 m while the heat threshold sat at 70 m. Ten metres of mismatch was enough that the only
marker of the real boundary was a number that never appears on screen. The player could feel
that a line existed and could not find it. Fixing it meant putting four signals on the same
metre: a new rock that starts exactly there, the sky, fog, ambient light and dust all shifting
to ember, the hull starting to drain, and the warning vignette building. One signal would have
been missable; four is unmissable.

**Announce the zone before charging for it.** The world tint ramps over about 26 m of digging
while the damage escalation takes 40 seconds. That ordering is deliberate: the world should
say "you are somewhere dangerous" before the hull says "and it is costing you". A warning that
arrives with the punishment is not a warning.

**Couple the numbers in a test, because they drift.** The rock boundary and the heat threshold
were almost certainly aligned once and separated during some later retune, silently, because
nothing connected them. There is now an assertion that the two constants are equal. Any pair
of numbers that must agree for the game to explain itself should be tied together by a test
rather than by a comment or by memory.

**Check that every content band is actually reachable.** Found while in there: the hardest and
most valuable rock started at 130 m, and the first planet's core sits at 110. It could never
be seen on the planet every player starts on. Generated content silently falls outside the
reachable range as other numbers move; assert reachability the same way you assert ordering.

**Believe the player about the symptom, not about the cause.** He proposed a bigger jump in
materials plus a visual change, which was the right fix. But the underlying problem was a
misalignment he had no way to see, not a matter of the contrast being too subtle. Take the
report seriously, then go and find out what is actually producing it.

## 2026-09-07 — Adding content to a hash-generated world without rebalancing it

Coreward's world is a pure seeded hash: `rnd(x, d, planet)` decides every cell, which is what
makes it reproducible and testable. Stage 4 added gas pockets, geodes, caves and per-planet
traits on top of it. Everything below came out of doing that.

**A new world feature must roll on its own seed offset, never the existing one.** If a new
check consumes the same roll the ore stream uses, every ore at every depth on every planet
shifts. The game is rebalanced end to end and the diff is three lines. Caves roll on
`planet + 77` against a coarse `(x/2, d/2)` grid, pockets on `planet + 41` against
`(x + 313, d + 977)`. The ore roll is untouched, so adding them is purely additive.

**Freeze the world as it was the moment before you add to it, and test the property rather
than the snapshot.** The pre-feature grid is kept as its own baseline with its own id legend,
and the test asserts the only legal difference: a cell either kept its id, or one of the new
things overwrote it. It also asserts the change touches more than 200 cells and less than 12%
of the world, so it cannot pass by generating nothing. That file is explicitly never
re-recorded - re-recording it is exactly the mistake it exists to catch. A plain golden
snapshot would have accepted a total reshuffle as "intentional, re-record".

**A hazard must not resemble a reward, and hue alone is not enough separation.** The gas
pocket shipped as a green crystal in dark rock, which is what an emerald looks like, at depths
where both appear. Fixed by changing the *form*: gas is now the only cell whose body is
emissive rather than its crystals, so it reads as a lit slab where every ore reads as dark
rock with sparks in it. Silhouette and material survive a small screen and a colour-blind
player; hue does not.

**The most valuable thing on screen must be the brightest thing on screen.** First pass made
the hazard glow harder than the payout, which points the player's eye at the thing they must
not touch. The hazard only has to be unmistakable. The reward has to be magnetic.

**Make a decoy break faster than its surroundings, not slower.** The gas pocket was initially
harder than the rock band it sits in, so you felt it coming and it became a tax. Softer means
you hit it by accident and the bang is a surprise. There is now a test asserting it is softer
than every band it can appear in, because the first version was wrong by 0.1 and nothing
noticed.

**A consumable must refuse rather than silently spend.** A full tank, an intact hull, no heat
soak: the button says why and keeps the item. On a phone these sit next to the movement
controls, and an item burnt for no effect is the kind of thing a player never forgives. The
same three states are worth generalising - hidden when you own none, dim when it would do
nothing, lit when it would help. In play the lit button *is* the advice, which turned out to
be better feedback than the count.

**Consumables and upgrades must sit on different axes or one kills the other.** An upgrade
raises the ceiling on every future run; a consumable buys one more minute on this one. Keep
the stack limits small (two or three), price the consumable that answers an uncapped threat
above the first level of the upgrade that answers it, and make sure a full kit costs more than
several rungs of the ladder. Otherwise stocking up quietly replaces deciding.

**Differing by numbers that all climb together is a difficulty slider, not variety.** Coreward's
planets had a deeper core, harder rock and better prices - so every planet was the previous
one with the dial turned up, and the ladder taught you nothing. Traits (twice the gas, triple
the geodes, riddled with caves, soak builds faster) give each planet a different question for
one multiplier each.

**A trait should multiply a layer, not the generator.** Every Coreward trait scales something
sitting on top of world generation and none of them touches the ore roll - enforced by running
the additive-only test with traits applied. This ruled out the trait I most wanted, a planet
where heat starts higher: that threshold is welded to the rock band, sky, fog and ambient
tint, and moving it changes block ids. Reaching the same idea from a different constant (soak
rate rather than heat depth) cost one parameter instead of a redesign.

**Put the modifier where the thing is already named.** The trait rides on the planet chip in
the HUD, because that is the only always-visible place the planet is named. A modifier you
have to open a menu to remember is one you play without.

### Two operational notes

**Seeding a save through localStorage and reloading does not work if the game saves on
`visibilitychange`.** The unload writes the live state straight back over the seed. Freeze
`Storage.prototype.setItem` for that key on the outgoing page first. This has now cost time
twice, in the browser and again in a Playwright test.

**A bundle-size budget only works if you update it when growth is real.** Coreward's had
drifted to +8% before a legitimate feature pushed it past the tolerance and failed the build.
The budget is a drift detector, not a ceiling: re-record it deliberately as part of any commit
that adds a system, and it keeps catching the accidental doubling it exists for.

## 2026-09-07 — Ten changes in one session, none of them playtested

Gideon asked for a full overhaul and said he would be away, so everything below was
verified by golden tests, smoke tests against the real build, and screenshots — never by
playing. That constraint shaped the work as much as the design did, and half these lessons
are about it.

### Economy and tension

**One resource is no resource.** Coreward had nine ores and five rocks that all converted to
the same number, so where you dug never mattered — only how long. That is a difficulty
slider wearing a resource system's clothes. The Dome Keeper design dive puts the threshold
at three: fewer and there is no decision, more and there is no comprehension.

**Gate an upgrade behind a place, not a price.** The best version of this is when the thing
that counters a threat requires surviving the threat first. Coreward's Cooling Rig now costs
emerald, which starts eight metres *inside* the heat zone — so you make a heat run without
protection in order to buy protection. That is the "hit a wall, upgrade, get past it" spine
that Motherload-likes live on, and no amount of money substitutes for it.

**A weight limit is what turns "which is worth more" into a decision.** The mineral gate only
creates a choice because cargo is capped by kilos: six emerald is 51 kg of a 60 kg hold, and
every kilo is one not spent on something worth more per kilo. Without the cap it would be a
shopping list.

**Attrition gives you one question; a rhythm gives you a bet.** A slow drain charges for time
and the answer is always "leave a bit sooner". A recurring, announced event — Coreward's
tremors collapse part of your tunnel every ~27 s past 85 m — makes depth a commitment rather
than a number, because what it takes is the way *out*.

**Never let a hazard take the run.** A tremor may cost time, fuel and patience. After
choosing which cells to collapse, the code re-runs the pathfinder; if the ship can no longer
reach the surface, the whole collapse is reverted and the tremor is spent as noise. Bound the
worst case explicitly and test the bound, or the mechanic is a coin flip on whether the
player quits.

**A discovery has to be un-re-rollable.** Cache contents come from the cell's own
coordinates, not from a random call, so closing the tab and reopening it cannot fish for a
better prize. Same discipline as the terrain; costs nothing; makes the reward testable as a
bonus.

**Reward the thing that is actually blocking them.** Once a mineral gate exists, the most
valuable thing a surprise can hand you is two emerald, not any amount of money. Weight cache
contents toward whatever the current bottleneck is, and money last — money is what the loop
already pays constantly.

### Making things legible

**Silhouette carries more than colour.** Third time this has come up and it has now been
wrong in three different ways: a green gas pocket that looked like an emerald, a pink supply
cache next to purple amethyst, and parallax background slabs that read as UI panels because
they were rectangles in a world made of chipped angular rock. Change the *form* — a lit body
instead of lit crystals, parallel machined faces instead of points, a jittered hexagon
instead of a plane.

**When a change must be noticed from memory rather than from comparison, change the amount,
not the shade.** Repainting the drill per tier is correct and completely invisible: at play
scale the ship is thirty pixels and the auger is eight of them. What reads is the drill
*spark* — and even there, Steel and Godcore are both pale, so hue alone is legible side by
side and forgettable alone. Three times the sparks, twice as fast, is legible alone.

**An upgrade you cannot see is one the player buys on trust.** Coreward's Scanner Array only
ever changed a light radius. Giving the ship a headlight cone whose length tracks that radius
turned the most invisible purchase on the shelf into a visible one, for one draw call.

**Give each pressure its own channel.** One red vignette driven by the larger of hull damage
and heat soak was fine while heat was the only thing that emptied the hull. The moment a
second source existed, the screen was saying "heat" for something that was not heat. Ember
edges are heat; a red pulse is the hull, whatever emptied it.

**A number beats a bar when the player needs to understand causation.** The single most
effective part of that fix was putting "HULL -3.4/s" on the hull bar while heat is draining
it. A coolant flush takes it to "-0.7/s" in front of you, which is the clearest possible
statement of what the purchase bought.

**Put the gauge on the thing it is eating**, and do not let it cover that thing. The soak
gauge lives inside the hull bar. At full height it covered the hull level entirely — the
gauge was hiding what it explains. Seven pixels of nineteen, along the bottom.

**Draw the player's own goal into the world.** A faint line across the rock at your previous
deepest reach is a target you set, as opposed to the core, which the game set. Freeze it at
the record you had when the run *started* — a line that retreats ahead of you is not a line
you can cross — and fade it once passed, or a moment becomes scenery.

### Adaptive music

**Vertical layering needs one tempo, one key, one harmony** — which a procedurally generated
score gets for free, since it is all coming off one scheduler.

**Fade times should not match.** Places arrive slowly (a second and a half); alarms snap in
over a quarter second and leave lazily. Late is useless for an alarm, and one that vanishes
the instant you patch the hull teaches you nothing about how close it was.

**Route the alarm past the filter that is darkening everything else.** Coreward closes a
lowpass over the whole score as you descend. The danger layer bypasses it, because the moment
it needs to be heard is exactly the moment everything else is being muffled.

**A texture reads as ambience; only a rhythm reads as movement.** The unstable-band layer is
scheduled thuds on beats 3 and 6, off the downbeat — on it, they would read as part of the
score rather than as something else in the room.

### Working without a playtester

**When a mechanic is a clock, extract the clock.** The tremor rhythm is a pure reducer taking
a clock and a delta and returning the next clock. Otherwise the only way to see it run is to
sit in the band for thirty-four seconds with a renderer attached — and the preview pane stops
animation frames entirely when it is hidden, so that was not even possible. Extracting it
immediately found a real bug: a long frame armed the warning and fired on the same tick, then
armed it again on the next.

**A safety property tested against a case that cannot trigger it is worse than no test.** The
first collapse fixture dug below the depth the pathfinder refuses to search, so every collapse
silently reverted and three tests passed while checking nothing. Fixtures should assert their
own preconditions, and a guarantee test should count the events it is guaranteeing about.

**Measure the worst case, not the reachable one.** The draw-call budget test dug down for a
few seconds, which by the end of this session measured a window with three block types in it.
Seeded to a deep opened-out chamber with rubble and caches, the real number is 50 of 70. A
budget that only ever sees the easy case has quietly stopped being a budget.

**Convert tuned constants rather than re-deriving them.** Fixing frame-rate-dependent
smoothing could have changed how the camera feels, which is the one thing a desktop cannot
verify. Instead every rate goes through a helper returning the exponential rate that covers
the same fraction in one 60 fps frame, and the golden baseline records those fractions — so
the file itself proves the feel did not move.

**Anything a test installs on the page must go in after the last reload.** A counter set
before a reload is wiped, and incrementing an undefined value produces NaN, which surfaces as
"expected 1, received NaN" — a failure that reads like a claim about the game.

**When something new renders as nothing, check what is already in that slice of z before you
touch its colour.** Two parallax layers were invisible even in pure red, because an opaque
backdrop plane sat in front of them.

## 2026-09-07 — Second Coreward overhaul: seven asks from one playtest

All of these came out of Gideon playing for an hour and writing a paragraph. Every one of
his observations turned out to name a structural problem rather than a matter of degree,
which is the pattern worth remembering more than any individual fix.

### The player names the symptom; go and find the cause

**"The light upgrade doesn't seem beneficial. I can see all of the blocks on screen."** The
Scanner changed a lamp radius while the camera framed a fixed number of rows, so the whole
frame was always inside the lit circle. No amount of tuning the radius could have fixed
that. The framing had to belong to the upgrade. Once it did, his *other* suggestion —
distant blocks being hard to identify — arrived free, because a tight camera means the lamp
no longer covers the frame.

**"I can always dig but if the hull is full, leave the resources floating."** A full hold
had stopped the drill dead and shown a number. That is the worst kind of wall: it does not
ask the player to decide anything, it just stops them doing the thing the game is about.
Ore that will not fit now waits at the cell it came from. It turned cargo capacity from a
hard stop into a rate limit on value per trip, which is a far better shape.

### Make the decoration mean something before you add more of it

**"I like the sections of texture. Make those give more."** Decorative flecks had been
scattered by one seeded roll. World generation now uses *that same roll* to decide which
cells are worth more, so the texture and the payout agree by construction rather than by
being kept in step. **The best new mechanic is often the one already drawn on screen.**

Two calibration notes. A third of all rock was far too many — the screen stopped saying
"some of this has mineral in it" and started saying "the rock is made of mineral", and every
wall went sandy. A sixth reads as a find. And the *blend* of the seam's own colour into the
band had to come down to a fifth: the cell has to stay recognisably its own band, because
the flecks are what the eye is meant to catch.

### A shop is a place, not a list

Grouping the upgrades onto named counters, giving the panel a sticky header with the
station's name and the planet, and — the part that does the work — **showing locked stock
rather than hiding it**. A sealed row that says "Sealed until you have reached 90 m" is a
reason to go deeper. A hidden row is nothing at all. Depth is a currency you can charge in,
and it is the only one that cannot be farmed.

### Abilities need a meter, and the meter is the design

A bomb and a laser, both spending one shared Power Cell pool that trickles back underground
and refills at the surface. That combination is the whole balance:

- the trickle means a long descent is never completely without an answer
- the refill gives the home base a purpose beyond selling
- a cap of four means a meter you can spend twice is a decision, not a second drill

They ignore hardness, so their value scales with exactly the thing that makes drilling slow —
which means they get better the deeper you go without a single line of tuning.

**Two abilities need a reason each to exist.** The first version had the bomb clear five
cells for two power while the laser cleared five for one — and the bomb unlocked earlier and
cost half as much, so owning both made the bomb pointless. There is now a test asserting the
expensive-to-fire one clears more per point *at every level*, with the other keeping reach
instead. Write that test before tuning, not after.

**Two gates on one thing means one of them is decoration.** The laser was gated at 90 m of
depth and by a mineral available from 22 m. A test now asserts every gated upgrade's mineral
lives within 30 m of its unlock depth, and it caught this before a human did.

### A secondary objective has to be a thing you keep

Money is a rung: every amount you earn makes the last amount irrelevant, so "what have I
got" is always a number that will look small next week. A collection is the opposite. One
relic per planet, buried below the halfway mark, marked on nothing, granting a permanent
perk — and it is **the only thing in the game you can miss permanently**, because breaking
the core takes the planet and everything still in it. That last property is what makes it
worth looking for rather than something you will pick up eventually.

**One cell on a planet with nothing marking it is a lottery, not a secret.** What turns
searching into a skill is a bearing: within the Scanner's radius, a mote drifts off the ship
in the relic's direction and brightens as you close. That gave one upgrade a third distinct
job — light, framing, finding — and three reasons to buy the same thing is worth more than
three upgrades with one reason each.

**Perks should be data, not callbacks.** Each one is read by a named derived stat rather
than being a function the relic runs, so a perk cannot do anything a test cannot see. There
is a test that applies every perk alone and asserts the stat it *claims* to move actually
moves — a perk that is described and never wired is the easiest thing in this category to
ship and the hardest to notice.

### The bug worth generalising

Past the eighth relic, every planet granted the same stacking perk. The check for "is this
relic still in the ground" asked *do I already own this perk*, which answers yes for every
planet from the ninth onward — so relics silently stopped existing for the rest of the game.

**What you own and what you have done are different lists.** Any time a reward repeats,
the "already collected" test has to key on the *event*, not on the reward. Verified the fix
by reintroducing the old check and watching the new test fail, which is the only way to know
a regression test regresses anything.

### Two smaller ones

**Rounding before clamping.** A new perk turned a tow cut into `0.5 - 8*0.05 - 0`, which is
0.09999999999999998 in floating point, and the golden baseline duly recorded a cut of
9.999999999999998%. True, useless, and exactly the kind of diff that trains you to
re-record without reading — the one habit golden baselines cannot survive.

**Categorise the kinds of legal change in a world-diff test.** An "additive only" assertion
with a single percentage ceiling broke when seams converted a third of all rock, because it
was counting a rare-pocket overwrite and a wholesale category conversion as the same claim.
Counted apart, with a ceiling each, both stay meaningful. A test whose failure message
blames the wrong subsystem is worse than one that does not fire.

## 2026-09-07 — Captain Run, a second game and the first one not built like Coreward

Gideon sent a screenshot of a commercial viking crowd-runner and asked whether that level of
graphics was reachable. It was, with no assets at all. Everything below came out of building
it in one session on the five-file static stack.

### Reproducing a mobile art style with zero assets

**Cel shading is a three-line texture, and the thing that kills it is ambient light.** A
`DataTexture` of four grey steps (0.36 / 0.62 / 0.84 / 1.0) as `MeshToonMaterial.gradientMap`,
with `NearestFilter` on *both* `minFilter` and `magFilter` or the bands smooth back out and
you have Lambert again. The first pass looked flat and I blamed the gradient; it was ambient
at 1.15 washing every band into the same value. Ambient 0.72, hemisphere 0.55, directional
2.6 is where the bands actually read. Ambient is the enemy of toon shading — it is the one
light that reaches every surface equally, which is precisely the distinction banding exists
to make.

**An inverted-hull outline must be sized from the geometry, not scaled by a factor.** The
first attempt multiplied every instance matrix by 1.08. On a 0.9-unit crate that is a
0.036-unit edge; on a 0.075-unit axe haft it is 0.003. Both sub-pixel on a phone, so the game
rendered with no visible outlines at all, and I spent a diagnostic pass proving the meshes
were in the scene, visible, BackSide and correctly counted before realising the geometry was
right and the *width* was the bug. The fix: treat the parameter as a world-unit thickness,
read the geometry's own bounding box in the constructor, and derive a per-axis scale of
`1 + 2*t/size`. Constant edge width on every object regardless of its size.

**Prefer a scaled hull to a normal-pushed one when the geometry is boxes.** Pushing vertices
along the normal gives constant thickness for free, but box normals are per-face and hard, so
the corners split and the outline develops gaps. Scaling has no gaps. Save the normal push
for smooth-shaded geometry.

**Instance the body parts, not the character.** One `InstancedMesh` per part — leg, torso,
belt, arm, head, beard, helmet, horn, haft, blade, shield, blob shadow — with matrices
recomputed each frame from a procedural run cycle. 26 vikings, 18 draugr, a 3.3x boss, 420
loot chunks and all scenery come to 42-55 draw calls, and crew size stops being a performance
question at all. The boss is the draugr rig at 3.3x with a different `instanceColor`: a whole
boss for zero extra draw calls.

**`setColorAt` is what makes one layer look like many objects.** Per-instance colour over a
white base material gives every viking its own cloak, beard and shield, and drives the axe
blade colour straight from the weapon tier — all from a single mesh.

### The bug worth generalising

**Any subsystem written as reset -> push -> flush will eventually be missing its flush, and it
fails completely silently.** The enemy layers were never flushed, so `count` stayed 0 and
every draugr in the game was invisible — while still charging, still costing crew, still
being killed. The crew was dying to nothing on screen and I read that as a balance problem
and spent a tuning pass on it. Nothing errored, nothing looked broken, the frame rate was
fine. What found it was comparing `mesh.count` against the entity list length. **If a render
path has a count, assert that count against the model.** A subsystem that renders nothing and
a subsystem that does not exist look identical from outside.

### Working without a visible tab

Coreward's notes already record that `requestAnimationFrame` does not fire in a background
tab. The new part is what to do about it: **split the loop into `frame(now)`, which computes
dt and calls rAF, and `tick(dt)`, which does everything else, then expose `tick` behind a
`?debug` query param.** A whole run — 50 seconds, five gates, the boss, the death path — then
compresses into `__CR.advance(56)` plus a screenshot, deterministically and faster than real
time. Every balance number in this game was set that way. Ship the seam: it costs one `if`,
and it is how the next session will test too.

**Anything that undoes itself on the next animation frame will stick forever if the tab is
hidden at that moment.** The white impact flash set opacity to 0.75 and cleared it from a rAF
callback, so the boss-kill flash stayed at 0.75 over the camp screen and made the entire UI
look washed out — a "the CSS is wrong" symptom with a scheduling cause. `setTimeout(..., 20)`
instead. Rule: use rAF to *draw*, never to *undo*.

**The localStorage writeback trap, confirmed a third time.** `localStorage.clear()` followed
by a reload restored the old save again, because the outgoing page saves on
`visibilitychange`. Freeze `Storage.prototype.setItem` on the outgoing page first. This has
now cost time in three separate sessions; it is worth doing reflexively.

### Runner design

**An enemy that dies at maximum range is an enemy the player never sees.** With 22 units of
attack range and a squad out-damaging a grunt twentyfold, every draugr evaporated at the
horizon and combat was a number changing. Giving them a 6 u/s charge toward the crowd —
against the player's 11 u/s — closes the gap in about a second, so they die at four or five
units, in frame, in a spray of loot. Same damage, same difficulty, completely different game.
**Where a fight resolves matters more than how long it takes.**

**Two upside gates are a better decision than a good gate and a bad gate.** "+6" against "x2"
has no correct answer — it depends on how many crew you have at that moment, which differs
every run — so the player is genuinely choosing. Good-versus-bad is a reflex test. Keep a
minority of punishing gates for tension, and never let a gate take the crew below 1: the run
should be lost to a fight, not to a lane picked in half a second.

**Cap the crowd at exactly the number you can render.** Crew caps at 26 because 26 is what
the rig draws, so the HUD number is never a lie and losing crew is always visible. Gate
overflow converts to gold with a "CREW FULL +240" popup, which turns the cap from a wasted
pickup into a readable reward — and into the reason to buy the crew-limit upgrade.

**A marching grid reads better than a scatter.** A phyllotaxis spiral spread the warband into
an overlapping blob at any size that fit the road. Rows of six, alternate rows offset by half
a space, captain out front and slightly larger: same footprint, legible silhouette, and you
can count them.

**Give the run-scoped resource and the persistent one different jobs.** Iron only ever fills
the in-run forge bar (about four axe tiers a run, at every ascent), gold only ever buys
permanent upgrades, runes only ever buy blessings. The forge bar is the minute-to-minute
power fantasy and the camp is the session-to-session one, and neither can substitute for the
other. Leftover iron converts to gold at the end so nothing is wasted.

## 2026-09-07 — Coreward, third pass: taking a grid out of a grid game

### Movement

**A grid you can feel is a spreadsheet you can see.** Coreward's ship hopped cell to cell on
a fixed timer, and no amount of work on the rock underneath changed how that read. Giving it
a velocity and a collision box was the single largest change to how the game feels, and it
touched one file plus a hundred lines of the frame loop.

**Put the collision in a pure module and test the failures, not the successes.** "Moves in
open space" is not worth a test. Tunnelling through a wall at speed, catching on a corner,
creeping into a block by leaning on it for four hundred frames, getting wedged in a dead
end, and thrust that differs with frame rate — those are the five things that actually go
wrong, and all five are checkable in milliseconds without a renderer.

**Substep rather than sweep.** Splitting any movement longer than a third of a cell into
pieces is a tenth of the code of a swept test and, at any speed a player will ever reach,
almost never costs more than two iterations.

**Derive the interaction from the collision, not alongside it.** Digging used to ask "is
there a block in front of me" separately from moving. Now the collision reports the cell
that stopped the ship, and that cell *is* what the drill points at. Two facts that could
disagree became one fact that cannot.

**Count what the grid was silently doing for you before you remove it.** Three things, all
found by playing rather than by reading: selling triggered on arriving in the pad's *cell*;
breaking a block scheduled a step *into* it, which is what kept continuous digging from
stuttering; and cell-snapping is what kept tunnels aligned to the world the terrain is still
built on. Each needed an explicit replacement.

### Interruption is a feature

**A commitment the player cannot back out of is a wall, not a decision.** Coreward's drill
ran a block to completion once started. Letting go now stops it and the rock keeps its
damage. The difference is between a wall you can probe and one you have to commit to
blind — and it costs one number per cell.

**Store progress as a share, never as elapsed time.** With seconds, buying a better tool
shrinks the total while the stored number stays put, so a job you had half finished silently
becomes nearly finished — backwards from what an upgrade should do. And when you write the
test, assert that the two interpretations actually *differ* in the case you picked;
otherwise the test passes under both and proves nothing.

### Light and framing

**Fog is not distance in a 2.5D game.** `FogExp2` measures distance from the camera, and a
camera twenty units back looking at a flat plane is the same distance from every object in
the scene. Turning fog up to fade the far edges of the frame instead puts an even grey wash
over the whole picture. The thing that falls off across the plane is a *point light* — in
this game, the ship's own lamp, whose decay is the actual lever.

**Make the camera's tightness the upgrade, and then make the darkness justify it.** A tight
frame on its own reads as "the camera is too close". The same frame with the ambient nearly
gone and the corners falling to black reads as "this is as far as the light reaches", which
is the same picture with the opposite meaning.

**Three stops, not two.** A vignette ramping linearly from clear to black across the whole
radius reads as a grey wash over the picture. Holding the middle mostly clear and falling
off hard in the last third reads as light running out.

### Screens

**A panel over the game is a pop-up however you style it.** Leaving half the world visible
behind a shop says "you are still out there". Hiding the game entirely, giving the screen a
window that looks out on where you actually are, and putting the exit button at the bottom
where a door would be — those three things turn a menu into a place.

**A station interior is flat panels, seams and warning tape**, which is exactly what
gradients and repeating stripes are good at. No images, no bytes.

**One scroll region per screen.** Giving an inner list its own `overflow-y` inside a flex
column quietly clips it at the fold: an entire category looked like it contained one item,
and another looked like it did not exist.

### Version numbers

**A build stamp answers "did my update land". It cannot answer "what is different".** After
a few sessions of work the second question matters more, and a commit log is the wrong shape
for it — it is written for whoever maintains the code, and there are eighty entries. A short
hand-written list of player-facing lines, newest first, one tap from the pause screen. The
rule for writing an entry: describe what the player can now do or see. If an entry cannot be
written that way, it probably did not need a version.

### Free assets: where, and when not to

The good CC0 sources for a game like this are **Kenney** (kenney.nl, ~40k assets, one
consistent style), **Quaternius**, and **Poly Pizza / Icosa** for the archived Google Poly
library (mostly CC-BY, so attribution required). Poly Haven is CC0 but photoreal, which is
the wrong register for anything stylised. Kenney's downloads go through a session redirect
rather than a stable URL, so they cannot be fetched unattended; Google Fonts can.

**The asset that was worth importing was a typeface.** Two weights of a condensed technical
face, self-hosted at 20 KB, added to the service worker's precache so an installed app never
falls back to a system font offline. It changed every screen in the game for less than a
third of the cost of the game's own code.

**The assets that were not worth importing were the 3D models**, and the reason generalises:
*import assets for things the player reads at their real size — type, UI, sound — and model
in code anything that is thirty pixels tall and judged on silhouette.* A downloaded model
arrives with its own topology, normals and sense of scale, and next to hand-tuned
flat-shaded low-poly the join shows in the first frame. It also costs a loader, an async
fetch and a precache entry to buy surface detail at a distance nothing is viewed from.

The exception inside that rule is worth naming: the **landing pad** was rebuilt by hand with
real structure, because it is the one object in the game that is stationary, close to the
camera, and looked at while nothing else is happening. That is the only place where surface
detail earns its keep — and it is a description of a situation, not of an object, so it is
the thing to look for in the next game rather than "the pad".
