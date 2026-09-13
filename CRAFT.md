# CRAFT.md - what makes a game good, learned by building eight of them

One rule per line, grouped by topic. **(M)** was measured on a real game, **(T)** is a tuned value
that survived play, **(L)** comes from the literature and is untested here, **(unplayed)** marks
Captain Run and Wick rules Gideon never played. Long write-ups are in `techniques/`; the original
2,406-line version is in `archive/CRAFT-2026-09-09.md`. Edited only by `/digest`.

---

## The rule this base keeps paying for

- **A rule written as advice about a convention prevents nothing. Write the test that fails, then
  point at the test instead of restating the advice.** Controls have shipped inverted in five
  games - Captain Run, Coreward, Wrecking Crew, Stillwater, Wildform - with the convention in this
  file the whole time, and the template was found steering inverted in the audit, making six.
- The tests live in `godot-template/test/` so a scaffolded game inherits them: `test_controls.gd`,
  `test_sim_boundary.gd` (the `src/sim` wall), `test_version.gd` (the three version strings).
- The repeating classes are each a test nobody wrote: a check that passes because nothing
  happened, "is this cell open" after the player is inside the material, a quantity computed
  twice, the instrument being the thing that is wrong. When a class repeats, the fix is a file in
  `test/`. `techniques/diagnosis-and-rework.md`.

## The loop and stakes

- Ask of any gathering or destruction loop: what happens if the player ignores it entirely? If
  nothing, the game has no stakes. Destruction became a game the moment it was the only way
  forward and the only thing scored (Wrecking Crew changed genre three times to find that).
- Ask what the player controls *continuously*. If the answer is "nothing", no amount of juice
  will make it feel like a game (Stillwater was "clunky" with a working sim and a film grade).
- Give the run-scoped resource and the persistent one different jobs; leftover run resource
  converts at the end so nothing is wasted. (unplayed) One resource that all converts to the same
  number is a difficulty slider in disguise, and three distinct resources is the ceiling for
  comprehension and the floor for a real decision.
- A secondary objective must be a thing you *keep* (a collection, a logbook, one relic per
  planet), never a number that will look small next week. Make the best reward missable. Rare
  surprises aimed at the current bottleneck stop routine work going stale - rare enough that they
  cannot be planned around, or they become a resource.
- A dominant strategy with no cost is not a mechanic. Ask what a wild version of the input
  costs; if nothing, add selectivity (targets worth different amounts, a cost, a cap). Thinning
  density makes it worse.
- Name the setting where a condition fires about half the time before building it; if none
  exists it is a wall wearing a decision's clothes.
- Interruption is a feature: let the player keep the partial progress of a stopped commitment.
- **In a run-based game with a hub, save only at the hub** so quitting mid-run costs exactly what
  dying costs, and both save-scumming abuses (the free ride home, quitting before a death)
  disappear with one rule instead of two (M). Add a checkpoint at a mid-run milestone rather than
  saving everywhere.
- **The best pressure is one the player CAUSES.** A pressure on a schedule happens whether or
  not the player acts, so it is not a decision; water that rises because you cut the rock makes
  over-digging a cost. Derive its number from the physical story (released water raises the level
  by the cell's water fraction, 15%), keep it derived not stored, and count against the ORIGINAL
  threshold or the flood feeds itself.
- **When a new objective ships, the old one is a stand-in and the round is not done until it is
  deleted.** Two objectives in one game is worse than either alone: the player collects components
  that now do nothing and the next session cannot tell which ending is real. Coreward's cost 1,300
  lines and ninety call sites across nineteen files, about two hours with the typechecker doing the
  finding. Budget it, and expect three things: **a derived stat quietly changes** (a drill formula
  lost its shards term, and the re-recorded golden matching the old `shards == 0` row exactly is what
  makes the removal safe rather than a silent rebalance), **a file turns out to be two features under
  one name** (deleting `transit.ts` took the title screen with it), and **a frozen golden keeps the
  dead ids in its allow-list for ever**, since an overwriter leaving a cell is as legal as one
  arriving.
- Build the meta-game early. A price next to an income is the first thing that shows the income
  is wrong; a hyper-inflationary curve (1.55x per level, M) makes any price list meaningless.
  Fix the curve upstream, not the prices.

## Progression and economy

- Gate an upgrade behind a *place*, not a price: the counter to a threat costs a material found
  inside the threat, and two gates on one thing means one is decoration. Depth, or any unfarmable
  record, is the cheapest structural gate. Show it.
- Show everything unlocked plus exactly one teaser, the shallowest thing still out of reach:
  at most one sealed row, never zero while something is gated.
- Drip-feed what is buyable rather than showing the whole shop: unlock a device by FINDING it,
  hint at what it does, then let it be upgraded. He has asked for this in two games.
- A weight or slot cap turns "which is worth more" into a decision. Consumables and permanent
  upgrades sit on different axes: small stacks, priced above the first upgrade rung.
- Quality is a *multiplier* on quantity, never an amount added, so both axes stay alive at every
  scale. Price spread on a premium resource under ~2x (M, bots). (unplayed)
- Three reasons to buy one upgrade beats three upgrades with one reason each. An upgrade you
  cannot see is bought on trust. Make it change the framing, the beam, the finder.
- Cap a visible resource at the number you can render; overflow converts to currency with a
  popup. (unplayed)
- Measure a progression by simulating play, bank, buy, next level, and reporting the level each
  thing is reached at. Dividing a late price by early income measures a player who never improved.
- When copying a reference, keep money in its units so its prices remain usable calibration: one
  scale constant, applied at one point.
- Contaminated-state bugs (the bank counted as earnings) need an invariance test: same level,
  different starting bank, same reward.
- **A thing can only be destroyed once, and the check belongs on the thing, not the shooter.**
  Any damage-over-time, aura, burn or chain effect is a SECOND caller into a payout path written
  for one: a burn ticking a broken crate brought a run home with 19,128 coins against ~340 (M).
  An invariance test cannot see it - assert the RATE, coins per crate broken.
- **Every prestige game needs one permanent rung with no top on it**, on a curve that rises
  forever, and its price step must be SMALLER than the difficulty step (1.30 < 1.35) or every
  world buys fewer ranks than the last. Play the meta loop far enough to find where the curve
  STOPS: eighty runs found a wall twenty did not (M).

## Difficulty and balance

- Split *frequency* from *severity*: how often the dangerous thing happens teaches it, how much
  it hurts punishes it. Tutorial is often and weak, endgame is rarer and strong.
- One knob that swamps the others is a design bug, not a tuning problem (Stillwater:
  win ~= 1.06 - 1.15 x run_chance, M). A new knob is a dial, not a cliff, with a ceiling asserted.
- **Write a table's balance property as an assertion in the same commit as the table**: no row
  dominates, every row is reachable, every entry costs something. A design test that has never
  failed is protecting something stable or is too loose to fire.
- **Store the quantity you mean and derive the thresholds at load.** A first-match-wins scan over
  `chance` fields is a CUMULATIVE threshold, and the first row tested keeps its whole number: the
  rarest ore was four times more common than the next down (2.10% against 0.50%, M). Print the
  derived rates. `techniques/human-bot-policies.md`.
- **The threshold an action unlocks at is not the level an alarm fires at.** Two facts sharing a
  value are two constants: the unlock from what the action should cost, the alarm from how much
  time the warning buys. An alarm on for most of a meter's working range trains the player to
  ignore it.
- **Measure the stretch the player actually reaches, not the whole content.** A mean of 1.55 m/s
  over a 200 m descent describes a run nobody has had; all four of Gravewell's faults sat in the
  first forty metres. Print the first ten seconds, per second, with the derived feel parameters
  beside the numbers.
- **When a request names a property the player should feel, check it is a VARIABLE in the data
  before tuning.** "Slowed down on denser materials" could not happen while hardness came from
  the depth band alone.
- **Any control raising a value against a decay has an equilibrium, and you own it whether or not
  you chose it.** `input_rate / decay_rate` inside the band the player must hold means one setting
  wins and the minigame is decoration (0.60, mid-band, M). Re-derive the EQUILIBRIUM when a
  control changes, and sweep the range.
- **When a design rule says "X is always accompanied by Y", one of them must CAUSE the other.**
  Two independent rolls make it hold only when they agree, and the exception's frequency is a
  number nobody chose. Test what is on the ground, not what the hash says.
- Give the player a risk dial they hold themselves, and test "the reckless option never actually
  works", not "the safe option scores higher". Doing nothing must lose; a wear clock (~46 s, T)
  makes caution a cost.
- A sudden event hits hardest at its start (a surge decaying over ~0.3 s) so reading the warning
  beats reacting to it - 96% to 54% landed (M). A tell longer than reaction time (~0.3 s, L)
  makes a mechanic free. Never let a hazard take the run: bound the worst case and test it.
- Everything dangerous lives inside the steerable band, routed through one lane helper. Write
  amplitude plus half-width plus tolerance against the steerable width before tuning frequency (a
  sweeper covered 61% of the lane at all times, M), and check a hitbox by measuring loss while
  dodging against standing still.
- A budget (swings, fuel) is derived from the content, never set as a rate over it, and asserted
  sufficient at every level.
- Any game with a wind-up, reload or lag must assert window > lag at the *top* of its speed ladder:
  five percent compounding per level quietly removed the game around level ten (M). Difficulty is
  usually the product of two fields, so assert the content table is a monotonic ladder in the order
  it is written, and remember every improvement to how hard a hit lands changes how long a level
  takes - rebalance both.
- Measure per item, never as one mean, against five or six procedural seeds: single-level numbers
  swing 25% on layout luck (M). Removing an obstacle kind removes its share of the danger, so do not
  backfill the slot.
- **The play-space boundary costs something the player can feel (speed, a rumble), never the
  resource the game is scored on.** Count boundary contacts per run with the bots before hazard
  contacts: an unplaced boundary hit 4-10 times a run in Snowball, more than any placed hazard,
  and became the real difficulty curve by accident.
- **When a binary control becomes proportional, re-measure balance in the quantity the new control
  moves** (strain, line given), not just land rates by band: the cost of ignoring a warning can
  migrate to a quantity that recovers between episodes, so land rates look fine while the risk
  model breaks underneath (Stillwater, M). Bots need modelled hand lag, not just decision lag, to
  represent human play.
## Feel

- Feel is layered and ordered: physicality (what moves), then amplification (juice), then
  support (invisible forgiveness). Polish on top of no first layer looks good in a screenshot and
  feels the same in the hand.
- Fire visual, audio, camera and haptic channels as one event; any one alone reads as cheap. For
  CONTINUOUS effort drive all four from one 0..1 load parameter in the sim, and make it a LOOP
  that is modulated rather than a one-shot retriggered per hit. Four channels agreeing is what
  makes effort read.
- **A 0..1 feel parameter normalised across a content table reads zero at the bottom of that
  table, which is where every player starts.** Give it a floor.
- **Anything that gates the player's motion on completing a discrete unit of work reads as
  chunky, however smooth each unit is** - he feels the period, not the shape of one step. Derive
  the verb's speed from the bill it pays, and make any floor a property the content table asserts
  rather than a clamp. `techniques/gravewell-continuous-digging.md`.
- Hit-stop is the highest value per line of code. Freeze the *presentation* for 35-80 ms (L)
  scaled to the event, never the simulation clock, so the golden stays valid. Keep the rest of
  the juice medium (L): a couple of degrees of shake decaying in about a third of a second.
- Movement on a cell timer reads as a spreadsheet; a velocity and a collision box was the largest
  single feel change in Coreward. Fly *along* the grid: free travel on the pushed axis,
  continuous pull onto the other's centre line. Assert momentum, acceleration, coast.
- Reach top speed in about a fifth of a second and coast under a cell (T); on a thumb, momentum
  reads as latency.
- Smooth with `1 - exp(-rate * dt)`, never `min(1, dt * rate)`. When converting, translate tuned
  constants to the equivalent per-frame fraction so feel does not move.
- A smoothing term is *assigned*, not added to an existing velocity, or it is an undamped spring
  ("bouncy").
- Apply corrections as a velocity through the normal collision path, never as a position write,
  or they are invisible to collision and to tests. Never correct while the player is coasting:
  snap on the next input.
- On a track with a direction of travel, a depenetration must never have a component against that
  direction: pushing an arithmetic (no physics body) avatar out along the contact normal wedged a
  Snowball reader against a lane edge for 200+ seconds. Resolve overlaps across the track only,
  and treat a bot that stops advancing while its inputs keep changing as a wedge, not a bug in it.
- High speed alone reads as fast-forward; a spline with ease in and out and a heading that
  follows velocity reads as piloted.
- Indirect control needs the lag set as a feel constant (~1 s for a thumb, T), the correct
  technique discoverable by accident, and the expert version reaching further. Approach a target
  *velocity* exponentially, never a target position, or the tool gets one kick and hangs.
- A saturating value is only a mechanic in the range it moves through: cap where it rarely
  reaches and measure how often the cap binds.
- Two motions sharing one variable will be shown doing each other's job (a rod that bends on the
  cast). Give each motion its own state.
- **When a motion feels odd, measure the per-frame change in its velocity at every state boundary
  before tuning anything.** Stillwater's cast release jumped from 54 deg/s to 361 deg/s in one
  frame; fix a step with ONE continuous state (a damped spring whose velocity persists across the
  boundary) plus an acceleration cap (a stiff spring's first frame is itself a step), rather than
  a fourth ease.
- An idle world reads as a screenshot. Float the vehicle on the same wave function the water
  shader uses, generated from one source so they cannot drift.

## Controls and touch

- The frame the control speaks in must match the frame the camera speaks in. A fixed camera with
  vehicle-relative input is tank controls, and the report is "almost feels backward".
- **Name the direction of travel as ONE constant** and derive the camera, the track, every
  placement and every facing from it. One place to be wrong instead of nine.
- Every game gets `test_controls.gd`: a real `InputEventScreenDrag` through the real handler
  asserting the avatar moves the right way ON SCREEN, plus the camera's right vector
  (`basis.x.x > 0.5`, which read -1.00 on Wildform). A suite made entirely of scripted policies
  tests only the simulation - no bot here holds a thumb. Assert the ART's forward, not the
  node's, normalised.
- A one-dimensional quantity gets a one-dimensional control (a slider, not a dial). Width is
  precision for free.
- Put the lagging thing on the control next to the thing being controlled, driven from the
  simulation's own state, so the player reads their aim without looking up. On-screen controls
  are absolute, not relative, or the picture stops saying where the machine is pointing.
- A readout glanced at can sit under the thumb. A readout watched continuously cannot. If they
  fight for space, change the verb (a tap has no position) rather than the layout.
- Indirect control needs a visible intermediary (the boom, not just the ball), and a part that
  shows the machine's facing from behind.
- One finger, three verbs, discriminated by movement not time: drag looks, still-hold charges,
  tap taps. A verb behind a gesture that already means something else is not a verb.
- The action button's caption is derived by the function that performs the action - and so is its
  whole identity. One button that becomes Cast over water and Select over the boat, grey when
  nothing is under the crosshair, beats two buttons for one verb.
- "It drifts" usually means the *path* curves (a throttle floor through a turn), not that the
  physics slide. Check the path before the integrator.
- A tracked vehicle is one constant from a car: an alignment cone outside which it only rotates,
  and a turn rate fast at rest and slow at speed.
- Lay out touch controls against the *real* viewport, never the project's base size, and test
  the hit region against the drawn control on a tall phone. Every control handles its own input
  so hit box and drawing are one object. `POLISH.md` gates the sizes.
- **Every menu is also drivable with up/down/left/right and a confirm**, selection highlighted and
  described, and closes on an explicit X. Asked three times in two days, for every room.

## Onboarding and the first minute

- The shallow part and the screens are what get played, so weight the effort there (`PLAYER.md`).
- HOME is the game with `advance` not being called, not a menu: the level you are about to play is
  already behind the cards, which makes "playable in ten seconds" a consequence of the structure
  rather than a target to hit. `POLISH.md` gates it.
- A forgiving tutorial must still charge *time* for ignoring a mechanic, or it trains the player
  to ignore it and the next area punishes the habit. A station whose lowest tier is a no-op
  teaches the player to stop reading signs: floor every station at its first real effect.
- A transformation big enough to divide a level into before and after is a wall that cannot be
  missed, not an optional station.
- Every state names a visible action, and pressing the one visible control always leads back to
  playing - a way out only the simulation knows about is not a way out. Finishing a level starts
  the next; running out restarts. This has shipped as a frozen HUD twice.

## Camera and light (rules here, arithmetic and evidence: `techniques/phone-camera-and-light.md`)

- Portrait's horizontal cone is tiny (58 deg vertical is ~28 horizontal; 46 is ~22). Compute visible
  width at the distance a thing sits, rack shops vertically, measure px per world unit at EVERY depth
  used (122 at a 7.6 m wall against 245 at a 0.5 m drawer, M), and project the BOX.
- A first-person camera carried by a moving object gets its own transform: ~0.9 of POSITION, 20-30%
  of ROTATION, damped at 0.5-1 s. **Peak angular RATE predicts discomfort and nobody looks at it.**
- **An object the player holds up to look at is part of the CAMERA rig, not of the world.** Parent
  it to the camera, and solve its distance from its own measured bounds and the camera's half-angle
  rather than picking a number: Stillwater's fixed held position was 56 degrees below a 37-degree
  half-angle, off the bottom of the frame in the one moment the game asks him to look at it, and one
  distance cannot frame a bluegill and a carp three times its length (`d = 2.57 * L`, 0.75-2.40 m).
- Name the end at risk before measuring a frame, and check framing at the size where it BREAKS. **A
  probe that disagrees with a picture you are looking at is measuring the wrong quantity, and the
  picture wins.** Solve a framing promise with one constant and a bisection, not two.
- Inverting a follow is a two-part edit and the second part is a deletion: every RELATIVE assertion
  passes while the pair drift sixteen metres out of the boat (M), so test an ABSOLUTE claim. Put no
  sign flip near the input, assert the convention in `test_controls.gd`, cull against the camera.
- **A lighting complaint is about a RATIO, so measure two places** (6:1 blacks out the way home,
  1.65:1 has no direction, M), and **any change that lifts the black floor publishes every defect
  the darkness was covering.** A fix that improves every scene equally is a dimmer switch: attribute
  an artefact to a *layer* first, and render the term to ALBEDO when the toggles run out.
- Light through a grid propagates through open cells, a lamp-centred falloff is a disc and a disc
  follows the player, surface and air light are two lights, and a shadow fan is smoothed by
  filtering the lit-or-not ANSWER across bearings rather than by more rays.
- Post-processing is the cheapest mood tool going, and it goes under the HUD (`POLISH.md` gates the
  stops).

## Visual legibility and art direction

- Do not invent a symbol for something you can show. A bar is right only when the quantity has no
  physical form.
- Silhouette carries more than colour, and a hazard must not resemble a reward. Separate play
  space from background by *lightness*, not hue, and test the gap.
- The most valuable thing on screen is the brightest. Every hazard in one colour family; variety
  goes in silhouette and behaviour.
- A cue that teases before it commits is a judgement; a cue that fires once is a reaction test.
  Draw the difference in two dimensions (depth and duration) and vary the count.
- A sphere reads as a bubble at any size; prisms with hard corners catch light on one face and
  not the next.
- When a change must be noticed from memory, change the amount (3x the sparks), not the shade:
  repainting a thirty-pixel drill per tier was invisible.
- Give each pressure its own channel. A number beats a bar when the player needs causation
  (`HULL -3.4/s`); put the gauge on the thing it eats without covering it.
- **Derive the picture and the score from one state: one function computes the quantity, one
  applies it, and a test asserts the applied equals the displayed.** A derived quantity is a pure
  function of state, not of when you ask - one reading a cached flag hands every caller outside
  the tick last frame's answer.
- Let damage reveal history (shaved layers). When the accurate model and the readable model
  disagree, build the readable one (bands, not shells).
- **A derived index lives in the module that OWNS the data, never in the one that asks the
  question.** A `Set` mirroring a saved list is a second source of truth: `load()` replaces the
  list wholesale, an index built in the frame loop never hears about it, and after a reload every
  new entry looked already-seen so nothing was ever written again. Export a `mark()` that writes
  both and a `reset()` that rebuilds, called from every path that replaces the list - load, wipe,
  new game. **When adding a field to a save, grep the RESET path, not just the load path**; the
  same sweep found a "wipe everything" that had never wiped three discovery lists.
- **One threshold for "gone", named once, and everything else reads that constant.** Two pieces
  of code that each decide when a thing is destroyed disagree eventually, and the disagreement is
  a band neither can see: passability at `<= 1e-4` against a drill breaking at `0.0` left cells
  flyable, unbroken and still reporting their ore forever. The fix is for the second to read the
  first one's constant. Second time in that one file.
- **Any "take the best of N" over frequently-uniform data is a hidden dependence on iteration
  order**, surfacing the first time the geometry hiding it changes. Weight-average instead, and
  make the case that must win outright an override, not a tie-break.
- **Destruction granularity has to match the rendering STYLE, and the ratio is the number.**
  Character width against cell width: ~18:1 Worms, ~32:1 Noita (continuous), ~1:1 SteamWorld Dig,
  ~0.5:1 Terraria (blocky on purpose). Gravewell at 0.76:1 drew smooth contours, promising Worms
  and delivering Dig Dug. A finer TICK cannot help; the limit is spatial.
- **Unexplored ground is ruled squares, not black.** A map painted only where the player has been
  reads as the map failing. A survey grid at the tile pitch, a depth rule every 50 m across the
  WHOLE world, and a surveyed percentage.
- A formation needs per-unit state and more than one unit wide to be readable. (unplayed)
- Make failure a *shape* (lean over a neighbour), not a number, with something visible to fail
  onto, painted lighter than it. A liquid is motion and answers (a scrolling surface, entry
  rings, a tool that follows), not a texture.
- A transformation is worth ten multipliers: the screenshot before and after a station must be
  obviously different pictures.
- A HUD is a claim about what the player should think about. The reference shows three things.
- A prop that occludes the thing the game is about is a bug. A chain of short boxes reads as
  debris; sweep one mesh along the path.
- "Unavailable" and "not a control" are two booleans; only refusal is grey. Enabled and disabled
  say it three ways (colour, text, value), and ordering matters: sealed beats affordable, maxed
  beats affordable, name the missing material before the money.
- "Cartoony" from him means under-lit and under-textured, not the model style: a normal map on the
  largest surface, a real light with falloff and a real sky do more than any model swap. That is
  the design reading; `POLISH.md` gates it and `PLAYER.md` holds his words.
## Audio and music

- Round-robin the players and jitter the pitch on repeats, or a restarted player cuts its own
  tail off. `ASSETS.md` decides sampled against generated; `techniques/generated-audio.md` has
  the arithmetic.
- A texture reads as ambience; only a rhythm reads as movement. What makes music happy rather
  than ambient is a tempo you can nod to: a cadence, movement eight times a bar, a soft kick. A
  written theme beats random notes - without repetition there is no phrase, and a fast attack on
  a high sine is a notification sound (his one outright dislike).
- A mood arc is a crossfade on a gameplay quantity, never a playlist; the layer that leaves does
  more than any that arrives. Assert monotonicity and a real span. Fade times should not match:
  places arrive slowly (~1.5 s), alarms snap in (~0.25 s) and leave lazily, routed past whatever
  is muffling everything else.
- **Haptics are a readout channel, not a garnish.** Two levels matched to two states, as he asked:
  a small pulse when the thing pulls, a sustained heavier one as it nears breaking.
## UI and HUD

- Where a readout sits matters more than how it looks. The top of the screen is where nobody
  looks; gauges go by the thumb, or opposite it if watched continuously, and must not move for
  unrelated reasons. On a portrait phone the left column is action buttons and the bottom is the
  d-pad, so **the largest clear area is upper-right**.
- A pressed control reads as pushed in, not lit up; give a needle mass, damped to what it shows.
  A HUD over a textured world needs its own material, grain felt not seen, and labels in a 3D
  scene are sized by the pixels they occupy.
- A shop the player is meant to be *in* is geometry, a room with the real object in it, not a
  panel and not a styled list. Hide the game entirely behind it, put the exit where a door would
  be. `techniques/coreward-shop-room-and-hud.md`.
- **A panel printed on a 3D surface is still a panel.** An object IS what it contains: the tackle
  box holds a small rod and a spool of line, not a list of their names.
- **A diegetic menu runs out of ANGLES before it runs out of ideas**, and a surface in the world
  has a reading distance you check with arithmetic. No two interactables within 12 degrees of the
  seat, hit box = whole silhouette (so long things are expensive), visible width
  `d * tan(fov/2) * aspect * 2` with a 0.46 aspect term in portrait.
  `techniques/stillwater-fishing-fight.md`.
- Give the game ONE `close_any_room()` and one `any_room_open()`. A check keeping its own list of
  what might be open goes stale the first time a room is added, and the failure lands six checks
  later looking like a missing button.
- **Anything that can reach the inventory must have an entry in the table the inventory looks
  things up in**, because the screen crashes rather than degrades. A new cut-stone block got a
  weight and a value but no `DEF` entry, so the manifest opened or did not depending on whether the
  player had cut through a wall since last looking. Both halves were covered and the join was not:
  **every fixture that cut stone never opened the manifest, and every fixture that opened the
  manifest never cut stone.** Assert it by sweeping the world for everything breakable into the hold
  and checking the lookup exists, not by naming the ids that caused it - the narrow version passes
  for the next block type somebody adds.
- A screen you invented is invisible to you: list what the reference does *not* have, and do not
  copy a monetisation mechanic into a game with no monetisation.
- Preferences are not progress. Settings get their own file, and "erase progress" next to the
  sound switches only holds if the two are separate.

## Level and world design

- Put the reward on the ground with extent, give the player a formation with lag, and let the
  geometry make the decision (weaving measured 2.6x over straight, M). The thing you protect
  trails along your path rather than clustering around you, so size costs agility, and obstacles
  must test every unit.
- Starting with one of the collectible instead of eight makes the first pickup the most valuable
  object in the game. Cap flat damage as a fraction of the batch.
- An obstacle anchored to the track edge guarantees its own gap; its hitbox derives from the
  drawing.
- A hazard that must punish the do-nothing line sits just past that line, never on it, so the
  open side is guaranteed by construction, and the reward for that stretch goes on the other side;
  the first such hazard comes after the first win (reader 3/6 centred, 6/6 past the line, M).
- For a ball small next to the field (0.5-1.0 m radius), put pickups in a line sorted small to
  large, never a scattered disc: a small avatar sweeps a narrow strip and gets about one contact
  per disc pass against six to ten per trail pass (M). Measure contacts per pass with a bot before
  placing growth thresholds.
- Attrition asks one question ("leave sooner"). A rhythmic announced event makes depth a bet (a
  tremor every ~27 s past 85 m, T). Announce a zone before charging for it, land several things
  on the same metre, and look for one hazard answering another before adding a third. A threshold
  the player cannot see is not a mechanic.
- Every content band must be reachable in both directions, and every row in a content table at
  all. The bluegill shipped uncatchable with every subsystem working.
- If the game names a thing, it exists as visible geometry within reach of its interaction point,
  and the anchor is placed from where the imported model's geometry sits, not from its node's
  position. Three interactables shipped as prompts pointing at empty air, and a logbook prompted
  over bare floorboards a metre away.
- **Authored mystery in a seeded world is hand-written room templates dropped at seeded slots.**
  Stamp after every one-of-a-kind cell and before everything that generates; drop a colliding room
  ENTIRELY rather than clipping it, because half a room is a wall with no room behind it. Keep a
  third empty, and never let a locked door lock the world. `techniques/coreward-authored-rooms.md`.
- **Anything permanently impassable that sits INSIDE the route to later content will block that
  content**, which is the "never let a locked door lock the world" rule applied to furniture rather
  than doors. Coreward buried nine objectives as single unbreakable cells across only three columns,
  and a cell that never breaks is a permanent plug in its column: **six of the nine became
  unreachable by digging to them**, and a long-play probe read it as a balance problem for four
  simulated hours. A "you cannot cheat your way to this" rule only needs to hold until the thing is
  CLAIMED - unbreakable while unclaimed, merely very hard (3x the local rock) after - because a
  claimed monument in the way is one the player may move. Write the test that drives the player to
  **each** instance in turn, never to one.
- **Once a mechanic puts the player INSIDE material, every "is this cell clear" test written
  before that mechanic is suspect.** Three Gravewell faults were this: a lamp buried in the rock
  it was cutting got no light, collision asked about whole metres and wedged the ship on slivers,
  and a drowning check asked whether the metre the ship occupied was open - precisely the metre it
  is still cutting.

## Diagnosis and rework (more: `techniques/diagnosis-and-rework.md`)

- A complaint that survives a **correct fix** is about something else. Stop tuning and measure:
  hide a layer, read a pixel, print the buffer. (Standing rule 8. One fix, not two.) **When the
  fix for one complaint reliably causes another, look for the missing degree of freedom** - two
  things that must differ are being driven by one value.
- **Put a rule where the file system can see it, write the test that reads it, then break the
  code five times to prove the test is awake.** A boundary in a comment is a request.
- Half a feature working is the worst symptom, because it reads as tuning: if the obvious
  parameter changes nothing, a constant term is drowning it. A rewrite beats revision when the
  fault is an inheritance (shape) rather than a decision.
- Set up the test scene where the bug CAN appear, and **when a verb changes which states the
  player spends time in, or which callers a path has, grep every system whose rules assumed the
  old distribution.**
