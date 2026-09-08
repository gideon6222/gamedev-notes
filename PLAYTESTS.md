# PLAYTESTS.md

What Gideon actually said about each game, in his words, dated. Complaints are the most
valuable entries here.

**Append, never rewrite.** This is the one file that stays chronological: it is evidence,
and evidence does not get reorganised. `CRAFT.md` is where the conclusions drawn from it
live, and that one *is* reorganised.

Record a session's feedback when it arrives, not when the game is finished - the next game
may start before this one ends.

---

## Coreward — github.com/gideon6222/coreward

Live at https://gideon6222.github.io/coreward/

Dig toward a planet core, sell ore at the surface pad, buy upgrades, break the core and the
planet explodes, launch to a harder planet. Fuel and heat are the two pressures pushing you up.

### 2026-09-06 — first run
"the game looks like it runs great"

Ran well on the S26 Ultra in Chrome, installed as a PWA. No performance complaints.

### 2026-09-06 — first real session, reached 75m

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

### 2026-09-06 — autopilot and music

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

### 2026-09-06 — after the build-step migration

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

### 2026-09-06 — heat soak, first pass

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

### 2026-09-06 — after the fix

"I just tested it it on my phone through the app and it looks good."

No complaint about the balance, which is the part I was least sure of - the soak rates, the
0.72 shield cap and the reprice were derived from modelling, not from play. Treat that as
"nothing is obviously broken" rather than "the balance is right"; he has not yet played deep
enough on the new numbers to hit the wall where cooling becomes mandatory.

### 2026-09-07 — after the first overhaul, ten changes deep

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


---

## Captain Run — github.com/gideon6222/Captain_Run

Live at https://gideon6222.github.io/Captain_Run/

A viking crowd-runner. Drag to steer the warband up a mountain road; crates and draugr burst
into gold, iron and runes; iron fills a forge bar that upgrades the axe mid-run; each ascent
ends at a jotunn that is a pure DPS check, then a camp to spend gold.

### 2026-09-07 — how it was asked for

He sent a screenshot of a commercial viking runner: "can you make a phone game like this with
a similar level of graphics? are there tools or resources that you could be using that would
help?" and said the repo already existed.

The honest answer about tools: the good CC0 libraries — Kenney, Quaternius, Poly Pizza,
KayKit — all ship glTF/GLB, and the GitHub connector cannot push binary, so on the five-file
stack those assets are unreachable until a game earns a build step the way Coreward did.
Everything in the screenshot turned out to be reachable procedurally regardless: toon
shading, hard outlines, chunky silhouettes, and a great deal of loot in the air.

### 2026-09-07 — first build, NOT YET PLAYED

Recorded so the next session knows exactly what is verified and what is not.

**Verified** by driving the frame loop from a harness and screenshotting: the full 50-second
ascent, all five gates, the forge climbing four axe tiers within a run, draugr charging and
dying in frame, the jotunn fight and kill, the win path into the camp, the death path
("CARRIED HOME · KEPT 60%"), buying from the shop, locked rows gating on ascent, the steering
clamps, and 42-55 draw calls with the screen full.

**Not verified at all**: how it feels. Nobody has touched it with a thumb. Specifically
untested — the drag sensitivity (9.5 screen-widths to cross the road, a guess), whether the
audio is pleasant or irritating on a phone speaker, whether the boss lasts long enough to
feel like a fight, and every balance number past ascent 3, which is modelled rather than
played.

Ask him, in this order: does steering feel responsive or floaty; does the crowd growing feel
good; is the jotunn a wall or a formality; and does the music annoy him. The last one because
the Coreward score drew the only outright "I don't like" of that entire game, so the theme
here is a written 8-note phrase on a slow-attack horn rather than random notes — and it is
worth knowing whether that lesson actually transferred.
### 2026-09-07 - still exploring, six more asks

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


### 2026-09-07 - Captain Run becomes Wick, at his request

Asked what to work on next, he redirected the whole game:

"This was more of a base start of a game I would like to create. My girlfriend said that she
played a game a long time ago that had similar mechanics to this but you are a candle. The
point of the game is to collect additional layers of wax to make the best candle possible. As
you run, you run into traps that can remove wax from you. I think there are additional traps
as well. She thinks that once you reach the end of a level, you sell the candle and get more
money depending on how nice your candle is. You spend that money to get upgrades. Can you
research to see if you can find this game, model Captain Run off of it, and find assets you
can use to make it look like a polished professional game. You have free reign to make
improvements that you think will be fun or accurate to the game she is looking of."

Two things worth keeping about how this arrived.

**He described a complete game in one paragraph, secondhand, and every mechanic in it was
load-bearing.** Layers rather than an amount, traps that take them, a *quality*-based payout
rather than a score, and upgrades. That is a full loop, and the "how nice your candle is" is
the part that makes it more than a collect-a-thon - it is what let the ending be an appraisal
instead of a boss.

**He asked me to find the source game, and no single title matches.** Candle Craft (Voodoo) is
the layers-and-sell half; Gem Stack (MWM) is the run-and-protect half. Said so plainly rather
than picking the nearest match and claiming it - the mechanics were unambiguous either way, so
the missing title cost nothing.

Also asked, again, for downloadable assets to make it look professional - the same ask as
Coreward's session. The answer is again mostly no, and this time for a *structural* reason
worth reusing: **the candle's shape is gameplay state.** Its radius is how much wax you have,
its bands are what you dipped in and in what order, and a blade shaving one side has to expose
the colour underneath. No imported mesh can do that. Told him so with the reasoning rather
than leaving the absence silent, and spent the effort on the thing that does read as polish -
the candle being a real light source in a dark room.

### 2026-09-07 - Wick, first build, NOT YET PLAYED

Same status as Captain Run's first build, and worth recording as carefully.

**Verified** by driving the frame loop and screenshotting: dip arches adding rings, the
stepped-tower silhouette, blades shaving and bending, heat melting evenly, water snuffing the
wick and heat relighting it, a cold candle refusing droplets, the wick guttering and ending
the run at 55%, reaching the bench and selling, the appraisal breakdown, the shop, the scent
shelf, 32-43 draw calls, and the grades spreading PLAIN / GOOD / MASTERWORK across three
scripted play styles.

**Not verified at all**: how it feels. Ask, in this order - does the steering feel responsive
now (it was genuinely inverted in Captain Run, so this is the first build of either game where
a rightward drag moves the thing rightward); is the wick tense or stressful; is the appraisal
screen satisfying or just a table; and does the music annoy him. The last one because the
Coreward score drew the only outright "I don't like" of that game, and this one reuses its
horn theme with the octave drop repointed at being snuffed.

### 2026-09-07 - after lanes, the rock texture and the tick seam

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

### 2026-09-07 - the actual game, found

He sent two screenshots of the game his girlfriend remembered, from a YouTube short:
**Candle Gift** by Rollic Games. Worth recording that the first build was made from a verbal
description alone and got the *loop* right and the *presentation* completely wrong - it had
the player *being* a candle, in a dark workshop, when the real game is a bright factory line
and the player is the production line.

"can you make the visuals, mechanics, and gameplay look more like this? but an upgraded
version with similar art style and better graphics. also changes the menus and upgrades to
match. please research this actual game to see how other levels look and feel and how it
works, then overhaul our version to match closely to this. We will continue to make changes
to make it better than the one she remembers but I want it to start out very similar."

Two things worth keeping about this.

**A screenshot is worth more than any amount of description.** Everything that made the
overhaul work came from the two images plus one line of a strategy guide: the purple runway
in open sky, the hot-pink pill signs, the green banknotes, the red X barriers - and, in one
frame, CANDLE on the left of a gantry and GLITTER on the right, which is the entire
two-halves station design. Ask for a screenshot early when a game is being described from
memory.

**The most useful single sentence was in a strategy guide, not a store page:** "as your
candle stack gets longer, you need to be aware of everything happening in front of you, and
sometimes you need to start moving well before an obstacle is in reach". That is the trailing
stack, and it is what the whole rebuild is now built on. Store descriptions say what a game
contains; strategy guides say how it *feels* to play.

Also, in his own words on the earlier session's failures - he corrected a wrong diagnosis:
"Another Claude code chat was running tests on the Coreward game I am working on and cause
the earlier issues with the live tests. It has moved it over to an unused port. If that was
causing test issues, don't write those off as broken."

He was right and the recorded cause was wrong. Two games sharing a preview port produced
failures that looked like the game failing to boot, and one run that silently tested the
*other* game. Ports are now per-game.

### 2026-09-07 - Candle Gift, first build, NOT YET PLAYED

**Verified** by driving the frame loop and screenshotting: the trailing tray lagging through
a turn, obstacles clipping the tail of a tray the leader already cleared, all four station
kinds firing, both halves of a gantry doing different things, gates growing the tray to its
cap, banknotes and guarded banknote lines, the gift table lighting each candle in turn,
star ratings spreading 1/2/2/3 across four scripted play styles, and 45-65 draw calls.

**Not verified at all**: how it feels. Ask, in this order - does a full tray feel satisfying
or sluggish; is the steering sensitivity right now the runway is wider; does the results
screen land; and does the music annoy him. The last one because the Coreward score drew the
only outright "I don't like" of that game.

### 2026-09-07 - first real report on Candle Gift, and it was a blocker

"When I get to the upgrade screen, it won't scroll down so I can't see all of the upgrades or
close out of the menu to continue"

Exactly the pattern in "Working with Gideon": he named the symptom precisely and it was
structural, not cosmetic. The game was unplayable past level one and nothing on the desktop
could show it - every automated check drove the game through the debug seam, and the shop had
only ever been *clicked*, never scrolled.

Two causes, both in PIPELINE.md now: `touch-action: none` on body (which a browser intersects
up the whole ancestor chain, so it disables panning in every scroller under it), and the
window-level steering handler calling preventDefault() on drags that started over the menu.

The lasting fix is the third one though: the START button is now pinned to the bottom of the
sheet. It had been the last element after eight upgrades, a changelog and a build stamp, which
is what turned a scrolling bug into a dead end.

Worth remembering for every game here: **the first thing he does with a new build is open the
menus.** Both of the last two games' first reports were about a screen, not the gameplay.

### 2026-09-07 - "still pretty far off", and he was right

"I like the improvements but it looks like we are atill pretty far off from the original game
she was talking about. can you do a full overhaul to make the mechanics the same, same traps
and upgrades. I want the base of the game to be like the one she is talking about, then we can
upgrade it from there."

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

Still unverified, and he should be asked: the upgrade list. "Same traps and upgrades" cannot be
derived from two action screenshots and no source on the web lists them, so the shop is still
our own - Bigger Batch, Earning Power, Steady Tray, Long Reach, Deeper Vats, Glitter Cannon,
Press, Wrap. A screenshot of the reference's upgrade screen would settle it in one message.
