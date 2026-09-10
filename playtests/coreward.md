# Playtests — Coreward

Gideon's words, dated, verbatim. **Append only.** New entries go at the end under a `## YYYY-MM-DD` heading. Interpretation and lessons go in the topic files, not here.

---

Live at https://gideon6222.github.io/coreward/

Dig toward a planet core, sell ore at the surface pad, buy upgrades, break the core and the
planet explodes, launch to a harder planet. Fuel and heat are the two pressures pushing you up.

## 2026-09-06 — first run
"the game looks like it runs great"

Ran well on the S26 Ultra in Chrome, installed as a PWA. No performance complaints.

## 2026-09-06 — first real session, reached 75m

"I can afford upgrades pretty early on for fuel and cooling so neither is a risk."
Both pressure systems were defused before they applied pressure. Lesson: price the upgrade
that counters a threat against the depth where the threat actually begins, not against the
first haul.

"Right now it doesnt say it costs anything, so it feels free."
The Return button charged fuel but never showed the cost, so it read as a free teleport.
Lesson: an escape hatch with an invisible cost is the same as no cost.

His redesign, better than mine: no return button, running dry gets you towed home for a cut
of the haul, Tow Insurance reduces the cut, and Autopilot is a separate expensive unlock.

"It is difficult to judge the price of the different blocks you are mining."
Cargo counted units, so dirt and rubies took the same slot. Lesson: if the player cannot
compare two things on screen, the choice between them is not a real choice. Fixed with
weight-based cargo and a manifest showing count, weight and value per mineral.

"The ship should turn to face the direction it is digging in."

## 2026-09-06 — autopilot and music

"Instead of having the autopilot backtrack my path, can make it find the most efficient way
back? Also it looks like it is just fast forwarding."
Retracing the breadcrumb trail was both slower than necessary and, because it stepped
linearly from cell to cell at high speed, it read as a fast-forward rather than as flying.
Fixed with a breadth-first search for the shortest tunnel route and a Catmull-Rom spline with
ease-in and ease-out. Lesson: high speed alone does not read as motion. Curvature,
acceleration and a heading that follows the velocity are what make movement look piloted.

"The music has random higher pitch beeps that I dont like."
The score picked melody notes at random from a pentatonic scale. Musically valid, and it
still sounded like beeps. Lesson: randomness cannot substitute for melody. Without repetition
there is no phrase for the ear to latch onto, so isolated notes register as UI noise rather
than music. Also, a fast attack on a high sine is literally the shape of a notification
sound, which is exactly what he was hearing.

Fixed by writing an actual 32-beat theme in A minor over i - VI - III - VII, playing it only
every other cycle, giving every note a 0.3s attack and a long release, dropping it into a
register below where it gets shrill, and running it through a delay. The ambient bed was
thickened underneath with a continuous low drone and filtered air.

## 2026-09-06 — after the build-step migration

"I pulled it up on my phone and it has the correct version. I tested it and it runs well."

"It all looks good. It runs smoothly and I don't see any issues."

No gameplay feedback, and that is the entire point of recording it. The game moved from five
hand-written files to a Vite build, a generated service worker, TypeScript and sixteen
modules, and he had nothing to say about it. A migration that is invisible to the player is a
migration that worked.

Worth keeping in mind for the next one: nothing here is evidence that the *feel* is intact,
only that nothing obvious broke. Hit-stop, the camera lerps and the autopilot spline live in
the frame loop and were never covered by a test at any point. If a future refactor touches
that loop, ask him specifically about weight on a valuable strike and about whether the
autopilot still reads as flying, because those are the two things he has already complained
about once and would notice again.

## 2026-09-06 — heat soak, first pass

"I think it is good for now and will be a good mechanic when more gets added. right now it
doesnt seem very obvious that there is a distinct line. I think if we make it so that there
is a decent jump in materials and the visuals change to show there is a distinct difference,
that will help but I think future improvements will made this mechanic more obvious"

He was right twice in one paragraph, and the first half was a real bug rather than a
preference. The rock band changed at 60 m while heat started at 70 m, so the only marker of
the boundary was a number that never appears on screen. He could feel that the line existed
and could not find it, which is the correct read of a mechanic whose threshold is invisible.

Fixed by making four things land on the same metre: a new smouldering rock called scoria
starting at exactly the heat depth, the sky, fog, ambient light and dust all warming to
ember, the hull starting to drain, and the vignette building. There is now a test asserting
the rock boundary and the heat threshold stay equal, because they drifted apart silently
once already.

The second half is also worth keeping: he read the mechanic as scaffolding rather than as
finished, which it is. Heat is currently the only thing that punishes dwell time, so
"lingering is the gamble" has exactly one teeth. It gets interesting when there is more than
one reason to want to stay down.

## 2026-09-06 — after the fix

"I just tested it it on my phone through the app and it looks good."

No complaint about the balance, which is the part I was least sure of - the soak rates, the
0.72 shield cap and the reprice were derived from modelling, not from play. Treat that as
"nothing is obviously broken" rather than "the balance is right"; he has not yet played deep
enough on the new numbers to hit the wall where cooling becomes mandatory.

## 2026-09-07 — after the first overhaul, ten changes deep

"I tested it and it looked good."

Then, exploring rather than playing deep: he had not reached the new deep-game content at
all, and every note he wrote was about the first sixty metres. Worth remembering when
prioritising - the part of the game he actually spends time in is the shallow part.

Seven observations, and every one of them named a structural problem rather than a matter of
degree. Recorded in his words because the phrasing is the useful part:

"can you update the shop to look more like a separate upgrade screen, like an actual shop or
building? can you organize them and make it so certain things don't unlock until you make it
to a certain depth?"

"can you also make the light upgrade more important? I can see all of the blocks on screen,
so it doesnt seem very beneficial. If you make it so far away blocks are hard to tell what
they are without light upgrades, or start zoomed in a bit and each light upgrade zooms out,
that could be cool."
- He diagnosed it correctly AND proposed the fix. The Scanner only changed a lamp radius
  while the camera framed a fixed number of rows, so the frame was always inside the lit
  circle - no amount of tuning the radius could have helped. His zoom suggestion was the
  right shape.

"I like the sections of texture you added to the regular blocks. can you make it so most
regular dirt and rock give you a very small amount of resource, and those textured areas
give you more?"
- The single best suggestion of the batch. The flecks were decoration scattered by a seeded
  roll; generation now uses that same roll to decide which cells pay, so the texture and the
  payout agree by construction. He found a mechanic that was already drawn on screen.

"can you also make it so I can always dig but if the hull is full, just leave the resources
floating in place for me to pick up later"
- A full hold stopped the drill and showed a number, which is a wall that asks nothing of
  the player. Lesson recorded in CRAFT.

"can you add additional creative upgrades like a bomb that explodes a decent area, a laser
beam that destroys a straight line... they may work best as an ability that recharges over
time, or takes resources that you find while digging, or refill when you get back to the
surface"
- He specified the balance mechanism unprompted, and all three of his options turned out to
  be right together: one shared meter that trickles underground and refills at the pad.

"can you also think about a larger point to the game, or secondary objective?"
- Answered with relics. Still unplayed.

"is the memory limit something you have set or a build in standard for html or chrome?"
- Fair question after hearing about budgets repeatedly. Every budget in the repo is mine and
  is a drift detector; the only real platform limit in play is localStorage at ~5 MB, and
  the worst-case save is 12.5 KB. Recorded in the game's NOTES.md so it does not need
  answering twice.

## 2026-09-07 - still exploring, six more asks

"im still testing the new update but a couple changes I want to make."

Again all of it about the first sixty metres and the surface, and again every observation
named a structure rather than a degree. His words:

"can you make the ship feel more like it is free to fly not on a grid? still make it easy
and intuitive to control but don't keep it stuck on the grid."
- The single biggest change to how the game feels, and he named it in one sentence. The
  cell-to-cell hop was the thing making a good-looking world read like a spreadsheet.

"Blocks should stop being dug if you stop drilling but remember how much damage is already
done to them so they can be partially damaged, then easily finished off."
- He specified the whole mechanic including the part that makes it work. A commitment you
  cannot back out of is a wall rather than a decision.

"zoom the camera out slightly and make shadows and darkness denser. I want it hard to see
blocks that are far away and almost black toward the edge of the screen, so it feels like we
are only zoomed in vecause we can see any further out."
- The second half is the design note: the darkness has to JUSTIFY the framing. A tight frame
  on its own reads as a close camera; the same frame with the corners black reads as the
  limit of the light.

"can you also add a more intuitive version number and patch notes to the pause screen? so I
can see what version update we are actually on and what each iteration added."
- After several sessions the build stamp stopped being enough. Worth doing much earlier in
  the next game.

"can you make the shop an actually different screen instead of a pop up screen and make it
look more like a space station shop?"
- He had already been shown a restyled shop panel and still read it as a pop-up, which is
  the answer: leaving the world visible behind it is what makes it one.

"can you find where to get free assets for the game automatically and improve the ship, pad,
and anything else that could easily benefit from pre-made assets? I want you to research
were the best place to get them from and how to install them all on your end."
- Answered with a font (installed) and a reasoned no on the 3D models, plus a hand-rebuilt
  pad. He asked for research and installation, so the reasoning was given rather than the
  absence being left silent. The rule that came out of it is in CRAFT.

## 2026-09-07 - after lanes, the rock texture and the tick seam

"The ship looks very bouncy when you change direction or stop. Can you find a smoother way to
have it align with the grid, or not make it align until you change direction? I want it to ease
into a stop."
- Right again, and the proposed fix was again the correct one. Two faults, both introduced by the
  lane pull the session before: it was `+=` onto an existing velocity, so it overshot and rang;
  and it ran while COASTING, where the nearest lane is as often behind the ship as ahead, so
  releasing near a boundary dragged the ship backwards against its own momentum. Assigning instead
  of adding, and pulling only while a direction is held, is exactly "don't align until you change
  direction".
- Fixing it exposed a third fault that had been hiding behind it for three sessions: the drill
  alignment wrote position directly, aligned the axis of the cut rather than the one across it,
  and drove the ship *into* the rock it was drilling. The coasting pull had been ejecting it back
  out on release - so "bouncy" was partly a jerk out of the wall after every single block.

"is there a way for you to add some kind of log to see how fast certain things drain, if the cost
is worth the benefit, or if certain abilities don't really seem to be necessary? ... I would only
want to do it if it has very little impact on the game running and is actually helpful."
- He set both acceptance criteria himself, and the second is the harder one. A counter dump would
  have satisfied "a log" and answered nothing; what he asked for are three specific questions, so
  the panel reports rates and ratios against them and says "never used" out loud when an ability
  has not been fired. Cost measured at below the noise floor of the frame time.

"Can you also move the directional buttons up slight?"

Still nothing about the deep game. Four sessions now, every note about the first sixty metres and
the surface. The tick seam exists partly because of this: he is never going to playtest 90 m, so
that part has to be tested rather than played.

## 2026-09-08 - the art pass, and a question about budgets

"the game looks a little cartoonie. can you update the graphics to look more realistic and
detailed? make the dirt and rocks look more like realistic minerals, make the colors and textures
more gritty. change the ship to look less bubbly and cartoonish. since we can use pre-made assets
I want you to make use of them wherever you think it can help. can you also rearrange how the shop
is layed out? make it look like a full room where upgrades have a physical model associated with
it instead of a list of upgrades. make it so upgrades to the ship show visual changes."
- Five asks in one paragraph and every one of them structural again. "Cartoonie" was three
  separate things: no roughness channel anywhere (Lambert), a sphere for a cockpit, and a shop
  that was a list. None of them was the amount of detail.

"Are we still stuck to seventy draw calls? What is preventing that from being a higher possible
number"
- Nothing was: it was my number, from the "50 to 100 on mobile" rule of thumb. Measured properly
  it is 5.0 us per call and about 3,200 before missing 60 fps. He was right to push on it, and the
  guideline was wrong by more than an order of magnitude. Worth remembering that he asks this kind
  of question about numbers he is told, and that the numbers should be measured before he does.

"can you make it so that the upgrades that you get correlate with what we see in the actual game?
So, like, when you upgrade thrusters and starts to change the way they look, it also changes the
way that they look when you're actually playing the game."
- The right instinct, and it turned into the design of the whole shop: show the real ship and the
  real parts rather than a preview, so the two cannot disagree.

## 2026-09-08 — on lighting, three rounds

**2026-09-08, on lighting. Three rounds in one session, and every round moved it.**

"Can you make the lighting from the ship a much more obvious and integrated mechanic? Instead
of seeing a cone of light, I want the light look like it actually spreading from the ship.
When a tunnel is dug down or to the side, light should fill those tunnels and spread to nearby
rocks, but areas that are multiple rocks deep should be very dark. light should come from the
actual ship so if it hits a corner or branch, it should cast a shadow down that tunnel."

- The whole feature in one paragraph, and it named the technique without naming it: light that
  travels through the tunnels rather than through the rock is a flood fill over the grid. He
  also spotted, unprompted, that the volumetric cone was a fake standing where the real thing
  should be - it went in the same commit.
- The half I got wrong on the first pass: lighting the WALLS of a tunnel is not lighting the
  tunnel. A dug cell contains no geometry, so the space itself stayed dead until an additive
  quad put light in the air. He asked for both halves in one sentence and I heard one.

"that looks very close to what I want but a couple of issues. each block shows that angled
shadow. that should only show on actual branched off tunnels."

- A real bug, described precisely enough to find: shadow acne on every wall face, caused by
  recording where a ray leaves a cell instead of the cell's far corner. Thirteen per cent of
  every wall was in its own shadow. **He described the symptom in terms of what it should
  have been, which is what made it findable** - "only on actual branched off tunnels" is the
  invariant, not the complaint.

"rocks to the sides of the tunnel should be a bit brighter and gradually dim, so around 3
layers should be visible but start bright and dim quickly by the third. rocks any further than
that should be almost completely black."

- A tuning spec, in layers, with a curve. Straight into the constants. Worth noting he gave a
  NUMBER of layers rather than an adjective, which is the difference between a note you can
  act on and one you have to interpret.
- It also exposed two tests asserting on the raw light field rather than on what the shader
  displays - both failed the moment the gradient became what he asked for.

"the rocks still stick up past the fog in certain areas."

- Sounded like a depth-sorting problem and was not. The displacement shader pushes tunnel
  walls a fifth of a cell into the tunnel, and those bulges sat inside a lit shaft with no
  light on them. Fixed by letting the glow spill onto the wall, which is where it belonged.

"I think I am explaing what I want wrong. there should basically be two types of light. one
will be the light in the tunnels, which will disperse and spread through all of the connected
tunnels ... the second type of light I want is on the rock faces and separate from the tunnel
light."

- **He was not explaining it wrong.** He had been describing two lights since the first
  message; I had been building one. Every note about the shadow therefore read as a bug in the
  shadow rather than as a bug in WHERE the shadow was applied, and I fixed the shadow twice.
- The tell I missed: the same complaint came back after a fix that genuinely worked. **A note
  that survives a correct fix is a note about something else.** Three rounds of "still getting
  angled shadows on the blocks" were three rounds of him saying the shadow was on the wrong
  surface, and I heard three rounds of "the shadow is wrong".
- Worth adding to the pattern already recorded here: **when he restates a request from
  scratch rather than refining it, that is the signal that the model is wrong, not the
  tuning.** Stop adjusting numbers and go looking for the structure he is describing.

## 2026-09-08 - Coreward, the lighting rounds

Five rounds on one artefact. His words each time, in order:

> "it looks like the tunnel light is still showing in a circle around the ship and shows on the
> face of the rocks, making the sharp shadows not quite look right."

> "it looks like we are still getting the circle of tunnel light coming from the ship and it
> looks like it bleeds through the rock still."

> "that helped but we are still getting this overlapping rounded look. do you know what is
> causing this?"

> "it is still doing it but I think it will be hard to see from your tests since it only
> happens when approaching a branching path."

> "Did you see the areas I circled in my picture? The position of the ship won't cause the
> issue that you have it at currently. It only happens when approaching a branching path, not
> when you are at the actual branch. It only shows up when the shadow is cast as you are
> approaching the branch"

Then, after a fix that removed the symptom by turning the fog down:

> "it looks like it is happening worse now than it was and I liked the art style before better.
> I think I see the possible cause now. it looks like you are creating the shadows by sending
> out multiple cone shape beams to check of light should make it into the tunnel. since the
> light should be coming from one location it shouldn't be split into more than one beam like
> we see here."

- **He was right about the mechanism, and I was not.** Occluder distance was being recorded per
  whole block, so one point lamp quantised into a cone per block. I had spent four rounds
  reasoning about which shader term could make the shape.
- **"approaching a branch, not at the branch" was the actual diagnostic.** It ruled out
  everything that depends only on the ship's own position and pointed at the geometry between
  ship and branch. I kept setting up test scenes with the ship AT the junction, which is the one
  place the artefact cannot appear, and he had to say so twice.
- **"I liked the art style before better"** followed a change that removed the artefact by
  making everything dimmer. It removed the symptom everywhere, including where its supposed
  mechanism could not apply - which in hindsight is the tell for a dimmer switch rather than a
  fix. Once the real cause was fixed the brightness went straight back with nothing following it.
- What finally worked was hiding one layer and re-rendering: artefact gone, terrain lighting
  intact, four modules eliminated in one call. That should have been the first move, not the
  fifth.

Later the same day, three asks in one message - a visible beam through dusty air, a real dust
particle effect, and autopilot flying home nose-first instead of reversing. The autopilot one
was a sign error that had been shipping for weeks and that nobody had put into words before.

**Read the mechanism half of a report as seriously as the symptom half.** Twice now he has
supplied the cause and I have treated it as a description of the symptom.
