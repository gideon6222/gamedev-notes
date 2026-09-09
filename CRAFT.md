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

**If the thing you are destroying can be walked past, destruction is optional and the game
has no stakes.** Wrecking Crew spent two builds as a runner with a wrecking ball, and no
amount of tuning made the buildings matter, because the genre answers the question before
the design gets to: in a runner you pass things, passing is free, and hitting them is a
bonus. Gideon's word for the result was that there was "no risk or reward yet", which was
exactly right and was not a balance problem.

**Destruction becomes a game the moment it is the only way forward, or the only thing being
scored.** The fix was to stop moving: one condemned building per level, a fixed number of
swings, and a way to fail that is not "you did not do enough" but "you did it in the wrong
order". Ask of any resource-gathering or destruction loop: *what happens if the player
ignores this entirely?* If the answer is "they score less", it is a difficulty slider. If
the answer is "they cannot continue" or "they lose what they came for", it is a mechanic.

**A budget is the cheapest risk there is, and it must be derived from the content rather than
set as a rate.** Wrecking Crew gives exactly enough swings to break every column plus four.
A flat three-per-bay drifted out of step the moment columns started varying in strength:
five bays of four hit points got 17 swings for a job needing 20, so the last levels were
arithmetically unwinnable however well they were played, and nothing said so. **Any budget
expressed as a rate over content will eventually disagree with the content.** Compute it
from the thing it is a budget for, and assert it is sufficient at every level.

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

**A station the player can pass through and get nothing from teaches them to stop reading the
signs.** Candle Gift's level-1 press stamped PLAIN onto plain candles and announced "ALREADY
PLAIN" - a gantry, a sign and a machine that was a dead beat until an upgrade several levels
later. Floor every station at its first *real* effect and let upgrades climb from there. The
same applies to any shop row, pickup or event whose lowest tier is a no-op.

**Two upside gates beat a good gate and a bad gate.** "+6" against "×2" has no correct
answer — it depends on how many crew you have right now, which differs every run — so the
player is genuinely choosing. Good-versus-bad is a reflex test. Keep a minority of punishing
gates for tension, and never let one take the player below the ability to continue.

**Make a quality bonus a multiplier on quantity, not an amount added to it.** Wick pays for
bulk wax and for craftsmanship - colours carried, and whether they contrast. As a flat bonus,
craftsmanship was decisive on a small candle and a rounding error on a big one, so one of the
two things the player was doing was always the wrong thing to think about. As a multiplier,
doubling the wax always doubles the money and a well-made candle is always worth about twice a
plain one. Both axes stay alive at every scale.

**Keep the price spread on a "premium" resource narrow, or the choice collapses.** Wick's waxes
started at up to 2.9x tallow, and the expensive-looking mistake genuinely scored highest:
material value swamped every design bonus and the dip arch became "take the bigger number".
Under 2x, the cheap contrasting wax and the pricey matching one are a real decision. **Any time
a system is meant to compete with raw quantity, check it actually beats raw quantity** - with a
test, at equal quantity.

**A progress gauge needs headroom past its top rating, or it stops measuring at the moment it
matters.** Candle Gift's end-of-run gauge was scaled to 1.35x the par value while three stars is
awarded at 1.15x - so every three-star run pegged the bar, and a merely good result and a great
one were the same picture. The gauge exists to distinguish exactly those two. Scale full-height
to roughly 1.5-2x the top threshold and let the best plausible run sit around two thirds.

**Cap a visible resource at exactly the number you can render.** Captain Run caps crew at 26
because 26 is what the rig draws, so the HUD number is never a lie and losing crew is always
visible. Overflow converts to currency with a "CREW FULL +240" popup, which turns a wasted
pickup into a readable reward — and into the reason to buy the cap upgrade.

---

## Tension

**A moving obstacle needs a provably reachable gap, computed rather than eyeballed.** Candle
Gift's sweeper is a bar that slides across the lane, and it shipped at its drawn half-width plus
the standard collision tolerance, swinging most of the steerable band: at every point in its
swing it covered 61% of the lane, so the scripted good player lost half its slab to it every
time. A static obstacle you can see is a decision; a moving one with no gap is a tax the player
cannot tell apart from bad luck. **Write down the worst-case clearance - swing amplitude plus
half-width plus tolerance against the steerable width - before tuning the frequency.**

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

**The best trap interaction is one hazard becoming the answer to another.** In Wick, water
snuffs your wick and heat lamps melt your wax - and heat is what relights you. The thing you
spend the whole run steering around is the thing you need the instant water takes your flame,
and you pay for it in melted wax while you stand in it. Two hazards already in the game, one
line of code, and the player discovers a rule rather than being told one. Look for this pair
before adding a third hazard.

**Make the thing you are protecting trail behind you, not cluster around you.** A crowd that
follows the player exactly is all upside: obstacles only ever meet the front of it, so more
units is strictly better and the size of the crowd is a number rather than a decision. Candle
Gift's tray records where the leader has been and puts each row a fixed distance back *along
that path*, so the back is still going where the front went a second ago. Swerve late and you
clear the obstacle yourself and drag half your tray through it - which means growing the tray
costs agility, and the player has to start steering well before an obstacle is in reach.
Obstacles must then test **every** unit, not the leader, or none of it is real.

**Put the resource ON THE GROUND and let the formation decide who touches it.** Candle Gift's
first build made every station a gate across the track that treated the whole tray at once,
and it measured as *identical* per-candle value across four scripted play styles - never
touching the screen scored the same quality as playing perfectly. The reference is a pool the
tray drives *through*: which candles get dipped depends on where each one was as the line
snaked over it, so sweeping left and right through a pair of pools gets some candles into each.
That one change turned every station from a thing that happens to you into a decision, and
weaving measured 2.6x per candle over driving straight.

The general rule: **if a system applies itself to everything you own, it is not a mechanic.**
Give the reward an extent in space, give the player a formation with lag, and the geometry
does the design for you.

**Per-unit state is what makes a formation worth looking at.** Once each candle carried its own
recipe, a tray that wove came out visibly striped in different colours and one that held a line
did not - the skill is legible on screen without a single number. Shared state across a group
is cheaper and always looks like one object.

**Interruption is a feature.** A commitment the player cannot back out of is a wall, not a
decision. Coreward's drill ran a block to completion once started; letting go now stops it and
the rock keeps its damage. The difference is between a wall you can probe and one you must
commit to blind, and it costs one number per cell.

**A condition with no middle setting is not a mechanic, whichever way it lands.** Wrecking
Crew's ball rises as it swings out, so the obvious rule was that it can only damage a
building it is not sailing over - a big swing takes the tops off towers, a gentle one is
needed to finish a stump. It sounded like the best idea in the design and it has exactly two
behaviours. With buildings two floors and up it never fired once: a hidden condition that is
always true, which is strictly worse than no condition, because it costs code and comprehension
and buys nothing. With one-floor shopfronts in the mix it fired on nearly all of them, and the
whole of the first street - the part that actually gets played - became immune to the only tool
in the game. Measured: the aiming bot felled two floors in thirty seconds.

The test for this before building it: **name the setting where the condition fires about half
the time.** If the answer needs the rest of the game to be tuned around it, it is a wall
wearing a decision's clothes. The choice it was meant to create was real and worth having -
how hard to swing, not just when - but it has to be a cost rather than a gate, and it has to
be on the HUD.

**A dominant strategy with no cost attached is not a mechanic, however good it feels.**
Wrecking Crew's ball reaches further the faster it is swinging, and nothing anywhere charges
for swinging flat out - so maximum swing is never wrong, and a bot that ignores the street
entirely and waves the crane on the ball's own period scores level with one that reads the
street and picks targets. The tell is not that the game is easy; it is that two completely
different intentions produce the same number.

**Check for it by asking what a wild version of the input costs**, and if the honest answer
is "nothing", the mechanic is a rhythm rather than a decision. The fixes are all forms of
making the sweep selective: targets worth different amounts, a cost per swing, a cap on
contacts, or a reward that scales with how square the hit was. Density is NOT one of them -
thinning the content made the aiming bot *worse*, because it started committing to things
that were not there yet, and the waving bot's advantage grew.

**Do not paper over one of these with a test that enshrines it.** Assert the thing that IS
true and valuable, write the problem down where the next session will read it, and leave the
assertion for when the fix lands.

**Solving a constraint by moving a thing and not touching its velocity injects energy;
solving it by overwriting the velocity destroys momentum. Neither is the answer.** Wrecking
Crew's chain went through both. The first version projected the ball back onto the circle and
left its velocity alone - which adds energy on every taut frame and compounds, measured at
216 m/s on a machine that cannot exceed 9.5. The obvious fix, deriving the velocity from how
far the ball actually moved, is stable and *kills the swing*: a taut chain clamps the ball to
a circle, so its per-frame displacement is small, so the derived velocity is small. The player's
words for those two faults sitting on top of each other were **"it flies out too much but also
feels like it doesn't have enough momentum"**.

The correct constraint **zeroes the RADIAL component of the ball's velocity relative to the
anchor, and leaves the tangential component completely alone.** Tangential is the momentum, so
it carries. Radial is the stretch, so it cannot. It cannot inject energy either, because it
only ever removes a component - which is what makes it stable without needing the displacement
trick at all.

**A restoring force has to be proportional to the displacement, or the thing has no period.**
The same chain pulled toward its anchor with a constant magnitude, which does not care how far
out the weight is - so once it was out, it stayed out. `g * offset / length` is one line, and
a period is what makes a swing read as a swing rather than as a weight being dragged on a
string.

**Every improvement to how hard a hit lands is a change to how long a level takes.** Fixing
the chain roughly doubled the damage a pass delivers, and a room that had been a minute's work
went down in eight seconds. The two numbers are one decision and have to be re-balanced
together, or the level loses its middle.

**The best version of a greed mechanic is one where greed genuinely pays, right up until it
does not.** Wrecking Crew's collapse used to be measured by "does leaving earn more than
staying" - and once the driving was fixed, it stopped being true: the policy that ignores the
collapse puts twice the columns down and banks more rubble before the ceiling lands on it.
That is not a broken mechanic, it is the correct one, and the assertion was what needed
changing. **The claim is not "the safe option scores higher". It is "the reckless option
never actually works."** If a player who ignores the threat can still finish, the threat is
scenery; if the safe option simply scores more, there was never a decision.

---

## Legibility

**A sphere reads as a bubble at any size.** It is the one shape with no orientation and no facets,
so it cannot look machined however it is shaded. Coreward's cockpit was a sphere and it was most
of what made the whole ship read as a toy; a four-segment wedge with a ridge and two angled panes
fixed it in one line. The same logic runs through a model: prisms with hard corners catch a light
on one face and not the next, cylinders do not.

**Silhouette carries more than colour.** This has now been wrong in four different ways: a
green gas pocket that looked like an emerald, a pink cache next to purple crystals,
rectangular background slabs that read as UI panels, and a repainted drill nobody could see.
Change the *form* — a lit body instead of lit crystals, parallel machined faces instead of
points, a jittered hexagon instead of a plane.

**A hazard must not resemble a reward.** Hue alone is not enough separation, especially at
phone size and especially for anything a colour-blind player might meet.

**If code has to judge whether two colours "look different", it must weigh lightness, not only
hue.** Wick scores adjacent wax layers as contrasting; the first version compared hue distance
alone, and cream tallow against crimson - obviously two colours, one of them nearly white -
came out as no contrast at all, because they sit 0.13 apart on the wheel. Either axis over a
threshold is enough. The pleasant side effect is that a pale wax becomes genuinely useful as a
*separator* between two saturated ones, which is how a real layered candle is banded. A unit
test caught this before any of it was drawn.

**Separate the play space from the background by lightness, not by hue.** A themed level in
Candle Gift shipped as a pink runway under a pink sky - different hues, similar lightness -
and the track dissolved into the backdrop at about twenty units, which is exactly the
distance the player steers by. There is now a unit test asserting a minimum lightness gap
between every road and every sky it floats in, because "it looked fine in the editor" is a
description of a close-up.

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

**Derive the silhouette from the state, never store it alongside.** Wick's candle is a list of
wax layers; its radius, height, lean and appraised value are all *functions* of that list, so
the thing on screen cannot drift from the thing being scored. In any game whose premise is
"protect the thing you can see", a score that disagrees with the picture is the one bug the
player will never forgive - and the only way to make it impossible is to have one source.

**Let damage reveal history.** Shaving Wick's outer ring exposes the colour underneath, so a
hit is informative rather than only costly: you can read what you dipped in, and in what
order, off your own body. Any stacked or layered resource can do this, and it converts damage
feedback from a number into a picture.

**When the accurate model and the readable model disagree, build the readable one.** Dipping a
candle in wax makes concentric shells - and rendered that way the outermost shell hides every
shell inside it, so five dips came out as a plain cream cylinder with a two-millimetre rim of
colour at the base. Horizontal bands stacked up the candle are physically wrong and instantly
legible: every dip visible at once, newest on top, and the HUD chips can be drawn in the same
order so the two never need reconciling. Ask what the mechanic needs to *look* like before
asking what it is.

**A formation is only readable if it is more than one unit wide.** The same tray in single
file showed the player one candle's worth of colour, because every candle hid behind the one
in front. Three abreast costs nothing, still trails identically - it is the *row* that
follows the path - and suddenly all the work the player did is on screen.

**Horizontal detail needs a low camera; vertical detail needs a high one.** Bands running
around a candle are only legible from the side, and the first pass looked down the runway
from above, saw the tops, and rendered a three-colour tray as one colour. The camera angle is
part of the art, not a framing preference.

**A marching grid reads better than a scatter.** A phyllotaxis spiral spread Captain Run's
warband into an overlapping blob. Rows of six, alternate rows offset by half a space, leader
out front and slightly larger: same footprint, legible silhouette, and you can count them.

**A control the player cannot see themselves using is a control they cannot learn.** Wrecking
Crew's first build drove the ball from the rig's lateral acceleration: aiming was the entire
game and the only feedback on your aim was whether you hit something. Gideon's note after one
session was to make the crane rotate instead - the same lag, the same lead, but with a boom
visibly pointing where he had dragged. **Indirect control needs a visible intermediary**: the
thing the input moves directly has to be on screen, so the lag reads as the tool trailing
rather than as the game not responding.

Two things make that work rather than merely look nicer. **Draw the intermediary and the
trailing thing as separate objects** - the gap between the boom and the ball IS the lag, drawn,
and it is the whole tutorial. And **give the machine a part that reads its own orientation from
behind**: a counterweight opposite the boom is the only thing that says which way the turret is
facing when the boom points away from the camera.

**When the tool's dimensions change, every framing decision calibrated on the old ones is
wrong.** Shortening the boom to a third of its length - which the design required, because "at
rest the tool falls just short of the target" was the load-bearing number - compressed the whole
machine toward the camera and put a two-metre ball across a quarter of a portrait screen. The
camera had to go back nearly half as far again. Re-shoot after any change to a length.

**Make the failure a SHAPE rather than a number.** The interesting risk in a demolition is
not how much came down, it is which way it went. Wrecking Crew's lean is the centroid of
what is still standing over the building's half width: work the bays alternately and it
stays at zero, work along one side and it goes over onto the neighbours. The player is
managing a picture, not a bar, and the gauge is a direct reading of the same number the
building is drawn leaning by - so the HUD cannot lie about the world.

Three details that turned out to be load bearing, and are worth stealing whole:

**The failure state needs something visible to fail ONTO.** The blocks either side of the
site are the entire stake. A lean gauge with nothing next to the building is a number about
nothing, so they are placed close enough to be in frame and painted LIGHTER than the
condemned building - separated by lightness, so "the one you must not hit" and "the one you
must" read apart at a glance.

**Judge the bonus on the worst state reached, not the final one.** When the last bay lands
there is nothing left to be off-centre, so a clean-drop bonus keyed on the final lean pays
out for every demolition including the reckless ones. What is being rewarded is never having
come close, and that is a maximum over the whole job.

**Check the endgame of any "balance" metric before shipping it.** The same centroid that
makes the mechanic work says the LAST remaining piece is at maximum imbalance, by
definition - so without an explicit "a lone piece cannot topple" clause, no building could
ever be finished, in any order. A metric derived from what remains will always do something
strange as what remains approaches nothing.

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

**A correction must be assigned, not added, or it is a spring instead of an approach.** Coreward's
lane pull did `v += laneVel(...)` on top of a velocity that was often already carrying the ship
toward the line, so the pair overshot, got corrected, and overshot again. The player's word for
that was "bouncy". Assigned, the value IS the exponential approach and overshoot is impossible by
construction. Any time a smoothing term is added to an existing velocity rather than replacing it,
it is a spring with no damping term and it will ring.

**Never correct anything while the player is coasting.** The same pull ran with no input held, and
the nearest snap target is as often behind the object as ahead of it - so releasing near a boundary
dragged the ship *backwards* against its own momentum. A release must be drag and nothing else.
Snap on the next input instead: the player said it themselves as "don't align until you change
direction", and it costs nothing, because by the time the alignment matters they have pressed
something.

**A correction that writes position directly is invisible to collision, and therefore to every
test.** Coreward's drill alignment set `g.px`/`g.pd` outright and aligned whichever axis did not
match - which for a dig is always the axis of the cut, since the target cell is a step ahead. It
drove the ship *into* the rock it was drilling, and nothing caught it for three sessions because a
second bug (the coasting pull above) shoved it back out on release. **Two bugs can hide each
other, and fixing the visible one is how the other surfaces** - so when a fix makes a *different*
test fail, suspect a mask rather than a regression.

**Exponential everywhere it matters, and keep the coast short.** Anything that reads as momentum
also reads as the controls being late, on a game played with a thumb. Coreward reaches top speed
in about a fifth of a second and coasts about three quarters of a cell. There is a test on the
coast distance, because that single number is most of what "free to fly" feels like.

**Spline flight beats stepping between waypoints.** Moving along a Catmull-Rom curve with ease-in
and ease-out, with the heading following the velocity, is what makes movement read as piloted.
High speed alone reads as fast-forward.

**Drive a tool from the player's ACCELERATION and you get indirect control for free.**
Wrecking Crew's ball hangs on a boom and is a damped pendulum on a moving pivot: the only
term the player controls is the pivot's lateral acceleration, so pushing the rig right
throws the ball left and it arrives on the right about a quarter of a swing period later.
The player never places the tool, they only ever push it. That single change turns "steer
into the thing" into "decide now where the thing will be in a second", which is the skill
every runner claims to have and almost none actually implements.

Two things make it work rather than merely frustrate. **The lag has to be a feel constant,
not physics.** Real gravity on a five-metre chain is a 4.5-second period, which is majestic
and unplayable; the number is set from what a thumb can anticipate - about a second - and
`sqrt(g/L)` is then solved for `g`. And **the correct technique has to be discoverable by
accident**: a sloppy single swerve still just barely connects, while the timed version -
load away from the target for a HALF period, then turn back - reaches 60% further. The
beginner gets contact, the expert gets twice the contact.

**If a tool is driven by acceleration, the rig that drives it cannot use a position lerp.**
An exponential lerp on position has an acceleration that spikes on the frame the input
changes and is zero for the rest of the move, so the tool gets kicked once and then hangs.
Approach a target VELOCITY exponentially instead: the acceleration is smooth, bounded, and
lasts as long as the drag is held, which is what lets a swing build. The cost is that `vx`
lags its target, so the object overshoots slightly - 4% in the first build - and the fix is a
faster velocity rate rather than a spring term.

**A speed ladder outruns any tool whose lag is measured in seconds.** Speed compounding at 5%
a street is invisible for four streets and then quietly removes the game: the window a target
is aimable in shrinks by the same fraction every level while the swing takes exactly as long
as it always did. By street 10 a building passed faster than the ball could be swung at it,
and by street 20 at half that. A design test caught it - `window > lag`, at levels 1, 5, 10
and 20 - and the fix was to cap speed and make later streets harder by growing the *targets*
instead. **Any game with a charge time, a wind-up, a reload or a lag should assert that
relationship at the top of its ladder, not just at the bottom.**

**A fixed camera and vehicle-relative controls are tank controls, and players feel it before
they can name it.** Wrecking Crew's machine took a throttle and a steer while the camera held
a fixed orientation - so whenever the machine faced back toward the lens, forward on the stick
drove it DOWN the screen and right turned it left. Gideon's report was "the driving controls
almost feel backward but not sure if that is the main issue", which is exactly what a control
scheme that is correct half the time produces: not a clear complaint, a nagging one.

**The rule: the frame the CONTROL speaks in must match the frame the CAMERA speaks in.** A
camera that turns with the vehicle can take vehicle-relative input. A fixed or world-aligned
camera needs world-relative input - push the stick where you want to go, and let the vehicle
work out its own heading. Mixing them is the bug, and it is invisible in any test that drives
the input seam directly, because at the seam both schemes look identical.

**Give a one-dimensional quantity a one-dimensional control.** The boom only slews, and it
had a dial - so the thumb had to be placed precisely on a circle to say something a line
could say, and the vertical half of every drag was thrown away. Gideon: *"the controls don't
need to be a dial look. since we are only controlling the turning, it could just be a left
and right joystick or slider."* A wide slider also buys precision for free, because width is
pixels per radian.

**And put the lagging thing on the control next to the thing being controlled.** The slider
carries the boom's knob AND a small mark where the ball actually is. The gap between them is
the lag the whole game is about, and it can be read without tracking two objects in the 3D
view at once.

**"It feels like it drifts" usually means the PATH curves, not that the physics slide.**
Wrecking Crew's machine has never had a lateral term - every step's displacement lies along
its own heading, and there is a test asserting it. What it had was a throttle floor of 45%
that applied through even a 180-degree correction, so every change of direction came out as a
long arc. Under a camera that holds a fixed orientation, a vehicle sweeping a curve reads as
a vehicle sliding. **Check the path before you check the integration**: the player is
describing the shape they see, not the term you are looking for.

**A tracked vehicle is one constant away from a car: the cone it must be facing within before
any throttle is applied.** Outside it, counter-rotate and do nothing else; inside, ramp the
throttle in as the nose comes round. That is the whole difference, and it is what "hold right
and it turns to face right, then moves" actually is. Pair it with a turn rate that is fast at
a standstill and much slower at speed, or the machine carves out of every turn anyway.

**A displacement test has to exclude the frames where something legitimately teleports the
object.** The "moves only along its heading" test failed immediately on the wall clamp, which
writes position directly and is a correct sideways displacement - the alternative being to
drive through concrete. Skip those frames and say why in the test, or the next person deletes
a true assertion.

---

## Graphics that carry on a phone

**Instancing is the whole game** — but not for the reason usually given. Coreward went from 207
draw calls to 35 by instancing terrain; Captain Run draws 26 vikings, 18 draugr, a boss, 420 loot
chunks and all scenery in 42–55 calls. What instancing actually buys is that **the draw count
stops being a function of how much content exists**, which is what keeps it from drifting as a
game grows.

**The "50 to 100 draw calls on mobile" rule of thumb is off by more than an order of magnitude,
and it is worth knowing that before designing around it.** Measured on Coreward: 5.0 microseconds
per call, linear from 79 to 2,519 calls, so about 3,200 calls to miss 60 fps on a desktop and the
high hundreds at worst on a phone. The game uses 60. A budget set at that guideline is a
regression detector wearing a hardware limit's clothes — useful, but do not let it talk you out of
a feature. **Fill rate is the real cost on a phone**, because that is what a heavier shader
charges and what feeds thermal throttling: Coreward's PBR terrain cost 0.098 ms/frame at an
unchanged draw count, which is more than a hundred extra draw calls would have.

**Instance the body parts, not the character.** One `InstancedMesh` per part — leg, torso, arm,
head, helmet, weapon, shadow — with matrices recomputed each frame from a procedural animation
cycle. Crowd size then stops being a performance question at all, and a boss is the same rig at
3.3× with a different colour: a whole boss for zero extra draw calls.

**Instance the bolt-on hardware too, not just the crowd.** Coreward's upgrade parts started as
thirteen separate meshes and took the worst case from 55 draw calls to 67 against a budget of 70 —
three from failing CI, for what is four copies of two shapes. One `InstancedMesh` per KIND with
`count` as the lever is exactly the semantics an upgrade ladder wants (show the first n), and it
stops the draw count moving with how upgraded the player is, which is otherwise a budget that
fails only for veterans.

**A point light does not know the rock is there, and on a 2.5D grid that is the difference
between "the picture got darker" and "I can only see where my lamp reaches".** Coreward's lamp
lit a side tunnel the player had never opened exactly as brightly as the shaft they were flying
down, because falloff is a function of distance and nothing else. The fix is a **flood fill over
the grid**: light travels through OPEN cells only, so what attenuates a cell is the length of the
path along the tunnel rather than the straight line. A shaft lights all the way down; a branch is
dim because the light went round a corner; unopened rock is black because there is no path to it.
It costs a Dijkstra over a few hundred cells, run only when the ship changes cell or the terrain
changes shape — microseconds, and no draw calls at all.

Four things make that work rather than merely run:

- **Store visibility, not brightness.** Per cell, keep `exp(-att * (pathLength - octileDistance))`
  — how much LONGER the light's real path was than a clear run would have been. Open space then
  comes out at exactly 1 and only geometry can darken anything. Subtracting Euclidean distance
  instead of octile puts a permanent haze over open ground, because eight-way steps do not add up
  to a straight line.
- **Split the continuous half out.** The grid cannot move smoothly and the ship can, so distance
  falloff belongs in the shader, evaluated per pixel from the ship's exact position. Leave it in
  the grid and the pool of light steps a whole metre at a time as you fly.
- **Upload it as a tiny texture and sample by world position.** 15×36 texels with `LinearFilter`
  is 2 KB and interpolates, so light fades ACROSS a rock face instead of stepping at cell edges.
  One `DataTexture`, one shared set of uniform objects wired into every material by reference, so
  a per-frame position drives thirty materials with one write.
- **Multiply `reflectedLight`, not the final colour, and clamp to at most 1.** Scaling
  `directDiffuse`/`indirectDiffuse`/`directSpecular`/`indirectSpecular` after
  `<lights_fragment_end>` leaves emissive alone, so ore keeps glowing in the dark — which in a
  mining game is the entire find-the-ore mechanic. Clamping to 1 means every lighting value
  calibrated by eye against the old renderer stays the ceiling it was.

**A flood has no notion of an edge, and a corner shadow is an edge.** Light that turns a corner
in a flood arrives from that corner in every direction at once, so a tunnel crossing the
player's path lights along its whole length, gently, when what should happen is that the corner
throws a shadow into it. That is a question about straight lines from a point, so it wants a
second solver: **fan a few hundred rays out from the light by grid DDA and record, per angle,
how far light gets before something stops it.** One-dimensional, so it uploads as a 512-texel
texture; a fragment is in shadow if it is further from the light than the occluder on its own
bearing. Sharp by construction, exact for any geometry, and the wedge behind a corner widens
with distance for free, because that is what a fan of rays does. It has to run every frame
rather than on cell changes - the whole point is that the shadow moves as the player does - and
a few thousand grid steps does not show up in a measurement.

**Record the FAR side of the first wall the ray hits, not the near side.** A wall's face is the
surface the light is falling ON and has to stay lit; shadow starts behind it. The near side
puts every rock face in the game into its own shadow, which reads as "the lighting is broken"
rather than as an off-by-one.

**Light on surfaces and light in the air are two different lights, and a shadow belongs to
only one of them.** Coreward ran one lighting number and handed it to both, so the ray fan -
which answers "can light get along this tunnel to here" - was also carving hard-edged wedges
across every rock face in the frame. A surface is lit by being NEAR a lit space, which is a
property of the surface; the air in a corridor is lit by light travelling along it, which a
corner can block. Same terms, one difference:

    SURFACE   flood x falloff x beam
    AIR       flood x falloff x beam x shadow

They also want very different ambient floors - a corridor is full of dust with light bouncing
off every wall in it, a surface the beam is not on is simply dark. Sharing one figure made
every side passage read as a hole.

**And the process lesson under it:** three rounds of playtest notes all pointed at this and
were all read as tuning requests, because each one described a symptom on a rock face. The
tell was that the complaint kept coming back after a fix that genuinely worked. **A note that
survives a correct fix is a note about something else.**

**A shadow fan sampled by angle needs the FARTHEST CORNER of the cell it hits, not where the
ray leaves it.** Per ray, the exit distance is exactly right - a point inside the cell is always
between entry and exit. But the shader interpolates between the two nearest rays, and those may
have clipped quite different parts of the wall or missed it, so parts of a cell come out beyond
their own occluder and go dark. In Coreward that was thirteen per cent of every wall face, and
on screen it is a hard diagonal cut across every single block in the frame - it reads as every
rock casting a shadow on itself, which is what the playtester called it. The rule the fan
exists to express is "the first wall is lit", and a wall is a whole cell.

**The test for that has to interpolate the way the shader does, and assert a ratio.** A
nearest-ray lookup cannot see the artefact at all, because the artefact only exists once two
rays are blended; sampling cell centres cannot see it either, because a centre passes under
both rules. Sample across a wall face, blend the two nearest rays, and assert the fraction of
lit-face-in-shadow stays under a few per cent.

**Give the soft, omnidirectional half of a light its own falloff.** Sharing the beam's pool
means the ambient glow behind the player ends exactly where the beam does, with the same hard
edge - which is the one thing the soft half must not do. Longer reach, much gentler curve.

**Dim glowing things on a separate, gentler curve from surfaces.** Emissive and additive haloes
exempted from the light field entirely become the loudest thing on screen at any depth, so a
glowing pickup deep inside unlit geometry reads as clearly as one at arm's length; run through
the same curve as a surface, they switch off and take a discovery mechanic with them. A square
root over a small floor keeps the near ones bright and pushes the distant ones to a smudge.

**Combine a directional beam and an omnidirectional bounce with `max()`, never by multiplying
two floors.** Multiplying "how much survives behind the player" by "how much survives in
shadow" means anywhere that is both lands on the product - four per cent of four per cent,
which is black. In Coreward that erased the shaft the player came down, which is the way home.
One bounce term at about a fifth of the beam, gated by the same flood so it lights opened
tunnels and never solid rock, and take whichever is larger.

**A lighting multiplier scales LINEAR light and is then sRGB-encoded, so its dark end lifts
enormously.** Six per cent of the light displays at roughly a third of full brightness. A field
that is numerically correct therefore reads as a grey wash over everything, and every plausible
suspect - lamp intensity, ambient, fog, the background layers - measures innocent in turn.
Square the multiplier before applying it. This is not a fudge; the alternative is to keep every
constant honest and then hand the result to a display that disagrees.

**Rock must be relaxed but never expanded.** A wall next to a lit tunnel is lit; light stops
there. Let rock pass light on and a one-cell wall leaks a third of the lamp into the chamber
behind it, so every sealed pocket glows faintly and tells the player it is there before they have
dug to it. The fade INTO the mass is a separate pass that only ever writes to rock, so it cannot
leak into open air either.

**Lighting a surface is only half of "light fills the tunnel".** A dug cell contains no geometry,
so there is nothing in it to light and the tunnel reads as an empty slot. One additive quad across
the frame, sampling a second channel of the same texture that is non-zero only in OPEN cells,
turns the void near the lamp into glow and leaves the far end black. One draw call, and it is the
single change that made the feature read.

**A per-cell mask sampled with LinearFilter bleeds a FULL CELL in every direction, and on a
one-cell feature that is a blob rather than a shape.** Coreward stored "is this cell open" as one
texel per cell; a one-cell-wide tunnel is therefore a single 255 surrounded by zeroes, and
bilinear filtering ramps that to zero only at the neighbouring texel's CENTRE. The tunnel glow
painted three cells wide and read as a circle of light bleeding through solid rock. It took
three rounds of playtest notes because two other things were genuinely making a circle too.

The fix is to keep **brightness and shape in separate channels** - one channel for the eased
light value, one hard 0/255 bit for openness - and re-normalise the filter's own ramp in the
shader: `smoothstep(0.5, 0.98, mask)`. Bilinear leaves exactly 0.5 at a cell boundary and 1.0 at
a cell centre, so that maps the glow precisely inside the cell. Sharpening a combined value
instead would crush every dim tunnel to black, because "dim" and "outside" are the same number.

**And the process half: when a symptom survives two correct fixes, stop fixing and start
measuring.** Printing fifteen numbers out of the buffer ended a three-round hunt in one call.

**When you replace the reason for a workaround, delete the workaround in the same commit.**
Coreward bled a tunnel's glow half a cell onto the rock around it, to stop wall bulges reading
as unlit chips inside a lit shaft. A version later the real fix landed - the glow quad moved in
front of the terrain - and the bleed stayed, because nothing failed when it became unnecessary.
What it did instead was paint an additive wash over every rock face near the player: a circle,
over solid rock, softening the very shadow edges the shadow solver existed to draw. It took two
rounds of playtest notes to find, because a leftover workaround is indistinguishable from a
deliberate choice.

**When a lighting model lands, audit everything that emits light - not just the thing you set
out to replace.** Coreward had a wide additive halo sprite on the ship standing in for "there is
a lamp here". It predated the propagated light, it kept working, and because it was small enough
to read as part of the ship it survived three rounds of "the lighting still looks wrong". It was
the last object in the frame obeying different rules: additive quads know nothing about
geometry, so it painted a circle over solid rock. **A fake put in before the real system exists
does not announce itself when the real system arrives.**

**A gauge you check under pressure must not move for reasons unrelated to the check.** A
tachometer ring was added around a fuel dial on request and removed the next round: it swept
every time the player moved or dug, which turned a glance at the one reading that decides
whether to turn round into something you had to parse. Movement on an instrument has to be
earned by being read.

**Delete the fake when the real thing arrives.** Coreward drew a volumetric cone from the drill
as a stand-in for a headlight. Once light actually propagated, the cone was a triangle drawn where
light was *supposed* to be — it passed through solid rock as happily as through air, and it
contradicted the thing next to it. What survived was the one job it was uniquely good at: the
Scanner upgrade having a silhouette. That moved to the size of the lamp's own glow.

**Put the source glow BEHIND the character, not in front.** An additive quad centred on a lamp
that sits in front of the ship washes straight over the hull, and the ship renders as a bright
blob with no facets — the exact fault that render layers were added to fix, arriving by a
different route. Behind it, the ship silhouettes against its own light, which is what a lamp on a
machine actually looks like.

**Where a readout sits matters more than what it looks like.** Coreward's fuel, hull and cargo
were bars along the top of the screen. They got a full instrument restyle - segments, ghost
cells, scanlines, numbers - and were still wrong, because the top of the screen is the one place
you are not looking while playing. Moving them to the corner beside the thumb that is already
there did more than any amount of paint. **If a restyle does not fix a "feels out of place"
note, the problem is placement, not surface.**

**For analog gauges in the DOM, use SVG and `pathLength="100"`.** It renormalises a path so its
length is exactly 100 regardless of the real geometry, so "show 62 per cent" is
`stroke-dasharray: 62 100` and nothing needs to know the radius. Needles are one transform
each. It stays crisp at any pixel density with no redraw, and the drawn fraction is directly
readable from a test - which is what lets an assertion follow a value from a bar to a dial
without becoming a lie.

**Generate tick marks, never hand-place them.** Thirty lines of SVG is thirty chances to be half
a degree out, and every one has to be redone for the second dial. The geometry is four lines of
trigonometry.

**Give a needle mass.** Easing it toward its reading instead of snapping is most of what
separates an analog gauge from a bar with a pointer on it. Damp each one to what it shows: a
fuel needle only ever falls slowly, a load needle is chasing something that changes in a tenth
of a second.

**A HUD sitting on a textured world needs a material of its own.** Translucent fills with soft
corners are a clean overlay and the wrong one over photographed rock: the controls end up the
only part of the screen made of nothing. One plate does it - a rolled-steel gradient, a small
hard corner, a bright top edge and a dark bottom one, and a generated grain over the top. Draw
the grain as fine speckle plus a coarse mottle plus a HORIZONTAL STREAK; the streak is what
gives it a rolling direction, and without it noise reads as television static rather than as
metal. Sixty-four pixels, tiled, built once at boot from a deterministic hash so screenshots
stay comparable - zero bytes shipped.

**Grain wants to be felt, not seen.** The first pass was three times too strong, and the tell
is simple: you notice the texture before you notice the panel.

**A pressed control should read as pushed IN, not lit up.** Coreward's d-pad flooded cyan on
touch, which made it the loudest thing on screen at exactly the moment a thumb was covering it.
Inverting the bevel and dropping it a pixel says the same thing and gets out of the way.

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

**A gradient sky in CSS and real post-processing are mutually exclusive, and that is the thing to
decide first.** Rendering with `alpha: true` over a CSS gradient is free and looks great — until
you want an `EffectComposer`, at which point the scene renders into an opaque render target and
the sky it was compositing over goes black. Measured on Coreward: `UnrealBloomPass` at half
resolution cost **0.096 ms/frame** (0.357 → 0.453, 27% of a very small number) and was never
going to be the problem; the problem was that the sky vanished and the palette shifted — brown
rock to grey, a cyan beam to green. `OutputPass` fixes the colour-space half and does nothing for
the alpha; `RenderPass.clearAlpha = 0` does not rescue it either, because the bloom composite is
additive and destroys alpha inside the chain. **If a game might ever want a post pass, put the
sky in the scene from the start** — a fullscreen gradient quad is barely more code than the CSS
and does not have to be unpicked later, along with everything calibrated on top of it.

**Moving from Lambert to MeshStandardMaterial changes the SHAPE of the lighting, not just its
values.** Standard adds a specular lobe, so every light now contributes a highlight as well as a
diffuse term and the old intensities read as a bright plastic wash. Turning everything down is not
the fix: **ambient has to fall away much faster**, because ambient is the one light that reaches
every surface equally, which is the exact opposite of a lamp in a dark hole. Coreward went from a
linear falloff to a squared one so the drop lands in the first third of the descent where it can
be felt.

**A metal with no environment map has no diffuse term at all** — a metal's colour comes entirely
from what it reflects, so with nothing to reflect it is specular hotspots and black. Lowering
metalness looks like the fix and is not; the fix is giving it something to reflect. A 64px canvas
gradient standing in for "dark ground below, faint light above", run through `PMREMGenerator`,
costs nothing and ships no bytes. Apply it **per material, not as `scene.environment`** — as a
scene environment it lights the terrain too and puts back exactly the flat fill a darkness pass
just removed.

**And set `colorSpace` on it.** A canvas env map read as linear rather than sRGB comes back about
four times too bright, which presents as "the metal is blown out" and sends you hunting through
light intensities. The same rule catches normal and roughness maps from the other side: those are
DATA, not colour, and must NOT be sRGB-decoded.

**Do not light the player's vehicle with the gameplay light.** Coreward's lamp is a point light on
the ship, so the ship sat four times closer to it than the rock it lit and rendered white whatever
its hull was painted. The real problem was worse than the look: lamp range is an UPGRADE, so
buying a Scanner level changed how the ship looked. Put the vehicle on its own layer with its own
small key light, and its material reads the same at every depth and every upgrade level.

**When a render looks wrong, measure it rather than staring at it.** Hide the object and see if
the problem goes; `gl.readPixels` the actual pixel; recolour materials one at a time to find which
mesh is which. Coreward's "white ship" was blamed on four different things in turn, and the mesh
everything was pinned on turned out to be a small cap at the top while the pale mass was a
different material entirely — whose values were ordinary mid-greys that only read as white against
very dark rock.

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

**And check the defaults you did not set, not the properties you did.** Wick's gate labels were
invisible; every property worth inspecting said they were fine - visible, positioned, textured,
renderOrder above the curtain, a texture with 27,000 opaque pixels. A `PlaneGeometry` faces `+z`,
that camera looks along `+z`, so the player only ever saw the back face and `FrontSide` culled
it. Papering over it with `DoubleSide` then rendered the text mirrored, which is the same bug
wearing a second symptom. Rotate the plane `Math.PI` about Y. **When something renders as
nothing, enumerate what you never configured.**

**Gradient skies for free.** Render with `alpha: true` and no scene background, then put a CSS
gradient behind the canvas.

**A prop placed relative to where the player stops has to clear where the camera goes when they
stop.** Candle Gift's display table sat two units past the finish line, which was fine for the
whole run and wrong for the one shot that matters: the end-of-run camera swings forward past that
line to look back at the player object, so a six-metre slab ended up between the lens and the
thing being framed and the shot was mostly table corner. **Any end-of-run camera move is a second
placement pass over everything near the finish** - and moving the camera *behind* the object
rather than in front of it makes the scenery beyond the finish a backdrop instead of an
obstruction.

**A transformation that can be dodged is a power-up; make it a wall.** Candle Gift's ROTATE
stands the whole batch upright, and while it was an ordinary station occupying one half of the
track it was optional and could fire twice a level - so the press downstream was stamping
candles that might still be lying on their sides, and the biggest moment in a run was
something a player could miss entirely. Spanning the full track turned it into a section
boundary: a level is now "wax while you lie flat" then "machines while you stand", and every
station after the wall can assume the form it needs. **If a change is big enough to divide a
level into before and after, place it so it cannot be missed.**

**Starting the player with one of the thing they collect changes what the game is about.**
Candle Gift began runs with eight candles, and the first thirty seconds were free - nothing
picked up mattered and losing three was an inconvenience. At one, the first loose candle is the
most valuable object in the game. Two consequences worth knowing before doing it: flat damage
has to be capped as a *fraction* of what you hold, or the first hazard ends the run before the
player has touched anything; and **the value of defensive play collapses** - measured, a bot
that only dodges now scores what a bot that does nothing scores, because the candles it saved
are ones it never picked up. That second one is a real design fact, not a bug, and it is worth
leaving in the numbers rather than massaging out.

**Frustum culling will not save you from something dead ahead.** Twelve shop-front meshes 200
units down a narrow lane were inside the frustum for the whole middle of a level and cost
twelve draw calls where the peak is. One `visible =` line on the group gave them all back.
**Distance is not culling**; if a thing only matters for the last seconds of a run, switch it
off for the rest.

**Do not copy a monetisation mechanic into a game with no monetisation.** Candle Gift ends a
run on a five-wedge multiplier fan, and the fan is a rewarded-video gamble: you watch an advert
to spin it. Copied into a game with no adverts it became a wheel that always lands on the same
wedge - a wheel-shaped lie, and a screen that takes an extra tap to say what a line of text
already said. **Ask what a borrowed mechanic is *for* in the original before copying its
shape**; if the answer is "to sell an impression", the shape is not the part worth having.

**A liquid is made of motion and answers, not of texture.** Wax pools read as coloured carpet
until they (a) scrolled their surface, (b) spread a ring wherever something entered them, and
(c) had a ladle that slid across to stay above the thing being dipped. All three are a few
lines. The tempting fix - a photoreal water normal map - would have given the surface relief
and left it just as dead, and would have been the join that shows in the first frame. Worth
knowing before reaching for an asset: **ambientCG has no `water`, `liquid` or `ripple`
material at all**; the nearest hits are plaster and paint, which read as a rough wall.

**A transformation is worth ten multipliers.** Candle Gift's stations felt like power-ups
here and like machinery there, and the difference was one thing: its ROTATE station stands the
whole batch up off the track into a tower, and its press stamps a visible cross-section. Ours
awarded a number. **The test for a "satisfying" station is whether a screenshot taken before
it and one taken after are obviously different pictures** - not whether the score went up. A
multiplier is a fact about the scoreboard; a transformation is a fact about the thing the
player has been steering for thirty seconds.

Two corollaries that made it cheap. **Show the die, not just the press**: one mesh per shape,
only the active one visible, and the machine standing over the track is literally the shape
you get. And **a container needs a rim**: the wax pools were flat planes painted on the road
and read as carpet; a box standing 0.4 proud with its wall in a darker shade of the same
colour reads as a tank holding liquid, for one extra mesh.

**A long-play video is worth ten store screenshots.** Candle Gift's eight official
screenshots show the runway and almost none of the UI, and four rebuilds off them got the
world closer and closer while every *screen* stayed wrong. One four-minute "levels 1-6"
walkthrough showed the home screen, the end-of-run ruler and the reward screen in one pass -
and showed that the reference has **no upgrade screen at all**, which no amount of staring at
screenshots would ever have revealed. **Search for the longest playthrough, not the prettiest
capture**, and note that these disappear: one of the three found for this game was already
gone a day later.

**Absence is the hardest thing to observe, and the most valuable.** The finding that moved
this game most was not a feature to add, it was a screen that was not there: no stat-upgrade
list anywhere in six levels. Our version opened one after every level. When comparing against
a reference, list what it does *not* have as deliberately as what it does - a screen you
invented is invisible to you precisely because you built it on purpose.

**A HUD is a claim about what the player should be thinking about.** The reference shows
three things: settings, level, money. This build had grown a candle counter, a live value, a
colour-chip readout and a progress bar - each individually justifiable, and together the main
reason a screenshot of it did not look like a screenshot of the thing it was copying. Adding
a readout is the cheapest change in a game and the easiest to keep adding.

**Magnify the reference before you model from it.** Three passes at Candle Gift's obstacles
were built from store screenshots viewed at page size, and all three came out as generic
shapes - a red box, beads on a string. Cropping the same images into a canvas at 4x with
`imageSmoothingEnabled = false` showed a rimmed panel with a recessed face, interlocking
diamonds on a shaft anchored to a post *outside* the rail, and a navy arrowhead that says
which way the moving one is going. Those details are 40 pixels wide in the source and they
are the entire difference between "similar" and "the same game". **If you are modelling from
an image, the crop is the research step, not the glance.**

**Every hazard in one colour family.** Candle Gift makes everything that costs you candles
coral - panel, spikes, sweeper - so "this hurts" is one thing the player learns once and then
reads at distance, in peripheral vision, at speed. Variety belongs in the silhouette and the
behaviour, not the palette.

**An obstacle anchored to the edge of the track guarantees its own gap.** The reference's
spiked roller stands on a post outside the rail and reaches part way across; there is always
somewhere to be. Deriving the collision box from that anchor - centre and half-width computed
from the side and the reach - also means the hit box cannot drift away from the drawing,
which is the usual way a fair obstacle becomes an unfair one.

**Decorative meshes that are not instanced cost the same as the thing they decorate.** Three shop
fronts of seven meshes apiece took Candle Gift from 63 draw calls to 87 the moment they entered
the frustum, and the extra four per front were an outline hull and a `+` built from two crossed
boxes - both invisible at the distance they are ever seen from. Baking the `+` into a 64px canvas
texture and dropping the hull cost nothing visible and gave back twelve calls. **Count the meshes
in a decorative group before you place three of them; detail below a few pixels is pure cost.**

**A panel over the game is a pop-up however you style it.** Leaving half the world visible behind
a shop says "you are still out there". Hide the game entirely, give the screen a window that looks
out on where the player actually is, and put the exit at the bottom where a door would be.

**And a list is a list however you style it.** That fix was still a scrolling list of rows on a
painted background, and the next note was to make it a room. A second scene - the shop drawn as
somewhere you stand, with the goods on pedestals - costs one extra Scene and camera and reuses
every material the game already has. The rule underneath: **if the player is meant to feel they
are somewhere, the somewhere has to be geometry, not gradients.**

**A 3D shop still needs labels, and their size is decided by the screen.** Coreward's cases are
readable at a glance because each carries a canvas plate on its plinth - label text that belongs to
the case and turns with it, rather than HTML hovering in front of the room. At that camera the
visible width is ~3.5 world units across 375 CSS pixels, so a 0.66-unit plate is about 70 px:
a six-character word and nothing more. That is why they read DRILL and THRUST, not "Drill Bit" and
"Thrusters" - the full name goes in the detail card. **Measure the pixels the label will occupy
before choosing the words.**

**Say an availability state three ways, not one.** Coreward's cases carry it in a strip of light
(colour), the plate's second line (text) and how far the alcove is shuttered (value), so it reads
at a glance AND survives a colour-blind player. Four states: ready, short, sealed, maxed.

**Dim the case, not the object, when the object's material is shared.** The parts in those cases
are the same materials as the parts on the ship - tinting one to show "you cannot afford this"
would have dimmed the same part bolted to the ship parked in the middle of the room. A smoked panel
in front does the job and keeps the shared-object guarantee intact.

**Order the states deliberately and test the ordering.** Sealed beats affordable: quoting a price
for something no amount of money can buy is a lie, and the depth IS the price. Maxed beats
affordability. And name the missing MINERAL ahead of the credits, because credits are what the loop
pays constantly - a mineral the player has never seen is the thing actually stopping them.

**Show the REAL object in the shop, not a preview of it.** Coreward reparents the actual ship into
the station scene rather than building a copy, and the parts in the display cases are the same
geometry and materials that get bolted to the hull. So "what changes in the shop" and "what
changes in play" cannot disagree — not because they are kept in sync, but because there is only
one of them. Any time a shop shows a thing the game also shows, a copy is a second source of truth
that will drift, usually within one session.

**Lay a 3D shop out for the aspect ratio you actually have.** Portrait is ~0.46, so a 46 degree
vertical field is only ~22 degrees horizontal: eight units back shows 6.8 units of height and 3.1
of width. A hangar laid out sideways — the obvious shape for a hangar — puts most of itself off
the edges of a phone. Racking the goods in vertical columns flanking the centre is both what fits
and what a parts wall in a workshop looks like anyway.

**One scroll region per screen.** Giving an inner list its own `overflow-y` inside a flex column
quietly clips it at the fold — an entire category looked like it held one item, and another looked
like it did not exist.

**Draw the control as the thing it controls.** Wrecking Crew's crane dial is a top-down picture
of the machine: the tracks, the turret, a boom pointing where you have dragged, and - the part
that earns it - a dot for the ball at its ACTUAL bearing, which is not where the boom is
pointing. The gap between the two is the lag the whole game is built on, and putting it on the
control means the player can read their own aim without looking up at the crane. A generic
stick would have shown the input; this shows the *state*.

Drive it from the same source the world uses (`sim.yaw`), never from the drawn object's
transform, so the control and the thing it controls cannot disagree.

**And an on-screen control should be absolute, not relative.** A relative mapping lets the
thumb and the dial drift apart until the picture no longer says where the machine is pointing,
which defeats the entire point of drawing it.

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

**A metric is only useful if its denominator is the thing in question.** Coreward's run log
reported "98.5% of blocks paid", which was true and worthless: plain dirt had started paying a
token amount, so `value > 0` was true of nearly everything. Reusing the game's own existing
threshold for "worth coming back for" turned it back into an answer. A ratio that is always ~100%
is measuring the wrong set, not reporting good news.

**Telemetry earns its place by reporting rates and ratios, not counters.** Nobody balances against
"fuel burned"; they balance against "a full tank is 3m 21s of drilling", "31% drilling, 15% flying,
53% still", and "25% of runs ended in a tow". And make an unused thing SAY it is unused - "never
used" as a value, with a note explaining what that implies - because a zero the eye skips past is
the single most valuable reading in the file: it means the ability does not need tuning, it needs
deleting or rethinking. Cost is not the objection people expect: fifteen `+=` on a flat object per
frame measured below the noise floor of the frame time itself.

**If a system applies itself, the player is not playing it.** Candle Gift's stations first
spanned the whole runway, so every tray got every treatment just by reaching the end - and
four scripted play styles, from never touching the screen to playing well, produced an
*identical* per-candle value. Everything downstream still worked; there was simply no input
in it. Splitting each station into two halves across the track, one effect each, turned a
fixed consequence into a chain of decisions. **Measure a mechanic across a bad run and a good
run: if the number does not move, the mechanic is scenery.**

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

**A test of a PRIORITY has to use the case where the priorities disagree.** Coreward's "a depth
lock beats being able to pay" test used a rich player - and a rich player reads as sealed whether
the depth check runs first or last, so it proved nothing about the ordering it was named after. It
only surfaced because a mutation of that ordering was caught by a different test. The case that
distinguishes them is broke-AND-sealed: one ordering says "sealed", the other says "you are short
of money" and sends the player off to earn money for something money cannot buy. Same trap as
"assert the two interpretations actually differ" — when a test is about which rule wins, construct
the input where both rules apply.

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

**Calibrate against several procedural levels, never one.** Candle Gift's four scripted
policies swing 25% from level to level on layout luck alone - its "dodge hazards only" bot
scores 18,158 on level one and 1,350 on level five, where dodging is worse than doing
nothing. A `par` set from level one put the best policy on three stars there and two
everywhere else, and nothing about that was visible from the level-one numbers, which looked
clean and well separated. Take the mean over five or six seeds, and keep the single-level
numbers as a regression test that says in its own comment that it is not the calibration.

**Removing an obstacle kind means removing its share of the danger, not redistributing it.**
Deleting Candle Gift's saw and backfilling its spawn slot with a third barrier kept the
runway exactly as busy and cost the weaving bot a fifth of its score - with the same number
of candles lost. The damage was not to what the player *had*, it was to what they had *time
to do*: in a game whose skill lives in a second system, every second spent dodging is a
second not spent weaving. **When two systems compete for the same seconds, measure the one
you care about after changing the other.**

**A bot is a definition of "playing well", so it has to live in the repo.** Candle Gift picks
`par` - the number the star rating and the end-of-run gauge are both drawn from - by running four
scripted policies over a level and choosing the value that separates them. One pass measured with
an ad-hoc policy typed into the browser console, whose lookahead was a few units longer than the
one committed in `e2e`; it scored 64,606 where the committed bot scores 39,134, and par went in
44% too high. Nobody could have caught that by reading the number. **Measure balance with the bot
anybody can re-run, name it in the comment beside the constant, and pin the ratings it produces in
a test** - otherwise the constant is not measured, it is remembered.

**Restarting the run is not restarting the game.** Candle Gift's `freeze()` restarts the level in
place but leaves `S.level` alone, and every layout decision is keyed on `hash(chunk, salt + level)`
- so the headline test, comparing a weaving policy against a gathering one back to back, was
comparing two *completely different runways*. Not "one slightly harder": level 2 happens to be a
bad draw, where the same bot brings home 14 candles instead of 29. Any A/B over a procedural world
has to reset the seed inputs, not just the position. **Ask what the seed is keyed on, and check
your reset touches all of it.**

**What you own and what you have done are different lists.** Coreward's relic check asked "do I
already own this perk" — which answers yes for every planet past the eighth, where the perks
repeat, so relics silently stopped existing. Any time a reward repeats, the "already collected"
test must key on the *event*.

**If the policy that reads the level loses to the policy that ignores it, the bot is wrong
before the game is.** Wrecking Crew's first aiming bot steered straight at the kerb it wanted
to hit, and scored BELOW a bot that ignored the street entirely and weaved rail to rail on the
pendulum's period. The instinct is to read that as "the game does not reward aiming" and go
tune the game. It meant the bot had not been taught the technique the mechanic requires -
here, that driving at the target throws the tool the other way. Teaching it took street one
from 120 to 492 with no change to the game at all.

So: **a bot that loses to a dumber bot is a bug report about the bot.** Fix it before
touching a single constant, or a whole balance pass gets built on a measurement of the wrong
thing.

**A bot that only optimises will die, and a mean taken over dead runs measures how long the
game lets you live rather than how well the mechanic works.** The same bot finished six streets
out of six with no lives left, so every reading was of a game nobody had played to the end.
Give the scripted player the survival job as well and let survival win where they disagree,
which is also how a person plays.

**Sweep a manoeuvre rather than reasoning about its timing.** "Turn back when the tool reaches
its extreme" is the intuitive rule for a pendulum and it is wrong: it ignores that the vehicle
has to travel too, and the vehicle's own trip is most of the amplitude. Swept across load
times, a quarter-period load peaked at 4.19 and a half-period load at 6.76 - a 60% difference
that no amount of thinking about pendulums produced. Ten lines of throwaway script, and the
numbers went into the test's comment so the next person does not re-derive them.

**A test that samples one instant is testing its own timing.** The first version of that
assertion read the tool's position after the manoeuvre, found it 2.6 metres the wrong way, and
looked exactly like the physics being inverted. It had simply arrived half a swing late. The
thing being asserted was only true for a moment - and that moment is the whole game - so the
assertion has to be on the peak over the window, not on the end state.

**A saturating value stops being a consequence and becomes a constant.** Wrecking Crew's ball
swings further out the faster it travels, which is what makes reach a result of how hard you
swung. With the gain set high and the cap low, the radius sat PINNED at its cap for most of
every sweep - so the ball blanketed a band twice the width of the street, could not miss, and
the mechanic silently became "the ball is always at maximum reach". **Any value clamped at the
top of its range is only a mechanic in the part of the range it actually moves through**, so
put the cap somewhere the value rarely gets to, and measure what fraction of the time it is
binding rather than assuming.

**When two policies score the same, that IS the finding - do not go looking for a third
explanation first.** The instinct on seeing a reading bot lose to a blind one is to blame the
bot, which was right once on this game and wrong the next time. What separated the two cases
was cheap: sweeping the bot's one free parameter across eleven values took a minute and showed
no setting anywhere beat the blind policy, which rules the bot out and points at the design.
**Sweep the bot's parameter before touching the game's.**

**Make every scripted policy fail for a DIFFERENT reason, and you have a design you can
read.** Wrecking Crew's four: one touches nothing and scores zero; one swings blindly and
cannot reach the outer bays; one works the bays from one end and topples; one works them in
a balanced order and sweeps. Four rows, four distinct failures, and the table is a
description of what the game rewards. When two policies fail the same way - or worse, score
the same - one of them is not testing anything, and on the earlier build of this game that
was the signal that the whole genre was wrong.

**The pair that proves a decision exists must differ in exactly ONE thing.** The balanced and
the reckless policies here share all their code and take the same argument; the only
difference is which bay they pick next. Same control, same effort, same building on the
ground - 2.2x the score. That is a claim about the design that cannot be confounded by the
bots being differently good at driving.

**A test helper that plays the game is a second, worse player.** Eight tests failed here for
a reason unrelated to anything they asserted, because the helper driving the tool had its own
sweep and was quietly worse at connecting than the committed policy - so tests meant to check
"does a column take its hit points to break" were really checking "can this particular sweep
connect at all". Export the policy's own routine and have the tests drive through it. One
definition of how the game is played, used by the bots and the tests alike.

**A hand-derived ceiling is the wrong test for "is this physics stable".** Wrecking Crew's
energy test computed a bound from the machine's top speed and its rotation rates and asserted
the ball never exceeded it. It failed - correctly, and for entirely the wrong reason: driving
a pendulum near its own period PUMPS it, so the speed legitimately climbs well past anything
one push can produce. That is resonance, not a leak.

**Assert SATURATION instead.** Drive adversarially for a minute, take the worst speed in the
first half and the worst in the second, and require the second to be within a few percent of
the first. Real damping settles to a steady state; an energy leak grows without bound. The
test then says the thing you actually mean, and it stops firing on legitimate play.

**A safety clamp that fires in normal play cannot signal anything.** The same game capped ball
speed at a number ordinary hard driving reached, so the clamp was on much of the time and the
runaway it existed to catch would have been indistinguishable from a good swing. Set a guard
ABOVE anything legitimate, and assert in the tests that it never fires.

---

## Traps that have cost time more than once

**The reset → push → flush pattern will eventually be missing its flush, and it fails completely
silently.** Captain Run's enemy layers were never flushed, so `count` stayed 0 and every enemy was
invisible while still charging, still costing crew, still being killed. It read as a balance
problem and got a whole tuning pass. **If a render path has a count, assert that count against the
model.** A subsystem that renders nothing and a subsystem that does not exist look identical from
outside.

**A uniform that is declared and never supplied is not an error, a warning, or a visible
failure.** GLSL gives a missing sampler texture unit zero and a missing vector all zeroes, so
the shader compiles, runs, and silently ignores whatever depended on it. Coreward's shadow fan
was added to the shader source and to one material's hand-written uniform list but not to the
other's, so the terrain rendered with no shadows at all while the light in the tunnels had
them. **Half a feature working is the worst possible symptom**, because it reads as a tuning
problem and sends you off measuring lamp intensities.

Two rules from it: **pass uniforms by iterating one shared object, never by naming keys in more
than one place** - a loop cannot forget - and **test it by pulling the `uniform ... name;`
declarations out of the compiled shader and asserting the material supplies every one.**
`renderer.properties.get(material).uniforms` against
`gl.getShaderSource(program.fragmentShader)`. Nothing else can see it.

**A threshold about how dark something LOOKS belongs on the post-gamma value, not on the field
that feeds it.** Two of Coreward's lighting tests asserted on the raw light field, and both
failed the moment the gradient was retuned to exactly what a playtest had asked for. A test
that fails when the code becomes more correct is aimed at the wrong layer - and the fix is not
to loosen the number, it is to assert in the units the person looking at the screen was using.

**`Object3D.layers` does not stop a light from reaching an object.** Layers decide what a
CAMERA draws. three.js collects a scene's lights once and hands all of them to every lit
material - there is no per-object light filtering in the forward renderer. Coreward put its
ship on its own layer specifically so the world's lamp would not reach it, and the comment
saying so survived three versions while a point light of intensity 44 sat on the ship lighting
it. The hull rendered pure white however dark it was painted.

**Excluding a light from an object means a second render pass**: draw the world with the
camera's layers excluding the object, then draw the object alone with that light's intensity
set to zero and `autoClear` off so the depth buffer survives. It costs no extra draw calls -
the same objects are drawn either way. Set `renderer.info.autoReset = false` and reset by hand
at the top of the frame, or every draw-call budget test silently starts measuring only the last
pass.

**A metal gets its colour almost entirely from its environment map.** A high-metalness material
has essentially no diffuse term, so with a dark albedo the environment IS the visible
brightness - and a `CanvasTexture` used as one defaults to `NoColorSpace`, which decodes an
sRGB gradient about two and a half times too bright. The symptom is an object that will not
respond to being repainted. **If adjusting the obvious parameter changes nothing at all, stop
adjusting it: that is the signature of a constant term drowning the one you are moving, and the
next move is to measure, not to tune harder.**

**A material has exactly ONE `onBeforeCompile`, and assigning it is how you silently delete
somebody else's shader.** Coreward patches stock three shaders in three places — world-space
displacement, world-space map UVs, and the propagated light. Each one wrote
`m.onBeforeCompile = ...`, so applying two to the same material kept whichever went last and
threw the other away. Nothing fails. The material compiles, renders, and is simply missing an
effect. Route every injection through one `chainCompile(m, patch, tag)` that calls the previous
handler first and appends its tag to `customProgramCacheKey`, and the order stops mattering.

**And `Material.clone()` copies neither `onBeforeCompile` nor `customProgramCacheKey`.** A clone
comes back as stock three with every injection gone. Coreward clones exactly one material — the
block currently being drilled — so the symptom was one cell in the whole world lit differently
from the rock it was cut out of. Found by eye, which is the expensive way.

**The test that catches both reads the compiled shader back out of WebGL.**
`gl.getShaderSource(program.fragmentShader)` on everything in `renderer.info.programs`, asserting
the injected call is present in every program that carries the other injection. Asserting on the
material proves nothing — the material is fine; it is the compile that lost it.

**A chase camera behind the player, looking along +z, mirrors the x axis - and it will invert
your controls.** Putting the camera at a *lower* z than everything it looks at is a 180-degree
rotation about Y, so world +x projects to screen LEFT. Measured in Wick: world +2 lands at NDC
-0.31. Mapping a rightward drag to increasing x - the obvious thing - therefore moves the
avatar the wrong way.

Captain Run shipped with this for its entire life and nobody noticed, which is the part worth
remembering: **every test drove the steering seam in world coordinates, which is exactly the
layer the bug lives under.** A test that says "steer(1.5) put x at 1.5" passes happily on
inverted controls. The only thing that catches it is driving real pointer events and then
asking where the avatar *is in the frame*, in normalised device coordinates. Every game with a
chase camera needs that one test.

Either move the player along -z so the camera keeps its default orientation, or flip the sign
where the drag meets the world and comment it loudly. Do not "fix" it later by flipping
something else as well.

**Take the first option.** Wrecking Crew draws the street along -Z while the simulation
counts distance upward, through one `wz()` helper called everywhere, so the camera is never
turned around and screen right IS world +X by construction - no sign flip anywhere near the
input. A flipped sign is a fact that has to stay true through every future change to the
camera; an axis convention is one that cannot come apart. Keep the NDC test either way, and
**verify it by turning the camera around and watching it fail** - it should name the
consequence ("a rightward drag will move the rig the wrong way"), not the geometry.

**A raycast reads world matrices, and those are only refreshed by a render.** Tap something in the
same tick a 3D screen opens — before it has ever been drawn — and every object is still at the
identity matrix, so the ray misses everything and the tap silently does nothing. It starts working
the instant one frame has gone by, which means it reproduces on a fast tap and nowhere else. Call
`updateMatrixWorld(true)` at the top of the pick.

**A second scene does not inherit the first one's layer decisions.** Coreward's ship sits on its
own layer so the gameplay lamp cannot blow it out; moving it into the shop scene made it vanish,
because that scene's camera did not render the layer and its lights did not reach it. Anything
that reparents an object across scenes has to carry the layers, the lights and the background with
it — and a background especially, since a scene deliberately left transparent will show the wrong
thing through it somewhere else.

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

**A hazard outside the steerable band is not a hazard.** Wick's road mesh is 7.6 wide and the
thumb can only cross 5.0 of it; the first spawner placed blades across the full road width, so
some could never be hit *or* dodged - drawn, in the level, and unable to interact with the
player at all. Everything the player must reach or avoid goes through one `laneX` helper that
places inside the steering clamp, and a unit test asserts its range. Same failure as an
unreachable content band, same symptom: none.

**Check the hitbox against the band, not just against the object.** A blade's disc plus a grown
candle's own radius swept 1.29 of a 1.5-unit half-band, so a perfectly steered run lost about
as much as one that never touched the screen and steering was decoration. The test that keeps
it honest compares wax lost while dodging against wax lost standing still - a *measurement*,
because the thing that matters is an interaction between three numbers living in three files.

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
