# Playtests — Wildform

Gideon's words, dated, verbatim. **Append only.** New entries go at the end under a
`## YYYY-MM-DD` heading. Interpretation and lessons go in the topic files, not here.

---

## 2026-09-11 - the idea, and the gate

The original ask, in full:

> One of those games where you run forward, slide left and right to dodge obstacles, shoot
> resources to get money and gems, and shoot gates or objects that continue to level up the
> more damage you do to it. Once the run is over, you get to upgrade your stats and abilities
> to make it further into the level. The is a full progression system so that after you beat a
> level, you start a new one with a different theme. Your character progress resets but
> certain overall abilities don't, so you keep getting stronger each level, even though your
> main stats reset. I want it themed around pokemon style, where you continue to level up,
> evolve, and gain new abilities. Those are the things that stick between levels. I want some
> additional twists and ideas from other similar games that worked well.

Shown the plan at the gate, he approved it unchanged:

> that sounds great. let's go for it

**Worth recording for later, because it is the kind of thing that gets re-litigated:** the
plan was approved with no edits, so every difference between the plan and the build from here
is the build's doing, not his. The three additions he accepted without comment were type
advantage as the read, the evolution branch decided by what you fed, and de-evolution as the
health bar.

**And the research finding he accepted:** there is no reference game. The genre's actual hits
(Count Masters, Gun Rush, Tall Man Run) use instant walk-through gates with no shooting and no
accumulation; the shoot-to-raise-tier gate he described has no verified precedent. So unlike
Candle Gift there is nothing to match, and the readability of the damage race is specified
rather than copied. If it does not read on the phone, that is the place to look first.

## 2026-09-11 - the first build he actually played

> I was able to test the apk. the dinosaurs run backwards and the controls are backwards. it
> is difficult to understand what is going on but that may be improved when the rest of the
> plan is implemented.

Three asks, and the first two have **one cause**.

**1 and 2 are the same bug.** The track was drawn along +Z. A Godot camera looking toward +Z
has its right hand pointing at -X, so world +X appears on the LEFT of the screen: dragging
right moved the creature left. The same wrong axis meant the models were rotated to face the
opposite way from the direction of travel, so they ran backwards. This is exactly the fault
`CRAFT.md` warns about - *"pick the axis convention so no sign flip sits near the input (draw
the street along -Z so screen right IS world +X)"* - and exactly the one Captain Run shipped
inverted for its whole life. One flip of the renderer's axis fixes both, and there is now a
test that drives a real drag through the input handler and asserts which way the creature
moves ON SCREEN, which is the test that would have caught it.

**Worth recording about the process, not just the bug.** The desk had every tool needed to
catch this: filmed runs, contact sheets, screenshots of every screen. None of them caught it,
because I only ever drove the game with scripted policies that call `steer_to()` directly and
never once through the touch handler. **A policy that sets the value the control would set is
not a test of the control.** The one thing no bot here does is hold a thumb.

**3 is the one to act on.** "Difficult to understand what is going on" is the report that
matters, and he has pre-excused it ("may be improved when the rest of the plan is
implemented") - which is exactly the kind of generosity that gets a legibility problem
deferred until it is load-bearing. The picture has no words in it: no callout when a gate
ticks up, no callout when a stage is won or lost, unlabelled bars at the bottom, and gates
that read as pale slabs. Taking it at face value now.
