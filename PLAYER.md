# PLAYER.md - who the games are for, and how he works

Everything here is drawn from `playtests/*.md`, which is the evidence; quotes are verbatim and
never paraphrased. When the evidence changes, `/digest` changes this file. Read it before
designing anything: the same seven faults recur across eight games and every one of them is
listed below, as are the four things he has now asked for in more than one game and got in none.

Rewritten 2026-09-12 against all eight logs (Coreward, Captain Run, Wick, Candle Gift,
Wrecking Crew, Stillwater, Gravewell, Wildform). The previous version described six games and
was eight playtest entries behind.

## How he plays a new build

- **He opens the menus first**, then plays the opening. The shop, the pause screen, the upgrade
  list and the first sixty seconds are what get judged. Deep content has never been reported on
  in any game. Weight the effort there.
- **He plays on the phone**, in portrait, thumb over the bottom of the screen, with no dev
  console. A build stamp and version in the pause menu is how he tells which build he is on, and
  he asked for that himself; `POLISH.md` gates it, with the patch notes.
- "It looks good" or "runs great" means nothing obviously broke. It is not praise of feel. The
  one unprompted design compliment in eight games was for texture on the blocks in Coreward, and
  he turned it into a mechanic suggestion in the same sentence. The one other explicit approval
  is worth as much: *"the face of the rock looks decent as far as how the soft light shows"* -
  when he approves something, stop changing it.
- He sends several asks per message (eight in one paragraph is normal) and expects every one
  handled or explicitly answered. Number them back to him when you report.
- **He flags his own priorities and they are usually right.** *"im sure we can work on it later
  but the rod bends back then flicks forward"* - the rod was a ten-minute fix and the mechanic
  beside it was a rewrite, and the ordering he offered was correct.

## The recurring complaints, in his words

1. **The shop or menu is wrong, and it is the first thing he opens.** "make it look more like a
   separate upgrade screen, like an actual shop or building." "make it look like a full room
   where upgrades have a physical model." And the blocker: "it won't scroll down so I can't see
   all of the upgrades or close out of the menu." A shop is a place, not a panel or a list.
   Every scrolling panel is tested with a finger, and the primary button is pinned.
2. **Nothing is at stake.** "it feels free." "I can afford upgrades pretty early on for fuel and
   cooling so neither is a risk." "there isn't really a risk or reward yet." "the fishing
   mechanic is too easy." Doing nothing must lose, the greedy option must be genuinely better
   and genuinely near the edge, and a scripted do-nothing bot must score badly.
3. **The controls or motion feel wrong.** "feel more like it is free to fly not on a grid."
   "very bouncy when you change direction or stop." "the driving controls almost feel backward."
   "the dinosaurs run backwards and the controls are backwards." "flies out too much but also
   feels like it doesnt have enough momentum." "The button icons don't line up with where you
   need to press ... about .5 inches too high." "digging feels very rigid and chunky ... instead
   of taking longer to destroy a chunk I would like it to continously plow through but get
   slowed down on denser materials." Velocity and collision, exponential smoothing, controls
   anchored to the real viewport, and `test_controls.gd` for handedness. **Anything that gates
   the player's motion on finishing a discrete unit of work reads as chunky**, however smooth
   each unit is: he feels the cadence, not the interpolation.
4. **He cannot see the thing that matters.** "difficult to judge the price of the different
   blocks." "it doesnt seem very obvious that there is a distinct line." "my thumb will be
   blocking the gauge I am looking at." "i dont see any gauges and after it says tap in the
   green ... I cant recast or anything." "i cant see the log book on the ground" - said while
   the prompt in the same frame named the logbook, so the crosshair was on it and his eye could
   not find it. "it is difficult to understand what is going on." Every state names a visible
   action, every gauge sits where the thumb is not, and **every check-in carries a picture of every
   change with a visible result, shot at the device aspect** - not before shipping, which is too
   late and too narrow. He asked for it directly: "at the end of every session, when you stop and
   check in, can you provide me screen shots of how each of the changes look? I cant test right now
   but I can check screen shots." He said "I can't test currently" three times in one session, so
   **the screenshot is not a ship artefact, it IS the review**.
5. **An animation does the physically wrong thing.** "it looks like it is just fast forwarding."
   "The ship should turn to face the direction it is digging in." "the rod should pull up and
   back when preparing to cast but it pushes down and flings up." "the pages dont flip, they
   just change instantly." He gives the correct motion in order. Build exactly that motion and
   film it before sending.
6. **A rendering artefact survives several rounds, or the look regresses.** "it is still doing
   it." "it looks like it is happening worse now than it was and I liked the art style before
   better." "the game looks a little cartoonie. can you update the graphics to look more
   realistic and detailed?" "there appears to be multiple separate beams when using the light
   ... rather than a glow that extends from the front of the ship." Attribute an artefact to a
   layer before fixing it. A fix that dims every scene equally is a dimmer switch. Never trade
   away a look he liked to fix a bug.
7. **He wants the game to be about something.** "think about a larger point to the game, or
   secondary objective." "add additional creative upgrades like a bomb ... a laser beam." Every
   plan has a meta-goal, a collection or progression that does not decay, and a reason to come
   back in five minutes.

The only outright dislike ever recorded: "The music has random higher pitch beeps that I dont
like." A fast attack on a high sine reads as a notification sound. Music needs a written theme
with repetition, a cadence and a pulse, not random notes over a drone.

## What he has now asked for more than once and never been given

These are in the logs, in his words, and were in no topic file until 2026-09-12. Treat each as
standing, for every game and every screen, not as a request about the screen he was looking at.

- **Directional menu navigation with a confirm button.** Three times in two days: *"since the
  text is small I want arrow keys and confirm button to navigate the menues"*, then *"make it so
  clicking the up or down arrow changes what is selected, highlights it, and provides a
  description"*, then *"I want to have up down and left right control buttons while looking at
  menus like it. up down selects the different equipment and left right changes the version of
  equipment if we have it."* The first of these is his only accessibility note so far, and the
  log itself flags that it applies to every room, not the ones built so far.
- **An explicit X or back control, never tap-outside-to-dismiss.** Three times across Candle
  Gift and Stillwater: *"instead of clicking outside the menu to close it, i want an X or back
  button to prevent accidentally closing out of the menue"*, and *"when you run iut of pages keep
  the book out. only exit when I hit the X button."* Running out of content closing the screen
  is the same accidental-exit family. The Stillwater log's own note: *"He is right and the note
  was wrong."*
- **Affordance state visible on the control itself.** *"if I dont have other versions yet, make
  the arrows grey, so it is obvious that this is my only option currently"*, and *"make the
  select button grey unless there is something clickable, then change it to a yellow or other
  color that fits the theme."* He also overruled the opposite: *"dont show the dots implying
  that there are additional equipment. only show those if you have different versions to swap
  between."* A control says what it can do before it is pressed, and never implies options that
  do not exist.
- **Haptics as a readout channel, with two levels.** *"when the fish pulls, you should feel a
  small vibration, and when the pole is getting too bent, you should get a good amount of
  vibration to match."* The first time he has asked for the phone to buzz, and he asked for it
  as an instrument rather than as juice.
- **Drip-fed unlocks rather than a shop shown up front.** *"I want most of the upgrades to be
  hidden for now and unlock later in the game ... so you only unlock certain upgrades by finding
  them initially, the game hints at what it does and you now own it, then you can upgrade it at
  the shop."* Asked for Coreward, and the same instinct in Stillwater's tackle box.
- **Failure must be terminal.** *"I dont want towing to be a thing. if you run out of gas, you
  should game over."* He said game over and meant it. Take the hold, the run and the ship; the
  research is unanimous that meta-progression survives, and that is the only part to protect.

## The debt that came with giving him what he asked for

Rule 1 above - a shop is a place, not a panel - was implemented in Stillwater as rooms you look
at from the seat, and his first phone session on them was five complaints, every one of them a
thing a panel had been doing for free:

> "the menus clip through the physical objects, i cant see the log book on the ground. I cant
> swipe the pages on the log book when I pick it up."

**Panels do not intersect geometry, always have a close button, and are never behind anything.
Making a menu physical means re-earning all three, and none of them was in the plan.** A
SubViewport quad is ordinary geometry and depth-tests like any other. Budget the three debts -
depth, an exit, and reading order - in the same milestone as the room itself. A menu printed on
a 3D surface is also still a panel: *"It also just has a menu in it"* about a tackle box that
was a tackle box with a list inside it. The object IS what it contains.

## How he wants to work with Claude

- **Research first, and say so.** "research how other fishing games handle this mechanic." "use
  other games as reference." "research where the best place to get [assets] from and how to
  install them all on your end." "can you do some research and see what the best option is to
  achieve this effect, even if we need to do it a different way?" He asks for this repeatedly,
  so do it without being asked.
- **Match the reference first, then improve.** "I want the base of the game to be like the one
  she is talking about, then we can upgrade it from there." Read the strategy guide for the
  VERBS, find the longest playthrough video, magnify the screenshots before modelling anything.
  A store page lists what is in a game; a guide describes what the player is doing.
- **Free rein inside a brief.** "You have free reign to make improvements that you think will be
  fun or accurate." "fill in any missing details." He wants the idea expanded, not narrowed. He
  asked for a full design document up front for Stillwater and liked it.
- **One gate.** He approves the plan, then he wants a playable build, not questions. Wildform's
  plan was approved unchanged - "that sounds great. let's go for it" - so every difference
  between plan and build after that is the build's doing, not his. If a decision genuinely
  cannot be made, make the reversible choice, write it in `NOTES.md`, mention it in the ship
  report.
- **Go back to the original intent, not the defect list.** "expand on everything and upgrade
  every aspect of the game and try achieve what I was requesting initially, rather than just
  modifying things that are having issues with the game currently." The unit of work is the gap
  between the game and the intent.
- **Numbers have to be real.** "is the memory limit something you have set or a built-in
  standard?" "Are we still stuck to seventy draw calls? What is preventing that from being a
  higher possible number." Measure before quoting a limit. The seventy draw-call figure was
  wrong by thirty times.
- **He sets acceptance criteria and expects them honoured.** "I would only want to do it if it
  has very little impact on the game running and is actually helpful."
- **He does not want realism for its own sake.** "it doesnt need to be realistic fishing
  mechanics. it can just be a fun challenging mini game feel." And he wants the fiction and the
  mechanic to be the same object: a float pulled under IS the timing cue, the rod's bend IS the
  tension gauge, the rod pointing where you look IS the aiming reticle.
- **He reads the reasoning on a no.** A reasoned no on an asset was welcomed. A silent absence
  is not.
- **He reads screenshots he sends you closely and expects the same.** "Did you see the areas I
  circled in my picture?" Look at every image he sends before answering.
- **He corrects process misdiagnoses.** "Another Claude code chat was running tests on the
  Coreward game ... If that was causing test issues, don't write those off as broken." Other
  sessions are running. A flaky suite is more likely a port or a shared file than a bug.

## How he reports, and what that tells you

- **He names the symptom accurately and the cause is structural.** Not once in eight games has a
  complaint turned out to be a matter of degree.
- **When he proposes a mechanism, build that mechanism.** `playtests/` records at least a dozen
  proposed mechanisms across Wrecking Crew, Stillwater, Coreward, Candle Gift and Gravewell -
  rotate the crane, a slider not a dial, break the beams inside the building, a machine on
  tracks that turns to face before moving, tap to hold pressure, watch the bobber, distance as
  progress and the rod as the tension, the logbook and tackle box as objects, grey arrows for
  "no other option", upgrades found before they are bought, reference price tags first - and not
  one of them was wrong.
- **When he restates from scratch instead of refining, the model is wrong, not the tuning.** Two
  Gravewell lighting notes in a row were restatements naming five mechanisms each; what he
  repeated unchanged between them was what was already right.
- **New, 2026-09-11: he has started naming two candidate mechanisms and asking which is right.**
  *"im not sure if the ticks need to be smaller or of you can make the rock break into smaller
  chunks. can you do some research and see what the best option is to achieve this effect, even
  if we need to do it a different way?"* That is the first time he has done that, and it is a
  different mode from both restating the feel and naming the fix: he is pointing at the class of
  cause (granularity, not speed) and handing over the choice within it. Answer it with research
  and a measurement, name which candidate is right and why the other cannot work, and say so
  explicitly - he has asked a question and expects it answered, not absorbed.
- **A complaint that moves is a fix that worked.** "It still rocks a bit too much" after a
  measured 18x reduction in camera rotation was not the camera failing; the camera was 1.1
  degrees and he had moved on to the waves. Re-read a repeated complaint for what has changed
  in it.
- **He reports the instrument's blind spot.** "I feel like things kept getting missed" is a
  process complaint, and it is the fourth time in six sessions he has named a fault a screenshot
  had already had the chance to show. He also named the fix: "I think you may have the correct
  tools to fix those now."
- **He pre-excuses legibility problems and you must not accept the excuse.** "it is difficult to
  understand what is going on but that may be improved when the rest of the plan is
  implemented." Take it at face value now.

## Preferences that carry into every game

- Portrait, one thumb, no menu to wade through. Playable within ten seconds of opening
  (`POLISH.md` gates it; `CRAFT.md` has why it is a consequence of the structure, not a target).
- Real 3D by default. He likes texture, lighting and a lived-in look over flat color.
- **Write US English everywhere he or a player reads**: chat replies, reports, commit subjects,
  changelogs, README text, on-screen strings, and the Play listing (en-US, USD). It is spelling,
  not units - Godot's meters stay meters. `scripts\us-english.txt` is the word list; `INDEX.md`
  standing rule 15 and `doctor.ps1` both check it, and `/digest` converts a topic-file section the
  moment it folds a lesson into that section.
- Anything that reads as a light must come from a fitting: "anything neon should feel like it is
  actually coming from an object or light in the room, not an overlay."
- A game keeps growing. Plan the second month's content in the first plan, even if it is not
  built.
- **Every screenshot is at the device aspect** (`--resolution 460x996` for a 1080x2340 phone). A
  desktop-window capture is nearly square and hides anything near an edge, so it cannot be used to
  sign off placement: a roughly square shot showed Stillwater's rod in the player's hands correctly
  while a probe at the real 19.5:9 found the reel **more than a full viewport width off the left
  edge**, so the rod bend, the line reddening, the reel animation and the new haptics had all been
  signed off on a picture that could not show them. Two of his complaints that session ("the pages
  are in the air on the left", "planks and sticks sticking up on the right") were both things a
  device-aspect shot showed immediately. If a change exists only mid-animation, add a screenshot
  mode that freezes the clock inside it rather than reporting that it cannot be captured.
