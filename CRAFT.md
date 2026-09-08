# CRAFT.md

What makes a game good, learned by building them. **Organised by topic, not by date** —
find the section a lesson belongs in and put it there.

This used to be a chronological log. It grew to nine hundred lines and became unreadable at
exactly the moment it was most needed: the start of a new game. History lives in git; this
file is for what we currently believe.

**Companion files:** `PIPELINE.md` (stack, deploy, measured limits, testing mechanics),
`ASSETS.md` (what to import and when not to), `PLAYTESTS.md` (what Gideon actually said).

---

## Recording: do it when you learn it

**Write the lesson in the same commit as the change that taught it.** Not at the end of the
session, not when the game ships. Two reasons, and the second is the one that matters:

1. Sessions end unpredictably — compaction, a crash, a change of subject. A lesson not
   written down is a lesson lost.
2. **Gideon runs several games at once.** A lesson from game A is only useful to game B if
   it is on disk before game A finishes. Waiting until "the end" means the next game starts
   from stale knowledge.

The test for whether something belongs here: *would this have saved time if I had known it
at the start of today?* If yes, it goes in, even if the game is half built and the lesson
might be revised later. A revised lesson is cheap; a missing one is not.

Put it in the right file. Design and technique here. Stack and process in `PIPELINE.md`.
Asset sourcing in `ASSETS.md`. His words, dated, in `PLAYTESTS.md`.

---

## The loop

**Give the run-scoped resource and the persistent one different jobs.** In Captain Run, iron
only fills the in-run forge bar, gold only buys permanent upgrades, runes only buy blessings.
The forge bar is the minute-to-minute power fantasy and the camp is the session-to-session
one, and neither can substitute for the other. Leftover run resource converts at the end so
nothing is wasted.

**One resource is no resource.** Coreward had nine ores and five rocks that all converted to
the same number, so *where* you dug never mattered — only how long. That is a difficulty
slider wearing a resource system's clothes. Three distinct resources is about the ceiling for
comprehension and the floor for a real decision.

**A secondary objective has to be a thing you keep.** Money is a rung: every amount you earn
makes the last amount irrelevant, so "what have I got" is always a number that will look
small next week. A collection is the opposite. Coreward's relics — one per planet, buried,
granting a permanent perk — are the first reward in that game whose value does not decay.

**Make the best reward missable.** A relic is lost forever if you break the planet's core
with it still in the ground. That single property is what makes it worth *looking* for
rather than something you will pick up eventually.

**Discovery moments stop routine work going stale.** A rare surprise during the grind — a
cache, a gadget, a bonus — is what a resource loop is missing when every unit is worth a
predictable number. Rare enough that you cannot plan around it, or it becomes a resource.

**Aim a surprise at the current bottleneck.** Once a gate exists, the most valuable thing a
cache can hand you is the two units you are short, not any amount of money. Money is what the
loop already pays constantly.

---

## Progression

**Gate an upgrade behind a place, not a price.** The strongest version is when the thing that
counters a threat requires surviving the threat first. Coreward's Cooling Rig costs emerald,
which starts eight metres *inside* the heat zone, so you make a heat run without protection in
order to buy protection. That is the "hit a wall, upgrade, get past it" spine that
Motherload-likes live on, and no amount of money substitutes for it.

**Depth is a currency that cannot be farmed.** Locking shop stock behind "deepest ever
reached" is the cheapest structural progression available, and it should be *shown*, not
hidden: a row that says "Sealed until 90 m" is a reason to go deeper. A hidden row is nothing
at all.

**Two gates on one thing means one of them is decoration.** Coreward's laser was gated at 90 m
of depth *and* by a material available from 22 m. A test now asserts every gated upgrade's
material lives within 30 m of its unlock depth, and it caught this before a human did.

**A weight limit is what turns "which is worth more" into a decision.** A material gate only
creates a choice because cargo is capped by kilos: six of the thing you need is most of a
starting hold, and every kilo of it is one not spent on something worth more per kilo. Without
the cap it is a shopping list.

**Consumables and permanent upgrades must sit on different axes.** An upgrade raises the
ceiling on every future run; a consumable buys one more minute on *this* one. Keep stack
limits small, price the consumable that answers an uncapped threat above the first level of
the upgrade that answers it, and make a full kit cost more than several rungs of the ladder.
Otherwise stocking up quietly replaces deciding.

**Two upside gates beat a good gate and a bad gate.** "+6" against "×2" has no correct
answer — it depends on how many crew you have right now, which differs every run — so the
player is genuinely choosing. Good-versus-bad is a reflex test. Keep a minority of punishing
gates for tension, and never let one take the player below the ability to continue.

**Cap a visible resource at exactly the number you can render.** Captain Run caps crew at 26
because 26 is what the rig draws, so the HUD number is never a lie and losing crew is always
visible. Overflow converts to currency with a "CREW FULL +240" popup, which turns a wasted
pickup into a readable reward — and into the reason to buy the cap upgrade.

---

## Tension

**Attrition gives you one question; a rhythm gives you a bet.** A slow drain charges for time
and the answer is always "leave a bit sooner". A recurring, announced event makes the decision
live: Coreward's tremors collapse part of your tunnel every ~27 seconds past 85 m, so depth
becomes a commitment rather than a number.

**Never let a hazard take the run.** A tremor may cost time, fuel and patience. After choosing
which cells to collapse, the code re-runs the pathfinder; if the ship can no longer reach the
surface, the whole collapse is reverted and the tremor is spent as noise. Bound the worst case
explicitly and test the bound, or the mechanic is a coin flip on whether the player quits.

**Announce a zone before charging for it.** The world tint should ramp *before* the damage
starts. A warning that arrives with the punishment is not a warning.

**A threshold the player cannot see is not a mechanic.** Coreward's rock band changed at 60 m
while heat started at 70, so the only marker of the boundary was a number that never appeared
on screen. Four things now land on the same metre: the rock changes, the sky warms, the hull
starts draining, the vignette builds. One is missable; four is not.

**Couple numbers that must agree with a test.** The rock boundary and the heat threshold were
aligned once and drifted apart silently. Any pair of constants that has to match for the game
to explain itself should be tied together by an assertion, not by a comment.

**Where a fight resolves matters more than how long it takes.** Captain Run's enemies died at
maximum range, so combat was a number changing at the horizon. Giving them a charge speed that
closes the gap in about a second means they die in frame, in a spray of loot. Same damage,
same difficulty, completely different game.

**Interruption is a feature.** A commitment the player cannot back out of is a wall, not a
decision. Coreward's drill ran a block to completion once started; letting go now stops it and
the rock keeps its damage. The difference is between a wall you can probe and one you must
commit to blind, and it costs one number per cell.

---

## Legibility

**Silhouette carries more than colour.** This has now been wrong in four different ways: a
green gas pocket that looked like an emerald, a pink cache next to purple crystals,
rectangular background slabs that read as UI panels, and a repainted drill nobody could see.
Change the *form* — a lit body instead of lit crystals, parallel machined faces instead of
points, a jittered hexagon instead of a plane.

**A hazard must not resemble a reward.** Hue alone is not enough separation, especially at
phone size and especially for anything a colour-blind player might meet.

**The most valuable thing on screen must be the brightest thing on screen.** A first pass made
Coreward's hazard glow harder than the payout, which points the eye at the thing you must not
touch. The hazard only has to be unmistakable; the reward has to be magnetic.

**When a change must be noticed from memory rather than by comparison, change the amount, not
the shade.** Two pale colours are distinguishable side by side and forgettable alone. Three
times the sparks, twice as fast, is legible alone.

**An upgrade you cannot see is one the player buys on trust.** Coreward's Scanner only changed
a light radius; the camera framed a fixed number of rows, so the whole screen was always inside
the lit circle. Giving it the *framing* — and then a headlight cone whose length tracks it, and
then a relic-finder whose range is that radius — turned the most invisible purchase on the
shelf into three reasons to buy one thing. **Three reasons to buy one upgrade beats three
upgrades with one reason each.**

**Give each pressure its own channel.** One red vignette driven by `max(hull, heat)` was fine
while heat was the only thing that emptied the hull. The moment a second source existed, the
screen was saying "heat" for something that was not heat.

**A number beats a bar when the player needs to understand causation.** Putting `HULL −3.4/s`
on the hull bar while heat drains it was the single most effective part of that fix. A coolant
flush takes it to `−0.7/s` in front of you, which is the clearest possible statement of what a
purchase bought.

**Put the gauge on the thing it is eating, and do not let it cover that thing.** The heat gauge
lives inside the hull bar. At full height it hid the hull level entirely — the gauge was
obscuring what it explains. Seven pixels of nineteen, along the bottom.

**Draw the player's own goal into the world.** A faint line across the rock at your previous
deepest reach is a target *you* set, as opposed to the core, which the game set. Freeze it at
the record you had when the run started — a line that retreats ahead of you is not a line you
can cross — and fade it once passed, or a moment becomes scenery.

**Put a modifier where the thing is already named.** A planet trait rides on the name chip in
the HUD, because that is the only always-visible place the planet is named. A modifier you must
open a menu to remember is one you play without.

**A marching grid reads better than a scatter.** A phyllotaxis spiral spread Captain Run's
warband into an overlapping blob. Rows of six, alternate rows offset by half a space, leader
out front and slightly larger: same footprint, legible silhouette, and you can count them.

---

## Feel

**Hit-stop is the highest value per line of code in the whole toolbox.** Freezing the
simulation for 35–80 ms on an impact makes the same animation feel like a different game.
Scale the freeze to how significant the event is.

**Layer three feedback channels on every action:** visual, audio, and camera. A block breaking
should spray particles, make a sound and shake the frame. Any one alone reads as cheap.

**A grid you can feel is a spreadsheet you can see.** Coreward's ship hopped cell to cell on a
fixed timer, and no amount of work on the rock underneath changed how that read. Giving it a
velocity and a collision box was the single largest change to how that game feels.

**Count what the grid was silently doing before you remove it.** Three things, all found by
playing rather than reading: selling triggered on arriving in a *cell*; breaking a block
scheduled a step *into* it, which is what kept continuous digging from stuttering; and
cell-snapping kept tunnels aligned to the world the terrain is still built on. Each needed an
explicit replacement.

**Derive the interaction from the collision, not alongside it.** Digging used to ask "is there
a block in front of me" separately from moving. Now the collision reports the cell that stopped
the ship, and that cell *is* what the drill points at. Two facts that could disagree became one
fact that cannot.

**That only works if the ship can be in exactly one cell - which off a grid it cannot.** The
above shipped and was still wrong, because a ship of radius 0.34 sitting at 5.40 touches rows 5
and 6 at once. The collision reported one; everything reconstructed from `Math.round()` reported
the other. Both symptoms were named by the player in one sentence. The drill refusing to bite
("not mining"): the stop test rebuilt the direction each frame, got a diagonal, and cancelled the
cut on the frame after starting it - forever, because the collision kept re-reporting the same
wall. And the ship snagging on the wall of the shaft it had just dug, which is a hard deadlock
where it can neither move nor drill, reachable by ordinary play.

**Fly along the grid, not on it and not off it.** Travel freely on the axis being pushed; be
drawn continuously onto the centre line of the other. Momentum, acceleration and the coast are
untouched - assert that with a test - and the wobble across the lane, which was doing nothing for
feel, was the entire source of the ambiguity. This is what "on a grid but not stuck on one"
actually means, and it is how every grid game that feels good has always worked.

**Apply a correction as a velocity, not as a position.** The lane pull goes through the same
collision as everything else, so it can never seat the ship inside rock: a blocked lane ejects it
into the free one. A position write would have needed its own safety check, which is a second
fact free to disagree with the first.

**Store the fact; never re-derive it.** The dig's stop test now compares against the direction the
cut *started* in, stored on the dig. Reconstructing it from position every frame was the bug.
Anything reconstructed from a rounded continuous value is a fact you have chosen to let drift.

**Store progress as a share, never as elapsed time.** With seconds, buying a better tool shrinks
the total while the stored number stays put, so a job you had half finished silently becomes
nearly finished — backwards from what an upgrade should do. When you write the test, assert that
the two interpretations actually *differ* in the case you picked; otherwise it passes under both
and proves nothing.

**`min(1, dt * rate)` is not frame-rate independent, and almost every game uses it anyway.** The
correct form is `1 - exp(-rate * dt)`. Two 8 ms steps then land exactly where one 16 ms step
lands.

**Convert tuned constants rather than re-deriving them.** Fixing that lerp could have changed how
the camera feels, which is the one thing a desktop cannot verify. Instead every rate goes through
a helper returning the exponential rate that covers the same fraction in one 60 fps frame, and
the golden baseline records those fractions — so the file itself proves the feel did not move.

**Exponential everywhere it matters, and keep the coast short.** Anything that reads as momentum
also reads as the controls being late, on a game played with a thumb. Coreward reaches top speed
in about a fifth of a second and coasts about three quarters of a cell. There is a test on the
coast distance, because that single number is most of what "free to fly" feels like.

**Spline flight beats stepping between waypoints.** Moving along a Catmull-Rom curve with ease-in
and ease-out, with the heading following the velocity, is what makes movement read as piloted.
High speed alone reads as fast-forward.

---

## Graphics that carry on a phone

**Instancing is the whole game.** Coreward went from 207 draw calls to 35 by instancing terrain.
Captain Run draws 26 vikings, 18 draugr, a boss, 420 loot chunks and all scenery in 42–55 calls.
See `PIPELINE.md` for the measured budgets.

**Instance the body parts, not the character.** One `InstancedMesh` per part — leg, torso, arm,
head, helmet, weapon, shadow — with matrices recomputed each frame from a procedural animation
cycle. Crowd size then stops being a performance question at all, and a boss is the same rig at
3.3× with a different colour: a whole boss for zero extra draw calls.

**`setColorAt` is what makes one layer look like many objects.** Per-instance colour over a white
base material gives every unit its own cloak and shield, and drives a weapon's colour straight
from its tier — all from a single mesh.

**Per-instance data can never fade across a boundary.** Learned twice on Coreward: seams between
cells, then glow that stopped dead at a cell edge. If an effect has to be continuous across the
world, it belongs in a shader keyed on world position, not in instance data.

**Two rotations on one object compose in an order, and the default is rarely the one you
want.** Coreward's ship carried its facing on `rotation.z` and its bank on `rotation.y`. Under
three.js's default `XYZ` the facing composes first and the bank then turns the already-turned
ship about the **world** vertical - a roll about the drill when pointing down, which is right,
and a swing of the nose toward the camera when pointing sideways, which reads as the ship
flipping out of the screen plane. `rotation.order = 'ZYX'` composes the other way, so the bank
applies in the ship's own frame and the facing turns the result: a roll in every facing. One
line, and it is worth checking the moment a second rotation is added to anything.

**A bank must read off the lateral axis in the object's own frame.** The same bug had a second
half: it was driven by `vx` regardless of which way the ship pointed, so flying left or right
banked the ship for going *fast* rather than for going sideways. Whichever axis the object is
not pointing along is the one that means "drifting".

**Fake bloom with additive sprite halos.** Post-processing bloom costs fill rate, a library, and a
pass. Additive quads with a soft texture cost one draw call, and if the camera never rotates a
quad in the XY plane always faces it — no billboarding needed.

**Cel shading is a three-line texture, and ambient light is what kills it.** A `DataTexture` of
four grey steps as `MeshToonMaterial.gradientMap`, with `NearestFilter` on *both* `minFilter` and
`magFilter` or the bands smooth back into Lambert. Then turn the ambient down — it is the one
light that reaches every surface equally, which is precisely the distinction banding exists to
make.

**An inverted-hull outline must be sized from the geometry, not scaled by a factor.** Multiplying
every instance by 1.08 gives a 0.036-unit edge on a large object and 0.003 on a small one, both
sub-pixel. Treat the parameter as a world-unit thickness, read the geometry's bounding box, and
derive a per-axis scale of `1 + 2*t/size`. Prefer a scaled hull to a normal-pushed one when the
geometry is boxes: hard per-face normals split at the corners and the outline develops gaps.

**Fog is not distance in a 2.5D game.** `FogExp2` measures distance from the *camera*, and a
camera twenty units back looking at a flat plane is equidistant from everything in it. Turning fog
up to fade the far edges instead puts an even grey wash over the whole picture. The thing that
falls off across the plane is a **point light**.

**Make the framing an upgrade, then make the darkness justify it.** A tight frame alone reads as
"the camera is too close". The same frame with ambient nearly gone and the corners falling to
black reads as "this is as far as the light reaches" — the same picture, opposite meaning.

**Three stops in a vignette, not two.** A linear ramp from clear to black across the whole radius
reads as a grey wash. Holding the middle mostly clear and falling off hard in the last third reads
as light running out.

**A normal map is how a photographed texture gets into a stylised game.** It carries no colour,
so the hand-tuned palette survives intact and every surface gains relief. Take the normal map out
of a CC0 PBR set and leave the colour map behind - that half is style-neutral, and the other half
is the join that shows in the first frame. Coreward's flat-shaded facets went from folded paper
to rock for 46 KB.

**Sample it on world position, for the same reason as the displacement below.** Mapped to each
cube's own UVs the detail restarts at every cell and the wall reads as a stack of identical
boxes. In three.js `vNormalMapUv` is an ordinary varying, so overwriting it with world XY in the
vertex shader is the entire change and everything downstream is stock.

**Expect to need a far higher `normalScale` than usual over flat shading, and measure it rather
than reasoning about it.** At 0.45 Coreward's was invisible; at 3.0 it read clearly with the
facets completely intact. Spreading one tile over several cells is what does it - only the
texture's low-frequency component survives, so the value that looks "wrong" is the correct one.
Check it lit by a moving lamp, not on a static screenshot of a flat-lit surface: the whole effect
is in how light rakes across it.

**Displacement keyed on world position is what makes stacked boxes read as rock.** Per-cell
displacement makes neighbours disagree at the seam. `flatShading` then derives normals from the
displaced surface for free.

**When something new renders as nothing, check what is already in that slice of z before you touch
its colour.** Two parallax layers were invisible even in pure red, because an opaque backdrop
plane sat in front of them.

**Gradient skies for free.** Render with `alpha: true` and no scene background, then put a CSS
gradient behind the canvas.

**A panel over the game is a pop-up however you style it.** Leaving half the world visible behind
a shop says "you are still out there". Hide the game entirely, give the screen a window that looks
out on where the player actually is, and put the exit at the bottom where a door would be.

**One scroll region per screen.** Giving an inner list its own `overflow-y` inside a flex column
quietly clips it at the fold — an entire category looked like it held one item, and another looked
like it did not exist.

---

## Audio design

The technical side is in `ASSETS.md`. The design side:

**Generative beats a loop.** A chord bed of detuned oscillators through a lowpass, a written theme
rather than random notes, and a delay for space. Randomness cannot substitute for melody: without
repetition there is no phrase for the ear to hold, so isolated notes register as UI noise. A fast
attack on a high sine is literally the shape of a notification sound.

**Randomise pitch and filter cutoff on repeated sounds**, or an identical sound fired twice a
second becomes a machine.

**A texture reads as ambience; only a rhythm reads as movement.** Coreward's unstable-band layer
is scheduled thuds off the downbeat — on the beat they would read as part of the score rather than
as something else in the room.

**Sound is one of the three feedback channels.** An action with no sound reads as not having
happened, however good the particles are.

---

## Testing design, not just code

**Test intent, not only values.** A snapshot of the tuning constants fixes the numbers but says
nothing about what they are *for*. Assertions like "a hazard breaks faster than the rock around
it", "a deeper ore is rarer than the one above it", "the counter to a threat costs a material from
inside that threat" have each caught a real design mistake before a human saw it.

**When a mechanic is a clock, extract the clock.** A pure reducer taking a clock and a delta and
returning the next clock is checkable in milliseconds; the alternative is sitting in the game for
thirty-four seconds with a renderer attached. Doing this immediately found a real bug — a long
frame armed a warning and fired on the same tick, then armed it again.

**Every fixture agreeing on a convenient value is how a whole suite misses a bug.** 124 golden
tests and 17 smoke tests ran through Coreward's flight for a session without touching a deadlock
that ordinary play hits, because every one of them seeded the ship exactly on a cell centre and
the bug only exists off one. The suite was not weak; it was *uniform*. When a value became
continuous, no fixture noticed, because a fixture is written by someone who already knows the
happy case. Ask what value every test happens to share, and write one that does not - and say in
the test why the awkward number is awkward, or the next person tidies it back to the round one
and silently retires the test.

**Put collision in a pure module and test the failures, not the successes.** "Moves in open space"
is not worth a test. Tunnelling at speed, catching on a corner, creeping into a block by leaning
on it, wedging in a dead end, and frame-rate dependence are the five things that actually go
wrong.

**Snapshot the pure functions before refactoring, then make the snapshots fail.** A golden test
you have never seen fail is a test you do not know works.

**Split assertions into contract and canary on order-dependent algorithms.** The contract is "this
route is valid and shortest"; the canary is "this exact tie-break path". The canary can be
re-recorded alone without weakening the contract.

**Freeze the world before you add to it, and test the property rather than the snapshot.**
Coreward keeps a frozen pre-feature grid with its own id legend, and asserts the only legal
difference: a cell either kept its id, or one of the new things overwrote it. A plain golden
snapshot would have accepted a total reshuffle as "intentional, re-record".

**Categorise the kinds of legal change in a world-diff test.** A single percentage ceiling broke
when one feature converted a third of all rock, because it counted a rare overwrite and a
wholesale category conversion as the same claim. **A test whose failure message blames the wrong
subsystem is worse than one that does not fire.**

**A new world feature must roll on its own seed offset.** If it consumes the roll the ore stream
uses, every value at every depth shifts, and the diff is three lines.

**Test the random source itself, not only what it produces.** Captain Run's seeded `hash` used
signed right shifts, so `h ^ (h >> 16)` always cleared the top bit and it could never return above
0.5 — measured maximum 0.499999 over 800,000 samples. Every spawn decision in the game went
through it. Nothing errored. Three mechanics that were written, tuned and shipped had never once
run: brutes needed `> 0.72`, punishing gates `> 0.68`, and the good gate swapping sides `> 0.5`.
Everything placed with `(hash() - 0.5) * width` came out negative every time, pinning enemies and
pickups to one half of the road. **A mechanic whose condition can never be true fails as absence
— no error, nothing missing on screen, the game simply plays differently than it reads — which is
the one failure mode playtesting cannot see.** Assert the range, assert the distribution, and add
an end-to-end test that each mechanic *occurs in an actual run*. Both are three lines.

Two follow-ons worth having in advance. **A 32-bit multiply needs `Math.imul`**: `x * 374761393`
is ~2^62, past what a double holds exactly, so the low bits a later xor-shift mixes down are
rounded away before use. And **balance tuned against a broken random source is tuned against a
different game** — fixing the hash made Captain Run's first ascent unwinnable, and the two design
bugs that surfaced underneath had been hidden by it for the whole life of the game.

**Kill rate, not damage, is what a crowd runs out of.** One volley on one target is a hard cap on
kills per second no matter how much damage each shot carries, and the overkill is invisible waste.
Captain Run capped at 2.4 kills a second against spawns of up to five at once; fanning the same
total damage across the nearest few cost nothing and multiplied the ceiling by five. Any time a
"not enough damage" symptom survives a damage increase, check whether the real constraint is
throughput.

**Whatever the game tells the player to fight, the auto-attack must target.** Nearest-first looks
obviously right and put every axe into trash while the boss the horn had just announced sat at
full health, slamming on its own clock. Worse, it was self-reinforcing: damage scaled with warband
size, so each hit cut the damage that would end the fight.

**What you own and what you have done are different lists.** Coreward's relic check asked "do I
already own this perk" — which answers yes for every planet past the eighth, where the perks
repeat, so relics silently stopped existing. Any time a reward repeats, the "already collected"
test must key on the *event*.

---

## Traps that have cost time more than once

**The reset → push → flush pattern will eventually be missing its flush, and it fails completely
silently.** Captain Run's enemy layers were never flushed, so `count` stayed 0 and every enemy was
invisible while still charging, still costing crew, still being killed. It read as a balance
problem and got a whole tuning pass. **If a render path has a count, assert that count against the
model.** A subsystem that renders nothing and a subsystem that does not exist look identical from
outside.

**Use `requestAnimationFrame` to draw, never to undo.** Anything that reverses itself on the next
frame sticks forever if the tab is hidden at that moment. An impact flash cleared from a rAF
callback stayed at 0.75 opacity over the whole UI — a "the CSS is wrong" symptom with a scheduling
cause. `setTimeout(..., 20)` instead.

**Ship a headless tick seam.** Split the loop into `frame(now)`, which computes dt and calls rAF,
and `tick(dt)`, which does everything else — then expose `tick` behind a `?debug` query param. A
whole run compresses into `advance(56)` plus a screenshot, deterministically and faster than real
time. It costs one `if`, and every balance number in Captain Run was set that way.

**`localStorage.clear()` plus a reload does not clear anything** if the game saves on
`visibilitychange` — the outgoing page writes it straight back. Freeze `Storage.prototype.setItem`
first. Three sessions, three times.

**Round before clamping.** A perk turned a cut into `0.5 - 8*0.05`, which is
`0.09999999999999998`, and the golden baseline recorded a rate of 9.999999999999998%. True,
useless, and exactly the kind of diff that trains you to re-record without reading — the one habit
golden baselines cannot survive.

**Check that every content band is actually reachable**, in both directions. The hardest rock once
started deeper than the first planet's core, so it could never be seen on the planet everyone
starts on. Later, the ore ladder stopped a hundred metres above the deepest reachable ground — the
same lesson inside out.

---

## Working with Gideon

**He names the symptom accurately and often names the fix too.** Every observation across three
sessions turned out to identify a structural problem rather than a matter of degree. "The light
upgrade doesn't seem beneficial, I can see all the blocks on screen" was a correct diagnosis of a
design fault no amount of tuning the light radius could have fixed — and his proposed fix, zooming
with the upgrade, was the right shape.

**Believe the symptom, then go and find the cause yourself.** He is reliably right that something
is wrong and not always right about why. Take the report seriously; do the diagnosis.

**He plays the opening.** Across two overhauls his notes were about the first sixty metres, and he
had not reached the deep content added the session before. Weight effort accordingly: the shallow
part of a game is the part that gets played.

**Complaints are the most valuable entries in `PLAYTESTS.md`.** Record them in his words, dated.
The phrasing is the useful part.

**"It looks good, no issues" is not evidence the feel is intact** — only that nothing obvious
broke. If a change touched the frame loop or the audio graph, ask about the specific thing:
whether a valuable strike still lands heavy, whether the flight still reads as flying.

**Ship, then check.** Push to `main`, say it is pushed, and let him test on the phone. Do not gate
on a preview or poll the live site.
