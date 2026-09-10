# Stillwater: the fishing fight, its mood arc and its water

**Game:** Stillwater (Godot / native Android) · **Status:** shipped through milestone M1; four playtest rounds on the fight · **Read when:** designing a hold-the-needle or tension minigame; a difficulty table with one knob that swamps the rest; a mood that has to change over hours; water that facets or a depth texture you cannot read

Stillwater is a first-person rowboat fishing game whose depth is its story clock: it starts
calm at dawn and gets creepier the deeper the player fishes. The fight went through three
designs in one milestone - a threshold band, a pump rhythm, and tapping to hold a needle -
and each was called too easy, unintuitive or broken by the next playtest until the fight had
a rhythm, a wear clock, a surge that punishes late reactions, and a nibble that teases before
it takes. Alongside the fight this file keeps the finding that the species table had only
one real difficulty knob, the depth-driven music crossfade, the sky series for the day cycle,
the water shader (swell displaced, chop in the normal), the heightfield-instead-of-depth-
texture decision, and the post-processing that finally made the picture look unclean.

**Generalisable takeaways**

- **A threshold fight settles into one correct sustained input and is then over as a
  mechanic.** Gaining ground has to require a rhythm; doing nothing has to lose (a wear
  clock); a sudden event should hit hardest at its start so awareness beats reaction. Measure
  the landing rate per species, not as one mean.
- **Split frequency from severity, and check every derived quantity that shares a constant.**
  If "harder" and "runs more often" are the same number, the tutorial cannot teach the
  mechanic. Taps per second and where a run settles both depended on one decay constant; the
  test belongs on the derived quantity.
- **Drive mood off a number the game already has, and let absence do the work.** Four beds
  running the whole time, levels crossfaded on depth, with the cheerful layer leaving rather
  than a creepy one arriving. Assert the arc is monotonic *and* spans a real range.

---

## Threshold fights, rhythm, surge and the wear clock

**A "threshold fight" settles into ONE correct sustained input, and then it is over as a
mechanic.** Hold the needle inside the band, keep the bar under the fish, stay in the green -
the whole family has the same failure: once the player finds the position that works there is
nothing left to do but not move, and the game becomes a test of not fidgeting. It is the most
common shape in fishing minigames and it is why Stillwater's first fight was called too easy
within a minute of being played.

**The fix is to make gaining ground require a RHYTHM rather than a value.** Stillwater's second
fight gives line on a completed pump - a lift above a threshold followed by a drop below a lower
one - so holding any constant load, high, low, or perfect, gains exactly nothing. There is a
test asserting precisely that at six different held values, because it is the one property that
would silently revert the mechanic to the thing it replaced.

**Give the player a risk dial they hold themselves.** Line gained scales with how high the lift
went, and the line starts taking damage just above the most profitable pump. The greedy option
is genuinely better and genuinely near the edge, which is a decision on every single stroke
rather than a difficulty setting.

**A sudden event should hit hardest at its START, and that is what separates awareness from
reaction.** A run in Stillwater carries a surge multiplier that decays over the first third of
a second, so being a tenth of a second late costs several times what being late later does.
The effect is that a player who reads the warning and drops the rod BEFORE the run begins wins
by a margin nobody can close by reacting faster - which is the difference between a game about
watching and a game about twitching. Before it was added, more frequent runs only made fights
longer; afterwards the same fish went from a 96% landing rate to 54%.

**And doing nothing must lose, or the optimal strategy is to take all day.** Every forgiving
fishing minigame collapses to patience. Stillwater runs a wear clock for the whole fight that
ends it in about 46 seconds regardless of how carefully it is played, so caution is a real cost
and not a free hedge.

## The nibble: a cue that teases before it commits

**DO NOT INVENT A SYMBOL FOR SOMETHING YOU CAN SHOW.** Stillwater's first hooking minigame was a
marker sweeping a bar with a green zone: a perfectly good arcade mechanic, and completely
abstract. Gideon replaced it in one sentence - *"can you make the initial hook portion of the
mini game just watching the rod or bobber pull down. make it look like a fish is nibbling on the
bait"* - and he was right, because **a float being pulled under IS the timing cue.** Drawing a
second, invented representation of it above the horizon asks the player to learn a symbol for
something already in front of them, and the symbol is worse: it carries no fiction, teaches
nothing about the world, and has to be explained.

The test before adding any HUD element: *is there something in the world that already does
this?* A bar is right when the quantity has no physical form - tension in a line, a resource, a
timer. It is wrong the moment the game contains the thing itself.

**A cue that teases before it commits is a judgement; a cue that fires once is a reaction test.**
That is the whole difference between Animal Crossing's fishing and Stardew's or Zelda's, and it
is worth knowing which one you are building. The fish nibbles two or three times - shallow, brief
dips that pop straight back - and then takes the bait properly, deeper and held. Striking on a
tease loses it. The player is not being asked *how fast*, they are being asked *is this the one*,
which is a far better question and survives repetition much longer.

**Draw the difference in TWO dimensions, or the read fails.** A tease and a take differ in depth
AND duration - 0.34 against 1.0, 0.26 s against 0.4-0.85 s. Either alone is a knife-edge; both
together are obvious at a glance and stay obvious at distance, in motion, on a small screen.
There is a test asserting each gap independently, because a tuning pass that closes one of them
silently turns a judgement back into a coin flip.

**And vary the count, or the player stops looking.** A fixed number of teases is a metronome:
two bites and they are counting rather than watching, which defeats the entire mechanic while
appearing to work perfectly.

## One difficulty knob that swamps the others is a design bug, not a tuning problem

Stillwater's twenty-six species had three fight fields, and measuring them showed the whole
table fitted `win ~ 1.06 - 1.15 * run_chance`. Stamina and haul only set how LONG a fight
ran. So "harder" and "runs more often" were the same statement - and tuning the tutorial
water to be winnable therefore tuned the runs out of it. A player could finish the entire
first act without ever seeing the mechanic the fight is built on.

**Split frequency from severity.** How OFTEN the dangerous thing happens teaches it; how much
it HURTS punishes it, and they must be separate numbers. The tutorial then runs constantly at
a third of the strength, the endgame runs less often for much more, and difficulty rises
without the mechanic disappearing from the place it is supposed to be learned.

Two traps in doing it:

- **Check the new knob is a dial and not a cliff.** The first split scaled both the instant
  spike and the sustained pressure by the same factor, and every fish below 0.85 was landed
  every time while everything above it was a coin flip - the spike decided the fight in one
  frame and nothing after it mattered. Compressing the spike against the knob while leaving
  the sustained pull alone turned it into a gradient, and made the better mechanic besides:
  a strong enemy should mean "hold this off for the whole encounter", not "one instant
  decided it".
- **Give the knob an arithmetic ceiling and assert it.** Past some value the pressure parks
  the gauge outside the safe band on its own and no play survives - that is a coin flip
  wearing a skill mechanic's clothes. The bound is derivable (`SAFE_HI * decay / pull`), so
  it is a test, not a matter of taste.

## Constants that share a formula, and the difficulty product

**CONSTANTS THAT SHARE A FORMULA MOVE TOGETHER, and a test on the DERIVED quantity is what
catches it.** Stillwater's tap kick was halved on request, to make each tap a finer step. Taps
per second is `decay x tension / kick`, so halving the kick alone would have doubled the tapping
rate into a dexterity test - that much was foreseen, and the decay was halved with it. What was
not foreseen is that the same decay *also* sets where a fish's run settles, `run_pull / decay`,
so the change quietly moved a run's resting tension from below the safe band to the top of it and
made every run unsurvivable however it was played.

Two rules out of it. **Before changing a constant, grep for every formula it appears in** - it is
usually more than one, and the second one is the one that bites. And **put the test on the
derived quantity rather than on the constants**, because the derived quantity is what the player
feels: a test asserting "the band is holdable at a human tapping rate" and one asserting "a run
left alone settles below the band" both failed the instant the decay moved, and named exactly
what had gone.

**Difficulty is usually the PRODUCT of two fields, and neither one tells you where a thing
sits.** Raising the bluegill's run chance while leaving its "busyness" high made the *tutorial*
fish harder than the one after it - 79% landed against the perch's 88%. Nothing in either field
looked wrong on its own. There is now a test asserting the species table is a monotonic ladder
in the order it is written, because a content table that is supposed to be ordered should say
so out loud.

**Measure per item, not as one mean.** The aggregate said "the human loses 24%", which hid that
the first fish was a 92% win and the prize fish was 54%. One mean over a difficulty ladder
describes none of its rungs.

## The gauge, the thumb, and the verb

**But a readout that must be watched CONTINUOUSLY cannot live under the thumb that operates
it** - and that limit is what decides whether the rule above applies at all. Stillwater's first
fight put a tension meter on a control on the right-hand side, exactly the Wrecking Crew
arrangement, and Gideon's note was "I don't like that my thumb will be blocking the gauge I am
looking at". The dial got away with it because you GLANCE at a dial between decisions; a
tension meter is read every frame, and a hand rests on it the whole time.

So the test before combining a control with its readout is **how often is it read**, not how
well the two go together:

- **Glanced at** - combine them. The dial is right and stays right.
- **Watched continuously** - separate them. Put the readout at one end of the screen and the
  input at the other.

**SEPARATE means separate, not DELETE - and the next note said so.** Stillwater's answer to the
thumb-on-the-meter complaint was to remove the meter entirely and let the rod's bend be the only
instrument. The following playtest: *"it is not very intuitive to tell what you are supposed to
do... I think having visual on screen queues or gauges would be a good addition."* Both notes
were right, and the second one says the first fix over-shot. **The answer to a gauge in the
wrong place is to move the gauge.** Deleting a readout removes the fault and the function
together, and "the world is the instrument" is a lovely idea that still has to be legible to
somebody who has played for ninety seconds.

**What actually resolves it is choosing an input with no position.** Gauges at the top and a
TAP anywhere is only possible because a tap carries no positional information - so the thing you
look at and the thing you touch can sit at opposite ends of the screen with nothing to
negotiate. A drag or a stick forces them back together, because a drag needs somewhere to be.
**If a readout and a control are fighting over the same space, change the verb rather than the
layout.**

**When an instrument is the only one you have, it has to deform, not just move.** A rod drawn as
a single stick rotated by the load barely changes silhouette - 40% and 60% look the same when a
straight line tilts. Five chained segments, each taking a share of the angle weighted toward the
tip, reads as a rod under strain at a glance. Weight the shares unevenly, or an even share bends
it into a circular arc and it reads as a bow.

**And keep separate motions in separate code.** The same rod both SWINGS (a cast: the whole thing
rotates back, then forward, staying straight) and BENDS (a fish: it curves forward under load).
One variable drove both, so loading a cast curved the rod as though something were already on
the line - "the rod bends back then flicks forward which isnt how it should work". Two physical
motions that share a number will eventually be shown doing each other's job.

## The way out the renderer never called

**A WAY OUT THAT ONLY THE SIMULATION KNOWS ABOUT IS NOT A WAY OUT.** The pure-core rule has a
matching failure mode and this is it: Stillwater's `reel_in()` — the escape from a cast with no
bite — existed, had a test, and passed for three builds, and **nothing in the renderer ever
called it.** The player was left with a lure in the water, no fish, and no route back to the
boat: "i cant recast or anything".

The test was asserting about an API rather than about the game. **Every "there is always a way
out" test has to drive the call the INPUT HANDLER makes**, not the method that exists to serve
it — which for a phone game means the tap or drag seam, exercised through the real scene. A
public method with no caller is the same thing as a missing feature, and it is harder to see
because the coverage looks complete.

Stillwater could always reel in - tapping during a wait called `reel_in` - and
the playtest report was "there is not option to pull the line back in or
recast". Nothing on screen said so, and that same tap set the hook during a
nibble. **A verb hidden behind a gesture that already means something else is not
a verb the player has.**

The fix is an action button whose caption is DERIVED from the state by the same
function that performs it, so the label and the behaviour are one decision. Two
places computing that is a button that lies the first time a state is added.

## Feel underneath the fight

Two items from the "feel is layered" essay that were specific to this game:

- **An idle world reads as a screenshot.** Floating the boat on the same wave
  function the water shader uses was the single biggest change - and generating
  the shader's GLSL from one GDScript array is what stops the two drifting. Two
  copies of a wave definition means a boat rocking slightly out of time with its
  own water, which reads as broken in a way nobody can name.
- **One finger, three verbs, discriminated by MOVEMENT not time.** Drag looks,
  still-hold charges, tap taps. Time cannot work when one of the verbs is itself
  a long press.

## The mood arc: a crossfade on depth

**A MOOD ARC IS A CROSSFADE ON A GAMEPLAY QUANTITY, NEVER A PLAYLIST.** Stillwater is meant
to go from pleasant to unpleasant over hours. The version that works runs four beds
continuously from the first second to the last - all one key, all one loop length - and
changes only their levels. A game that switches to Creepy Track 2 at forty metres has told
the player it is trying to frighten them, and being told is the end of it.

Two things make it work, and both are worth copying:

- **Drive it off a number the game already has**, not a story flag or an act counter.
  Stillwater uses DEPTH, which is what the whole game is about. The immediate reward is that
  the arc runs BACKWARDS for free: go and fish the shallows after the deep water and the
  cheerful layer comes back, and discovering it still exists is a stranger feeling than
  losing it was. No flag-based system gives you that, because a flag only counts forwards.
- **The layer that LEAVES does more work than any layer that arrives.** The bells are most of
  the first hour and gone by the halfway point, and nothing replaces them. An absence is the
  loudest thing you can put in a score, and it costs no assets.

**Assert the arc.** "The music changes" is a design claim, and a mix built by ear satisfies it
on the day and silently stops satisfying it the next time a level is nudged - a soundtrack
that quietly stopped changing is an inaudible regression. Drive the mixer at the depths the
game actually produces and assert monotonicity AND a real span at each end; monotonic alone
passes for an arc that moves half a decibel.

## The sky: a series from one location

(From `ASSETS.md`.)

### For a game with a day cycle, take a SERIES from one location

Poly Haven's `qwantani_*` set is dawn / morning / afternoon / dusk / night from
one spot, all `puresky`. Because the cloud structure is consistent between them
they crossfade cleanly, which a set assembled from five different locations does
not.

Two things worth knowing:

- **`puresky` variants are sky only** - no terrain, no horizon clutter. Essential
  wherever the horizon is water, because anything baked into the lower half of
  the panorama gets reflected in it. The first attempt used a non-puresky dawn
  and put African savanna hills across a drowned English valley.
- **A panorama is one fixed photograph.** If the game's look is a continuous
  curve - time of day, weather, depth - `PanoramaSkyMaterial` fights it, because
  swapping panoramas at each step is exactly the hard cut the curve exists to
  avoid. A ~20-line `shader_type sky` that samples TWO panoramas and crossfades
  them, then applies the same tint and darkening everything else gets, keeps both.
  Multiply a separate cloud panorama in for weather rather than blending toward
  it, so a storm at dusk stays lit dusk-coloured.

## The picture: sun, fog, boat

**Put the sun AHEAD of the camera for anything wet.** A specular streak is the path sun →
surface → eye, so a sun behind the player lights the water perfectly and it throws nothing back:
Stillwater's lake rendered as wet concrete for two builds with a correctly configured light.
Turning the sun to the far side of the water was the single change that made it read as a lake,
and it is worth checking before touching a roughness value.

**Depth fog repaints the sky, because the sky is at infinity.** Godot's `fog_sky_affect` defaults
to 1.0, so a fog that looks right on the water covers the entire sky in the fog colour - and a
flat cream wall where a dawn gradient should be reads as a *missing skybox*, which sends you into
the sky material hunting a fault that is not there. Drop it to about 0.2. The general form: **any
effect applied "by distance" hits the background hardest, so check the background first when
tuning one.**

**A prop that occludes the thing the game is about is a bug, not a look.** A bow block on
Stillwater's rowboat sat exactly in front of the float at a short cast - hiding the one object the
player watches for the whole cast. Easy to miss, because a screenshot at any other moment shows it
standing harmlessly in open water.

**Draw a first-person vehicle as an EDGE, not as a surface.** Two builds put a solid hull under a
camera sitting in it, and its lit top face became the brightest object on screen and a third of a
portrait frame - a picture of a plank. What a person in a boat actually sees is the gunwale running
away on both sides and converging ahead, with water between. Three thin meshes, the same read, and
it *frames* the subject instead of covering it. Seat the camera at seated height too: 1.78 m is a
person standing up in a rowboat, and it puts every part of the boat too far below to read.

## Vertex-displaced water: displace the swell, normal-map the chop

Stillwater's lake facets badly the first time it has enough specular to show it,
and the diagnosis took four attempts. Everything here is general.

- **A wave shorter than about four times the quad size cannot be represented.**
  Two samples per wavelength is the theoretical floor and it looks terrible; the
  1.55 m and 0.85 m waves on a 1.17 m quad aliased into flat plates. Displace only
  the long swells and move the short chop to a fragment-shader normal, which is
  where it belongs anyway - the eye reads the normal far more than the geometry.
- **Value noise sits on an axis-aligned integer lattice**, and stacking octaves
  that share it leaves the grid visible as rectangular plates at a grazing view.
  Rotate each octave by an irrational-ish angle so the lattices never realign.
- **Ripples are centimetres.** A base octave at 1.7 cycles/metre is a 59 cm cell,
  and one of those covers a third of the screen from a camera a metre above the
  water. 6.5 and up.
- **A fade added to hide one artefact will expose another.** A near-field fade
  meant to hide the lattice switched the fine normal off over exactly the water
  where the mesh quads are largest on screen, leaving the bare facets showing. The
  fine detail is what BREAKS UP the facets, so it has to run right to the camera.

And the general one: **a chain of short boxes rotated to follow a curve reads as
floating debris** - every joint leaves a gap and every end cap catches the light
on its own. Anything long and curved wants a swept mesh: one function that takes
a path and a cross-section pays for itself the second time (a boat hull and a
reed, here).

## Depth from the heightfield, not from `DEPTH_TEXTURE`

(From `PIPELINE.md`.)

Found while designing the water for a fishing game, before writing any of it. **Sampling the
depth texture on Forward Mobile with MSAA enabled returns corrupted data** — the MSAA resolve
is missing before the texture is bound. That matters because the standard recipe for water,
shore foam, soft particles and any depth-based fade is exactly this sample, and it is what
every tutorial reaches for.

The workaround is to turn MSAA off. **Do not take it.** The better answer is to notice that in
these games the renderer is being asked a question the simulation already knows the answer to:
the lake bed is a heightfield the sim authors and owns, because it decides where the fish are
and whether you snag. Upload that same field as a small texture, sample it in the shader by
**world position**, and the depth is exact, cheap, and *identical to the number the rules use*.

Three things fall out, and they are the reason this is a rule and not a workaround:

- **The picture cannot disagree with the game.** Foam is drawn where the sim says the bed is.
  Same guarantee as showing the real ship in the shop instead of a copy of it.
- **It is testable headlessly.** A depth-buffer read is invisible to a headless run; a
  heightfield lookup is arithmetic and goes straight into the golden.
- **MSAA stays on**, so thin geometry — line, reeds, rigging — stops shimmering.

Generalised: **when a shader wants to know something about the world, check whether the
simulation already owns it before asking the renderer.** Sampling the frame buffer to recover
a fact the game computed three milliseconds earlier is a second source of truth, and it is the
one that breaks on a specific renderer with no error message.

## Post-processing is the cheapest mood tool there is, and the last one reached for

Stillwater had correct geometry, a real sky, a tuned palette and a light rig that
all did their jobs, and the picture still looked CLEAN - which was the one thing
that game must not look. A vignette, animated grain and a touch of radial
chromatic aberration, all rising with the same progress number the rest of the
arc uses, did more for the mood than any of the modelling.

Four details that matter:

- **Put it UNDER the HUD**, on a lower CanvasLayer. Grain over a price list reads
  as a broken display, and the text has to stay legible at arm's length.
- **Animate the grain.** Static grain is dirt on the lens.
- **Weight it to the mid-tones.** Real film has none in the highlights and little
  in the blacks, where it is just noise.
- **Lift the blacks toward the scene's own colour**, not toward grey. A true black
  on an OLED phone is a hole, and a hole reads as the screen being off.
