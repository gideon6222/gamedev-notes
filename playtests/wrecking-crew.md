# Playtests — Wrecking Crew

Gideon's words, dated, verbatim. **Append only.** New entries go at the end under a `## YYYY-MM-DD` heading. Interpretation and lessons go in the topic files, not here.

---

## 2026-09-08 - Wrecking Crew, and the genre was the problem

Three shapes in one day. Worth recording all three of his notes, because each one was a
correct structural diagnosis rather than a matter of degree - the pattern in "Working with
Gideon" holding for a fourth session.

**On the first build (a lane runner with a fixed forward-pointing boom):**

"i think it would be more fun if the main goal was to rotate the crane part to hit the
buildings, especially as we add things to aim for. we would still be able to swipe to move
as well and have occasional obstacles to dodge but much less and would be more of an
additional thing to pay attention to rather than a main objective."

- Right, and the reason is worth keeping: aiming WAS the whole game and you could not see
  yourself aim. The ball was driven by the rig's lateral acceleration, so the only feedback
  on your aim was whether you hit something. Making the turret slew bought the one thing
  that mattered immediately - a bot that never touches the crane now scores exactly zero,
  where the equivalent bot on the old scheme scored 138 against the aimer's 268, because a
  ball driven by the vehicle's own movement swings into things by accident.

**Also, the same message:** "the game froze here" with a screenshot.

- The screenshot named the cause on its own. "BEST 582 on street 1" is only written when a
  street FINISHES, so the run had reached the end, `over` went true, and nothing existed to
  start street 2. A known gap in NOTES.md shipped as a hard stop. The lesson is in CRAFT
  now: every test in the suite played a level and read the state at the END, which is the
  exact instant the freeze began. The suite was not weak, it was uniform.

**On the second build (the crane runner):**

"The button icons don't line up with where you need to press on the screen. The icons are
about .5 inches too high."

- One cause, two symptoms, both mine. `stretch/aspect = "expand"` keeps the base WIDTH and
  extends the HEIGHT, so his screen's canvas is ~1080x2340 while the project base is
  1080x1920 - and the pads were laid out against the literal 1920. Separately the hit test
  scaled touches into a space of its own, so the drawn control and the region that responded
  disagreed with each other too. No headless test could catch it: the base size is exactly
  where the wrong layout and the right one agree.

"I think I would prefer having what looks like a joystick for the actually wrecking ball
machine on the screen that you move to rotate the boom, then if you swipe below it, it moves
the machine the direction you swipe."

- Built as described, and it turned out better than a generic stick: the dial draws the
  machine from above, with the boom where you pointed it AND a dot for the ball where it
  actually is. The gap between those two is the lag the whole game is about, and it is now
  readable without looking up at the crane.

**And the one that changed the game:**

"One thing that shows me though is that there isn't really a risk or reward yet. Can you
think of a way to have the buildings we are destroying be necessary? Like it unblocks a
path, or we are breaking beams inside a much larger building to collapse it? I think my may
complaint is I want to focus on the breaking part and don't know if this forward lane style
game is the best option."

- The most valuable note anyone has given on this project. It was not a balance problem and
  I had been treating it as one: in a runner the buildings are scenery you pass, passing is
  free, and no tuning makes optional destruction necessary. His own suggestion - breaking
  beams inside a larger building to collapse it - is now the game. One condemned building per
  site, a fixed number of swings, columns at the base, and a lean that puts it on the block
  next door if you work along one side.
- Worth noting for next time: **he proposed the fix and the fix was right, twice in one
  session.** The pattern is now four sessions old and has not failed once.

## 2026-09-09 - Wrecking Crew, the controls

Three sessions of notes on the same game, and the pattern in "Working with Gideon" held
every time: he names the symptom accurately, and the cause is always structural.

[duplicate of the entry above in the original file — the first three quotes of this entry repeat the 2026-09-08 entry]

"The button icons don't line up with where you need to press on the screen. The icons are
about .5 inches too high."
- A stretch-mode bug, and one no headless test could have caught: the base viewport is
  exactly where the wrong layout and the right one agree. See PIPELINE.

"i think I would prefer having what looks like a joystick for the actually wrecking ball
machine on the screen"
- Built it. Then, one build later: "the controls dont need to be a dial look. since we are
  only controlling the turning, it could just be a left and right joystick or slider." Also
  right, and the reason generalises: a dial is a two-dimensional control for a
  one-dimensional quantity, so the thumb has to be placed on a circle to say what a line
  could say.

"there isn't really a risk or reward yet... I want to focus on the breaking part and don't
know if this forward lane style game is the best option."
- The most valuable note on this project. Not a balance problem: in a runner the buildings
  are scenery you pass, passing is free, and no tuning makes optional destruction necessary.
  He proposed the replacement himself and it is now the game.

"the driving controls almost feel backward but not sure if that is the main issue."
- They were, half the time. Fixed camera plus vehicle-relative controls is tank controls, and
  it produces exactly that report: a nagging doubt rather than a clear complaint, because it
  is correct half the time. Worth noting he flagged the uncertainty himself - "not sure if
  that is the main issue" - and it WAS one of two separate faults in the same message.

"it flies out too much but also feels like it doesnt have enough momentum."
- Two faults stacked, and the phrasing named both precisely. A constant restoring force
  instead of a proportional one (so the ball stayed wherever it was flung), and a constraint
  that derived velocity from displacement (so momentum died the moment the chain went taut).

"it doesnt seem locked to move forward and backward. it seems to drift. can you make it so
that it works like a large machine on tracks... if you hold right, it should automatically
rotate itself to face right, then start moving in that direction."
- The machine was already locked to its heading. What it lacked was the pivot: a 45% throttle
  floor meant every turn was an arc, and an arc under a still camera reads as a slide. His
  proposed fix was the correct implementation, again - and it is one constant, an alignment
  cone.

Five reports across three sessions, five structural diagnoses, and on four of them he named
the fix. The standing note is now stronger than "believe the symptom": **when he proposes a
mechanism, build that mechanism.**
