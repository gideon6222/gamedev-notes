# Candle Gift: rebuilding a runner from reference footage

> **Split on 2026-09-12** to get under the 30 KB limit, as the note at the top of this file had
> asked for. "Measuring the design with scripted play" and "The economy" moved together into
> `candle-gift-measuring-the-design.md`; "Read the reference for the verbs" and "Reference
> research" moved together into `candle-gift-copying-a-reference.md`. Nothing was trimmed -
> every measured number went with its section.

**Game:** Candle Gift (web / three.js, then rewritten on Godot) · **Status:** shipped and played; the Godot rewrite reached parity in one session · **Read when:** a formation that trails the player; stations, pools and pickups on a runway; hazards in one colour family; an end-of-run screen; draw calls on a long lane; a game that keeps inheriting a shape it never wanted

Candle Gift is a reproduction of a commercial candle runner Gideon's girlfriend remembered:
a trailing tray of candles is steered through pools of wax and past hazards, then appraised.
This file keeps the build itself - the design of the tray and the pools (per-candle recipes,
the formation trailing along the recorded path, ROTATE as a wall), the stations and hazards,
the end-of-run camera and gauge and the fan that should not have been copied, the draw-call
arithmetic on a runway, the pixel versus model checks and the contact sheet, and the reasons
the web version was rewritten. The two halves that stand on their own are elsewhere:
**`candle-gift-copying-a-reference.md`** for the research method (guide for the verbs, longest
playthrough, 4x crops) and **`candle-gift-measuring-the-design.md`** for the calibration (par
from committed bots over several seeds, money in reference units, the run-versus-bank
invariance test).

**Generalisable takeaways**

- **Make the thing you are protecting trail behind you, not cluster around you, and put the
  resource on the ground.** A crowd that follows exactly is all upside; a formation with lag
  along its own path makes growing it cost agility. Give each unit its own state and the
  geometry does the design - weaving measured 2.6x per candle over driving straight.
- **A formation is only legible if the camera and the width let it be.** Three abreast costs
  nothing and puts the player's work on screen; single file hides every candle behind the one in
  front, and horizontal detail needs a low camera while vertical detail needs a high one. The
  camera angle is part of the art, not a framing preference.
- **Ask what a borrowed mechanic is *for* in the original before copying its shape.** The
  end-of-run multiplier fan is a rewarded-video gamble; copied into a game with no adverts it is
  a wheel-shaped lie. The same test applies to a whole build: revise a decision, rewrite an
  inheritance.

---

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

(From `archive/PIPELINE-2026-09-09.md`.)

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

(From `archive/PIPELINE-2026-09-09.md`; both were built for this game.)

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
