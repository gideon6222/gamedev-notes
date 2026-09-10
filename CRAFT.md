# CRAFT.md - what makes a game good, learned by building six of them

One rule per line, grouped by topic. Numbers marked **(M)** were measured on a real game,
**(T)** are tuned values that survived play, **(L)** come from the literature and have not
been tested here. Rules from Captain Run and Wick were never playtested by Gideon (both games
were redirected before he played them) and are marked **(unplayed)**. Long write-ups live in
`techniques/`; this file is the distilled version and is edited only by `/digest`.

The original 2,258-line version of this file is in `archive/` and in git history. Read it
only when a bullet here is not enough.

---

## The loop and stakes

- Ask of any gathering or destruction loop: what happens if the player ignores it entirely?
  If nothing, the game has no stakes. Destruction became a game the moment it was the only
  way forward and the only thing scored (Wrecking Crew changed genre three times to find that).
- Ask what the player controls *continuously*. If the answer is "nothing", no amount of juice
  will make it feel like a game (Stillwater was "clunky" with a working sim and a film grade).
- Give the run-scoped resource and the persistent one different jobs. Leftover run resource
  converts at the end so nothing is wasted. (unplayed)
- One resource that all converts to the same number is a difficulty slider in a resource
  system's clothes. Three distinct resources is about the ceiling for comprehension and the
  floor for a real decision.
- A secondary objective must be a thing you *keep* (a collection, a logbook, one relic per
  planet), never a number that will look small next week. Make the best reward missable.
- Rare surprises aimed at the current bottleneck stop routine work going stale. Rare enough
  that they cannot be planned around, or they become a resource.
- A dominant strategy with no cost is not a mechanic. Ask what a wild version of the input
  costs. If nothing, add selectivity: targets worth different amounts, a cost per action, a
  cap. Thinning density makes it worse.
- Name the setting where a condition fires about half the time before building it. If none
  exists it is a wall wearing a decision's clothes.
- Interruption is a feature: let the player stop a commitment and keep the partial progress.
- Build the meta-game early. A price next to an income is the first thing that shows the
  income is wrong, and a hyper-inflationary value curve (1.55x per level, M) makes any price
  list meaningless. Fix the curve upstream, not the prices.

## Progression and economy

- Gate an upgrade behind a *place*, not a price: the counter to a threat costs a material
  found inside the threat. Two gates on one thing means one is decoration. Assert the gating
  material lives near the unlock depth.
- Depth, or any unfarmable record, is the cheapest structural gate. Show it.
- Show everything unlocked plus exactly one teaser, the shallowest thing still out of reach.
  Assert at most one sealed row and never zero while something is gated. A rule about how
  much to show is a ratio and silently expires when the content count doubles.
- A weight or slot cap is what turns "which is worth more" into a decision.
- Consumables and permanent upgrades sit on different axes. Small stacks, priced above the
  first upgrade rung.
- Quality is a *multiplier* on quantity, never an amount added, so both axes stay alive at
  every scale. Keep the price spread on a premium resource under about 2x (M, bots) or
  material value swamps every design bonus. (unplayed)
- Three reasons to buy one upgrade beats three upgrades with one reason each. An upgrade
  you cannot see is bought on trust. Make it change the framing, the beam, the finder.
- Cap a visible resource at the number you can render. Overflow converts to currency with a
  visible popup. (unplayed)
- Measure a progression by simulating play, bank, buy, next level, and reporting the level
  each thing is reached at. Dividing a late price by early income measures a player who
  never got better.
- When copying a reference, keep money in its units so its prices remain usable calibration.
  One scale constant, applied at one point.
- Contaminated-state bugs (the bank counted as earnings) need an invariance test: same
  level, different starting bank, same reward.

## Difficulty and balance

- Split *frequency* from *severity*. How often the dangerous thing happens teaches it, how
  much it hurts punishes it. Tutorial is often and weak, endgame is rarer and strong.
- One knob that swamps the others is a design bug, not a tuning problem (Stillwater:
  win ~= 1.06 - 1.15 x run_chance, M). A new knob must be a dial, not a cliff. Give it an
  arithmetic ceiling and assert it.
- A "hold the needle in the band" fight collapses to one sustained input. Make gaining
  ground require a rhythm and assert that holding any constant value gains nothing.
- Give the player a risk dial they hold themselves. The greedy option is genuinely better
  and genuinely near the edge. The claim to test is "the reckless option never actually
  works", not "the safe option scores higher".
- Doing nothing must lose. A wear clock (~46 s, T) makes caution a cost.
- A sudden event hits hardest at its start (a surge decaying over ~0.3 s) so reading the
  warning beats reacting to it. That took a fish from 96% to 54% landed (M).
- A tell longer than human reaction time (~0.3 s, L) makes a mechanic free.
- Never let a hazard take the run. Bound the worst case (re-run the pathfinder after a
  collapse, revert if home is unreachable) and test the bound.
- A moving obstacle needs a provably reachable gap. Write amplitude plus half-width plus
  tolerance against the steerable width before tuning frequency (Candle Gift's sweeper
  covered 61% of the lane at every moment, M).
- A hazard outside the steerable band is not a hazard. Route all placement through one lane
  helper and test its range. Check the hitbox against the band by measuring loss while
  dodging against standing still. (unplayed)
- A budget (swings, fuel) is derived from the content, never set as a rate over it, and
  asserted sufficient at every level.
- Any game with a wind-up, reload or lag must assert window > lag at the *top* of its speed
  ladder. Five percent compounding per level quietly removed the game around level ten (M).
- Every improvement to how hard a hit lands changes how long a level takes. Rebalance both.
- Difficulty is usually the product of two fields. Assert the content table is a monotonic
  ladder in the order it is written.
- Measure per item, never as one mean. Calibrate against five or six procedural seeds, never
  one. Single-level numbers swing 25% on layout luck (M).
- Removing an obstacle kind removes its share of the danger. Do not backfill the slot, and
  re-measure the system that competes for the same seconds.
- Measure the spread across scripted play styles before setting thresholds. When every style
  scores the same, fix the game, not the thresholds. That flat spread IS the finding.

## Feel

- Feel is layered and ordered: physicality (what moves) then amplification (juice) then
  support (invisible forgiveness). Polish on top of no first layer looks good in a screenshot
  and feels the same in the hand.
- Fire visual, audio, camera and haptic channels as one event. Any one alone reads as cheap.
- Hit-stop is the highest value per line of code. Freeze the *presentation* for 35-80 ms (L)
  scaled to the event, never the simulation clock, so the golden stays valid.
- Keep juice medium (L): a couple of degrees of shake decaying in about a third of a second.
- Movement on a cell timer reads as a spreadsheet. A velocity and a collision box was the
  largest single feel change in Coreward. Fly *along* the grid: free travel on the pushed
  axis, continuous pull onto the centre line of the other. Assert momentum, acceleration and
  coast distance.
- Reach top speed in about a fifth of a second and coast under a cell (T). On a thumb,
  momentum reads as latency.
- Smooth with `1 - exp(-rate * dt)`, never `min(1, dt * rate)`. When converting, translate
  tuned constants to the equivalent per-frame fraction so feel does not move.
- A smoothing term must be *assigned*, not added to an existing velocity, or it is an
  undamped spring ("bouncy").
- Apply corrections as a velocity through the normal collision path, never as a position
  write, or they are invisible to collision and to tests.
- Never correct anything while the player is coasting. Snap on the next input.
- High speed alone reads as fast-forward. A spline with ease in and out and a heading that
  follows velocity reads as piloted.
- Indirect control (a tool driven by lag or acceleration) needs the lag set as a feel
  constant (~1 s for a thumb, T), the correct technique discoverable by accident, and the
  expert version reaching noticeably further. Approach a target *velocity* exponentially,
  never a target position, or the tool gets one kick and hangs.
- A saturating value is only a mechanic in the range it moves through. Cap where it rarely
  reaches and measure how often the cap binds.
- Two motions sharing one variable will eventually be shown doing each other's job (a rod
  that bends on the cast). Give each motion its own state.
- An idle world reads as a screenshot. Float the vehicle on the same wave function the water
  shader uses, generated from one source so they cannot drift.

## Controls and touch

- The frame the control speaks in must match the frame the camera speaks in. A fixed camera
  with vehicle-relative input is tank controls, and the report is "almost feels backward".
- A one-dimensional quantity gets a one-dimensional control (a slider, not a dial). Width is
  precision for free.
- Put the lagging thing on the control next to the thing being controlled, driven from the
  simulation's own state, so the player reads their aim without looking up.
- On-screen controls are absolute, not relative, or the picture stops saying where the
  machine is pointing.
- A readout glanced at can sit under the thumb. A readout watched continuously cannot. If
  they fight for space, change the verb (a tap has no position) rather than the layout.
- Indirect control needs a visible intermediary (the boom, not just the ball), and the
  machine needs a part that shows its facing from behind.
- One finger, three verbs, discriminated by movement not time: drag looks, still-hold
  charges, tap taps. A verb hidden behind a gesture that already means something else is not
  a verb the player has.
- The action button's caption is derived by the same function that performs the action.
- "It drifts" usually means the *path* curves (a throttle floor through a turn), not that
  the physics slide. Check the path before the integrator.
- A tracked vehicle is one constant from a car: an alignment cone outside which it only
  rotates, plus a turn rate fast at rest and slow at speed.
- Lay out touch controls against the *real* viewport, never the project's base size, and
  test the hit region against the drawn control on a tall phone. Every control handles its
  own input so hit box and drawing are one object.
- Test steering by driving real pointer events and asserting where the avatar lands *in the
  frame*. World-coordinate tests pass on inverted controls (Captain Run shipped inverted for
  its whole life).
- Thumb-sized targets (at least 48 dp), bottom of the screen, safe-area aware.

## Onboarding and the first minute

- He plays the opening and opens the menus first. The shallow part and the screens are what
  get played.
- Playable within ten seconds of opening. HOME is the game with `advance` not being called,
  not a menu: the level you are about to play is already behind the cards.
- A forgiving tutorial must still charge *time* for ignoring a mechanic, or it trains the
  player to ignore it and the next area punishes the habit.
- A station or pickup whose lowest tier is a no-op teaches the player to stop reading
  signs. Floor every station at its first real effect.
- A transformation big enough to divide a level into before and after must be a wall that
  cannot be missed, not an optional station.
- Every state names a visible action, and pressing the one visible control always leads back
  to playing. A way out only the simulation knows about is not a way out. Finishing a level
  starts the next; running out restarts. This has shipped as a frozen HUD twice.
- Teach through safe practice, escalate one variable at a time, never text-dump. The first
  thirty seconds are playable with zero reading.
- Version number and patch notes in the pause screen from the first build.

## Camera

- Portrait's horizontal cone is tiny (58 deg vertical is ~28 deg horizontal; 46 is ~22).
  Compute visible width at the distance a thing sits before placing it, and rack shops
  vertically.
- Horizontal detail wants a low camera, vertical detail a high one. The angle is part of
  the art.
- Seat a first-person camera at seated height and draw the vehicle as an edge (gunwales),
  not a surface.
- A tight frame reads as "camera too close" unless darkness justifies it. Make framing an
  upgrade and let the light's reach explain it.
- Any end-of-run camera move is a second placement pass over everything near the finish.
  Put the camera behind the subject.
- Re-shoot after any change to a length. Framing calibrated on old dimensions is wrong.
- Check a chase camera's handedness with the NDC test, and pick the axis convention so no
  sign flip sits near the input (draw the street along -Z so screen right IS world +X).
- Cull scenery against the camera position, not the player. A chase camera sits ten metres
  back, so anything culled at the player is still in front of the lens.

## Visual legibility and art direction

- Do not invent a symbol for something you can show. A bar is right only when the quantity
  has no physical form.
- Silhouette carries more than colour. A hazard must not resemble a reward. Separate play
  space from background by *lightness*, not hue, and test the gap.
- The most valuable thing on screen is the brightest. The hazard only has to be
  unmistakable. Every hazard in one colour family; variety goes in silhouette and behaviour.
- A cue that teases before it commits is a judgement; a cue that fires once is a reaction
  test. Draw the difference in two dimensions (depth and duration) and vary the count.
- A sphere reads as a bubble at any size. Prisms with hard corners catch light on one face
  and not the next.
- When a change must be noticed from memory, change the amount (3x the sparks), not the
  shade. Repainting a thirty-pixel drill per tier was invisible.
- Give each pressure its own channel. A number beats a bar when the player needs causation
  (`HULL -3.4/s`). Put the gauge on the thing it eats without covering it.
- Derive the picture and the score from one state so they cannot disagree. Let damage
  reveal history (shaved layers). When the accurate model and the readable model disagree,
  build the readable one (bands, not shells).
- A formation needs per-unit state and more than one unit wide to be readable. Rows with
  offset alternate rows beat a scatter. (unplayed)
- Make failure a *shape* (lean over a neighbour), not a number, with something visible to
  fail onto, painted lighter than the target.
- A transformation is worth ten multipliers. The screenshot before and after a station must
  be obviously different pictures.
- A liquid is motion and answers (a scrolling surface, entry rings, a tool that follows),
  not a texture.
- A HUD is a claim about what the player should think about. The reference shows three
  things. Do not keep adding readouts.
- A prop that occludes the thing the game is about is a bug. A chain of short boxes reads
  as debris; sweep a mesh along the path.
- "Unavailable" and "not a control" are two booleans. Only refusal is grey. Enabled and
  disabled say it three ways (colour, text, value), and ordering matters: sealed beats
  affordable, maxed beats affordable, name the missing material before the money.
- "Cartoony" from him means under-lit and under-textured, not the model style. A normal map
  on the largest surface, a real light source with falloff and a considered sky do more than
  any model swap.

## Lighting

- A point light does not know the geometry is there. Light through a grid must propagate
  through open cells (flood fill), with falloff in the shader and the field uploaded as a
  small texture. `techniques/coreward-propagated-lighting.md`.
- Surface light and air light are two lights. A corner shadow belongs only to the air
  term. Combine beam and bounce with `max()`, never by multiplying two floors.
- A lighting multiplier is linear and then sRGB-encoded, so its dark end lifts. Square it.
  Dim emissive things on a gentler curve than surfaces, or discovery mechanics switch off in
  the dark.
- Ambient is the one light that reaches every surface equally, which is the opposite of a
  lamp in a hole. Make it fall away fast. Three stops in a vignette.
- Do not light the player's vehicle with the gameplay light (its range is an upgrade). Give
  the vehicle its own key light and exclude the world's. In Godot that is `light_cull_mask`
  and `layers`, one flag, no second pass.
- Put the sun *ahead* of the camera for anything wet. A specular streak is sun, surface, eye.
- Any effect applied by distance hits the background hardest. Check the sky first when
  tuning fog (Godot `fog_sky_affect` ~0.2, T).
- Keep light fields at several texels per cell, and brightness and shape in separate
  channels. The one-toggle diagnosis is switching to nearest filtering.
- A metal with nothing to reflect is black plus hotspots. It needs an environment, and data
  textures (normal, roughness) must not be sRGB-decoded.
- A normal map is how photographed texture enters a stylised game. Sample by world position
  and expect a much higher strength than usual, judged under a moving lamp.
- Ambient particles are anchored in the world and wrapped around the player, lit by the
  world's light model on a harder curve, drawn behind terrain, faded wherever the beam is
  not the light. Dust you can see needs a dark room and a beam.
- Post-processing (vignette, animated mid-tone grain, a touch of aberration, blacks lifted
  toward the scene colour) is the cheapest mood tool there is. Put it under the HUD.
- A fix that improves every scene equally is a dimmer switch, not a fix. Attribute an
  artefact to a *layer* (toggle `.visible` per candidate) before touching any maths.

## Audio and music

- Sample where a sample is better; synthesise where the sound must answer the game. A tap
  or a knock is better from Kenney's packs than from a sine. A dip pitched by state is
  better generated. `techniques/generated-audio.md`.
- Randomise pitch and filter on repeated sounds. A round-robin pool of players, or one
  restarted player cuts its own tail off.
- A texture reads as ambience; only a rhythm reads as movement. A loop with no pulse floats.
  What makes music happy rather than ambient is a tempo you can nod to: a progression with a
  cadence, movement eight times a bar, a soft kick.
- A written theme beats random notes. Without repetition there is no phrase, and a fast
  attack on a high sine is a notification sound (his one outright dislike).
- A mood arc is a crossfade on a gameplay quantity, never a playlist. The layer that leaves
  does more than any that arrives. Assert monotonicity and a real span.
- Fade times should not match: places arrive slowly (~1.5 s), alarms snap in (~0.25 s) and
  leave lazily. Route an alarm past whatever is muffling everything else.
- Give the settings panel nothing to switch that does not exist. If there is a music toggle,
  there is music.

## UI and HUD

- Where a readout sits matters more than how it looks. The top of the screen is where nobody
  looks. Gauges by the thumb, or opposite the thumb if watched continuously. A gauge checked
  under pressure must not move for unrelated reasons.
- A pressed control reads as pushed in, not lit up. Give a needle mass, damped to what it
  shows. A HUD on a textured world needs its own material, with grain felt not seen.
- Labels in a 3D scene are sized by the pixels they occupy. Measure before choosing words.
- A shop the player is meant to be *in* is geometry, a room with the real object in it, not
  a panel and not a styled list. Hide the game entirely behind it, put the exit where a door
  would be. `techniques/coreward-shop-room-and-hud.md`.
- Pin the primary button (START, BUY, RECAST) to the bottom of any scrolling sheet.
- A screen you invented is invisible to you. List what the reference does *not* have.
- Do not copy a monetisation mechanic (a multiplier wheel) into a game with no monetisation.
- Preferences are not progress. Settings get their own file, and "erase progress" next to
  the sound switches only holds if the two are separate.

## Level and world design

- Put the reward on the ground with extent, give the player a formation with lag, and let
  the geometry make the decision (weaving measured 2.6x over straight, M).
- The thing you protect trails along your path rather than clustering around you, so size
  costs agility. Obstacles must test every unit.
- Starting with one of the collectible instead of eight makes the first pickup the most
  valuable object in the game. Cap flat damage as a fraction of the batch.
- An obstacle anchored to the track edge guarantees its own gap, and its hitbox derives from
  the drawing.
- Attrition asks one question ("leave sooner"). A rhythmic announced event makes depth a
  bet (a tremor every ~27 s past 85 m, T).
- Announce a zone before charging for it, and make several things land on the same metre.
  A threshold the player cannot see is not a mechanic.
- Look for one hazard being the answer to another before adding a third.
- Every content band must be reachable in both directions, and every row in a content table
  must be reachable at all. The bluegill shipped uncatchable with every subsystem working.
- If the game names a thing, the thing exists as visible geometry within reach of its
  interaction point. Three interactables shipped as prompts pointing at empty air.
- A first-person interior, a vehicle you sit in, a dock you tie up to: anything on screen
  for the whole game at full size is where imported assets earn their place.

## Process lessons that have each been paid for more than once

- Write the lesson the moment you learn it. Several games run at once.
- A complaint that survives a correct fix is about something else. When a symptom survives
  two fixes, stop fixing and measure: hide a layer, read a pixel, print the buffer.
- Half a feature working is the worst symptom, because it reads as tuning. If adjusting the
  obvious parameter changes nothing, a constant term is drowning it.
- Two bugs can hide each other. When a fix makes a different test fail, suspect a mask.
- Delete the stand-in in the same commit as the real thing, and audit everything else doing
  the same job. A fake put in before the real system exists does not announce itself.
- A rewrite beats revision when the fault is an inheritance (shape) rather than a decision.
  Keep research in its own file (`REFERENCE.md`) so a rewrite is cheap.
- Separate means separate, not delete. The answer to a gauge in the wrong place is to move
  the gauge.
- Before changing a constant, grep every formula it appears in. Test the derived quantity
  the player feels.
- Read the mechanism half of a report as seriously as the symptom half.
- Set up the test scene where the bug CAN appear. Four rounds were spent with the ship at
  the one junction where the artefact could not show.
