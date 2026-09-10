# Candle Gift: rebuilding a runner from reference footage

**Game:** Candle Gift (web / three.js, then rewritten on Godot) · **Status:** shipped and played; the Godot rewrite reached parity in one session · **Read when:** copying an existing game from screenshots and video; a trailing formation; stations, pools and pickups on a runway; setting par and star thresholds; an economy that has to match a reference

Candle Gift is a reproduction of a commercial candle runner Gideon's girlfriend remembered:
a trailing tray of candles is steered through pools of wax and past hazards, then appraised.
Two builds were made from a verbal description and were "still pretty far off"; the third
was built from two screenshots, one strategy-guide sentence and a four-minute walkthrough
video, and it is the method that got it there - not the code - that is worth keeping. This
file keeps that method (read the guide for the verbs; find the longest playthrough; magnify
the screenshots), the design of the tray and the pools (per-candle recipes, the formation
trailing along the recorded path, ROTATE as a wall), the economy calibration (money in the
reference's units, par from committed bots, the run-versus-bank invariance test), the pixel
versus model checks and the contact sheet, and the reasons the web version was rewritten.

**Generalisable takeaways**

- **Research is the asset.** Strategy guides describe what the player *does*; store pages
  list nouns. The longest playthrough video shows the screens a store never does - including
  the ones the reference does not have. Crop the reference at 4x before modelling from it,
  and keep the observed record as its own file so a rewrite is cheap.
- **If a system applies itself to everything you own, it is not a mechanic.** Put the resource
  on the ground, give the formation lag along its own path, give each unit its own state, and
  the geometry does the design. Measure a mechanic across a bad run and a good run; if the
  number does not move, it is scenery.
- **Calibrate with the bot anybody can re-run, over several seeds, in the reference's units,
  and test invariance rather than values.** A single-level par is layout luck; a price divided
  by early income measures a player who never got better; "the bank went up by what the screen
  said" is true with the bug present.

---

## Read the reference for the verbs

The line that turned the third build (from `PLAYTESTS.md`, 2026-09-07):

Third pass at this game, and the first two were both built on inference. Worth recording the
process failure as much as the fix: I had the reference's store copy and its strategy guide
from the first session and had extracted the *nouns* from them - stack, pools, glitter, bows -
without extracting the *verb*. The line that mattered was sitting in the guide the whole time:

"If there are two pools of wax side by side, you should swipe left and right quickly to try and
dunk all of your candles in both of the pools."

Wax is a pool on the GROUND. Which candles get which colour depends on where each one was as
the trailing stack snaked over it. So every candle needs its own recipe, and the player's line
IS the decision. The previous build treated the whole tray at once, which measured as identical
per-candle value across four play styles - the game had no input in it.

Lesson for next time a game is being reproduced: **read the guide for the verbs, not the
nouns.** A store page lists what is in a game; a strategy guide describes what the player is
doing, and that is the thing you are actually rebuilding.

**The most useful single sentence was in a strategy guide, not a store page:** "as your
candle stack gets longer, you need to be aware of everything happening in front of you, and
sometimes you need to start moving well before an obstacle is in reach". That is the trailing
stack, and it is what the whole rebuild is now built on. Store descriptions say what a game
contains; strategy guides say how it *feels* to play.

## Reference research: videos, absence, HUD, magnification

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

## The tray, the pools and per-candle recipes

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

**A formation is only readable if it is more than one unit wide.** The same tray in single
file showed the player one candle's worth of colour, because every candle hid behind the one
in front. Three abreast costs nothing, still trails identically - it is the *row* that
follows the path - and suddenly all the work the player did is on screen.

**Horizontal detail needs a low camera; vertical detail needs a high one.** Bands running
around a candle are only legible from the side, and the first pass looked down the runway
from above, saw the tops, and rendered a three-colour tray as one colour. The camera angle is
part of the art, not a framing preference.

### One backward walk for a trailing formation

(From `PIPELINE.md`.)

**Walking a path once per follower is quadratic, and it reads as a hang.** A trailing formation
where each member samples back along a recorded path costs (members x samples) a frame: thirty
followers walking ninety samples is 2,700 steps, invisible in a game playing one level and
ruinous in a suite playing twenty. A pure test suite went from about two seconds to over five
minutes, which looks like an infinite loop rather than like slow code. The distances are
monotonic, so **one backward walk can emit every follower as it crosses each threshold.**

## Stations, walls and transformations

**A station the player can pass through and get nothing from teaches them to stop reading the
signs.** Candle Gift's level-1 press stamped PLAIN onto plain candles and announced "ALREADY
PLAIN" - a gantry, a sign and a machine that was a dead beat until an upgrade several levels
later. Floor every station at its first *real* effect and let upgrades climb from there. The
same applies to any shop row, pickup or event whose lowest tier is a no-op.

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

**A liquid is made of motion and answers, not of texture.** Wax pools read as coloured carpet
until they (a) scrolled their surface, (b) spread a ring wherever something entered them, and
(c) had a ladle that slid across to stay above the thing being dipped. All three are a few
lines. The tempting fix - a photoreal water normal map - would have given the surface relief
and left it just as dead, and would have been the join that shows in the first frame. Worth
knowing before reaching for an asset: **ambientCG has no `water`, `liquid` or `ripple`
material at all**; the nearest hits are plaster and paint, which read as a rough wall.

## Hazards and obstacles

**A moving obstacle needs a provably reachable gap, computed rather than eyeballed.** Candle
Gift's sweeper is a bar that slides across the lane, and it shipped at its drawn half-width plus
the standard collision tolerance, swinging most of the steerable band: at every point in its
swing it covered 61% of the lane, so the scripted good player lost half its slab to it every
time. A static obstacle you can see is a decision; a moving one with no gap is a tax the player
cannot tell apart from bad luck. **Write down the worst-case clearance - swing amplitude plus
half-width plus tolerance against the steerable width - before tuning the frequency.**

**Every hazard in one colour family.** Candle Gift makes everything that costs you candles
coral - panel, spikes, sweeper - so "this hurts" is one thing the player learns once and then
reads at distance, in peripheral vision, at speed. Variety belongs in the silhouette and the
behaviour, not the palette.

**An obstacle anchored to the edge of the track guarantees its own gap.** The reference's
spiked roller stands on a post outside the rail and reaches part way across; there is always
somewhere to be. Deriving the collision box from that anchor - centre and half-width computed
from the side and the reach - also means the hit box cannot drift away from the drawing,
which is the usual way a fair obstacle becomes an unfair one.

**Separate the play space from the background by lightness, not by hue.** A themed level in
Candle Gift shipped as a pink runway under a pink sky - different hues, similar lightness -
and the track dissolved into the backdrop at about twenty units, which is exactly the
distance the player steers by. There is now a unit test asserting a minimum lightness gap
between every road and every sky it floats in, because "it looked fine in the editor" is a
description of a close-up.

## The run's end: camera, gauge, and the fan that should not have been copied

**A prop placed relative to where the player stops has to clear where the camera goes when they
stop.** Candle Gift's display table sat two units past the finish line, which was fine for the
whole run and wrong for the one shot that matters: the end-of-run camera swings forward past that
line to look back at the player object, so a six-metre slab ended up between the lens and the
thing being framed and the shot was mostly table corner. **Any end-of-run camera move is a second
placement pass over everything near the finish** - and moving the camera *behind* the object
rather than in front of it makes the scenery beyond the finish a backdrop instead of an
obstruction.

**A progress gauge needs headroom past its top rating, or it stops measuring at the moment it
matters.** Candle Gift's end-of-run gauge was scaled to 1.35x the par value while three stars is
awarded at 1.15x - so every three-star run pegged the bar, and a merely good result and a great
one were the same picture. The gauge exists to distinguish exactly those two. Scale full-height
to roughly 1.5-2x the top threshold and let the best plausible run sit around two thirds.

**Do not copy a monetisation mechanic into a game with no monetisation.** Candle Gift ends a
run on a five-wedge multiplier fan, and the fan is a rewarded-video gamble: you watch an advert
to spin it. Copied into a game with no adverts it became a wheel that always lands on the same
wedge - a wheel-shaped lie, and a screen that takes an extra tap to say what a line of text
already said. **Ask what a borrowed mechanic is *for* in the original before copying its
shape**; if the answer is "to sell an impression", the shape is not the part worth having.

## Draw calls on a runway

**Frustum culling will not save you from something dead ahead.** Twelve shop-front meshes 200
units down a narrow lane were inside the frustum for the whole middle of a level and cost
twelve draw calls where the peak is. One `visible =` line on the group gave them all back.
**Distance is not culling**; if a thing only matters for the last seconds of a run, switch it
off for the rest.

**Decorative meshes that are not instanced cost the same as the thing they decorate.** Three shop
fronts of seven meshes apiece took Candle Gift from 63 draw calls to 87 the moment they entered
the frustum, and the extra four per front were an outline hull and a `+` built from two crossed
boxes - both invisible at the distance they are ever seen from. Baking the `+` into a 64px canvas
texture and dropping the hull cost nothing visible and gave back twelve calls. **Count the meshes
in a decorative group before you place three of them; detail below a few pixels is pure cost.**

## Measuring the design with scripted play

**If a system applies itself, the player is not playing it.** Candle Gift's stations first
spanned the whole runway, so every tray got every treatment just by reaching the end - and
four scripted play styles, from never touching the screen to playing well, produced an
*identical* per-candle value. Everything downstream still worked; there was simply no input
in it. Splitting each station into two halves across the track, one effect each, turned a
fixed consequence into a chain of decisions. **Measure a mechanic across a bad run and a good
run: if the number does not move, the mechanic is scenery.**

Measure the spread before setting the thresholds (from `PIPELINE.md`):

- **Measure the spread before setting the thresholds, not after.** Star ratings and grades
  are cut against a par, and the *gaps* between them have to match the real distance between
  bad and good play. Candle Gift's first thresholds were bunched inside a 1.5x band while the
  measured spread across four scripted play styles was 1.3x, so every one of them scored full
  marks - including the run that never touched the screen. Script the extremes first, read
  the ratio, then place the thresholds inside it.
- **When every play style scores the same, fix the game, not the thresholds.** That flat
  spread was the real finding: it meant the systems were applying themselves. Re-tuning par
  would have hidden it.

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

## The economy: build the meta-game and find out what it does

A runner's economy can be wrong for a long time without looking wrong, because nothing in a
single run compares two numbers that ought to agree. Adding a shop is the first thing that
does: a price sits next to an income, and a price list that is trivially affordable is a
question mark over the income rather than over the prices.

Two bugs and one structural fault came out of asking "is this ladder priced sensibly", none of
which any test or screenshot had noticed:

**The bank was being counted as run earnings and paid back into itself.** The end-of-run
appraisal added the player's cash, and the player's cash had been seeded from the save. So a
run was appraised as (what you earned + what you already had), and that total was banked. A
balance of 5,000 became 141,699 in three runs of the same level.

**The obvious assertion cannot catch that, and it is worth understanding why.** "The bank went
up by the amount the reward screen said" is TRUE with the bug present, because both sides
inflate together: the screen says R + bank and the bank rises by R + bank. Any test written
from inside one run agrees with itself. The only shape that separates them is **playing the
same level twice with different starting conditions and demanding the same answer** - an
invariance test rather than a value test. Reach for one whenever a quantity might be
contaminated by state it should not see.

**And the value curve was hyperinflationary.** A run was worth 1.55x more per level - eighty
times over ten levels - so no fixed price list could mean anything. Even after repricing, the
whole ladder was bought out by level nine. The fix was upstream, in the curve, not in the
prices.

### Measure a progression by PLAYING it, not by dividing

The first version of the ladder table divided each price by the mean run value over the first
six levels and reported that the last shop took 75 runs. That number is meaningless: income
scales with the level, so a player who has reached the seventh rung earns many times the mean
of the first six. **Dividing a late price by early income measures a player who never got
better.**

Simulate the actual loop instead - play, bank, buy what is affordable, next level - and report
the level at which each thing is reached. That is the number the player experiences, and it is
the only one worth tuning against.

### Keep the money in the units of the game you are copying

Ours paid about 18,000 for a run where the reference paid about 540 - thirty-four times out.
That sounds cosmetic and is not. The only two prices ever observed in the reference were
$1,000 and $4,000, and against an 18,000 run those are not prices at all: the single most
useful piece of external calibration available was unusable until the units matched. It also
meant a money pill reading "148K" where the reference reads "540".

One constant, applied at one point, so everything downstream moves together and every number
stays comparable to the footage.

## The rewrite

Candle Gift ran to seven versions on the web stack and kept feeling wrong in ways that were
hard to name. The reason was structural: it had started life as a viking crowd-runner and been
reshaped twice, so its HUD, its upgrade screen, its obstacle set and its input model were all
answers to a different game's questions. Each pass fixed one of them and the next pass found
another.

**Rewriting it went faster than the last two revision passes did**, and the reason is worth
keeping: everything expensive to learn was already written down. `REFERENCE.md` - eight store
screenshots, two walkthrough videos with the timestamp of every finding, and the method for
pulling frames out of one - carried over unchanged, because it is research rather than code.
The new build reached parity in one session and passed the old one on structure immediately.

So the test for "rewrite or revise" is not how much code there is. It is **whether the thing
being fixed is a decision or an inheritance.** A decision can be revised. An inheritance keeps
coming back, because it is in the shape rather than in the lines.

And the thing that makes a rewrite cheap is having separated the research from the
implementation before you needed to. Write the observed record as its own file, in its own
words, with sources and timestamps - not as comments next to the code that acts on it.

## Checking the picture

(From `PIPELINE.md`; both were built for this game.)

### Test the PICTURE with pixels, test the PLACEMENT with the model

Both kinds of check are worth having and they are not interchangeable. Getting this backwards
cost three discarded metrics on one afternoon.

A wax pool rendering striped, and a station sign hung at the camera's eye height, were both
attacked first as frame statistics. Measured on a good build against a deliberately broken one:

| Metric | Good | Broken | Verdict |
|---|---|---|---|
| colour changes across a row | 45 | 49 | useless |
| saturated runs across five rows | 7 | 8 | useless |
| fraction of the upper frame still sky | 0.869 | 0.826 | too weak to threshold |
| **fraction of the lower frame near-black** | **0.028** | **0.196** | **kept** |

Both of the stubborn ones are GEOMETRY, and geometry is a number in the model: the pool's y
against the tops of the lane-stripe boxes, the distance from the lens to the nearest visible
gantry. In the model they are exact, they need no GPU, and the failure message names the number
and the object. In pixels they are a shade that also depends on marbling, on the time of the
frame, and on what happened to be on the ground where the band was sampled.

**What frame statistics are for is the whole picture going wrong at once** - everything one
colour, everything black, nothing drawn - which the model cannot see at all. That is a real
category: a build where every instanced object rendered as a solid black silhouette passed
every model assertion it had.

### Two rules for a pixel check that is worth running

**Measure first, then set the threshold, then break the build on purpose and watch it fail.**
A guard that does not move when the bug is present is worse than no guard - it is a green light
nobody has any reason to doubt. Give the runner a `--report` mode that prints the metrics and
asserts nothing, so the numbers can be re-derived rather than guessed at.

**Sample densely and judge the worst frame; a handful of chosen moments is not a sweep.** The
first version of this check sampled five seconds of a level and missed the exact bug it had
been written for, because a sign only fills the frame for about a second after you pass under
it. A frame costs milliseconds. Sample every second or two across the whole level. Transient is
precisely what a chosen-moment check cannot see, and in a runner transient is most of what is
wrong.

### State a guard in terms of what it is really about

The gantry check was first written as "no gantry is drawn behind the player", and it failed on
a deliberate one-metre grace that stops the gantry popping out as you cross it. That gantry is
still eleven metres from the camera and completely harmless. The rule is about distance from
the LENS, and once written that way it passes on every correct build and fails on the bug.

A guard phrased as the nearest convenient proxy will fail on correct changes, and a guard that
fails on correct changes gets deleted.

### Keep the pixel check local when CI has no GPU

Thresholds derived on one renderer do not transfer to another, and maintaining two sets of
numbers for one check is how a check stops meaning anything. Put it in a `check.sh` alongside
the headless suites and run that before committing, rather than pretending CI covers it.

### Screenshot a whole level as a contact sheet, not a second at a time

A single screenshot answers "does this moment look right" and costs an entire engine start, so
judging a level through one means guessing in advance which second to look at. Most of what is
wrong with a runner is only visible as a SEQUENCE: a prop that pops in, a sign that sweeps
through the middle of the frame, a pool that ends before the batch is out of it. None of that
can be seen in a frame chosen before you knew what was wrong.

One script that freezes, advances in fixed steps, and captures twelve frames across a level -
stitched into a grid - found four separate bugs in its first run that three individually
chosen screenshots had missed. Same seam as the tests (freeze, then advance), so cell *n* is
the same moment every time and two sheets a week apart are comparable.

### A candle on a white runway: fresnel rim instead of an inverted hull

The standard toon outline - the same mesh grown along its normals, drawn front-face-culled,
so only the sliver outside the silhouette survives - works on a `MeshInstance3D` and does not
work on a `MultiMeshInstance3D` in Godot 4.7. The hull draws OVER the object, so every
instanced thing in the game comes out as a solid black silhouette.

It was tried as a `next_pass`, as a second `MultiMeshInstance3D` sharing the same MultiMesh
resource, with `CULL_FRONT`, with `CULL_DISABLED`, with depth writing off, at both render
priorities, and **with the hull shrunk six centimetres INSIDE the object**. That last one is
the measurement that settles it: geometry entirely inside a solid object still drew over it,
so this is not a grow-direction problem or a draw-order problem, and no amount of tuning the
hull will fix it.

**A fresnel rim in the material does the same job for one dot product**, works on a MultiMesh,
and needs no second buffer to keep in step:

```glsl
float face = abs(dot(normalize(NORMAL), normalize(VIEW)));
float e = smoothstep(ink_width, ink_width * 0.35, face);
ALBEDO = mix(base, ink, e);
```

It is not identical - it cannot hold an even line width, and it darkens a flat face seen
edge-on, so anything thin and grazing (road stripes, decals) wants `ink_width = 0`. Write the
threshold so that **zero means no line**: expressed the other way round, as a smoothstep whose
two edges meet at zero width, it returns 1 everywhere and ink the entire surface.

Why it matters at all: a pale object on a pale ground has no edge without one. A cream candle
lying on a white runway rendered as a faint grey smear indistinguishable from a shadow, and
the batch - the thing the whole game is about - was the least legible object on screen.
