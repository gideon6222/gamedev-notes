# Scripted players with human faults: measuring design with bots

**Game:** Stillwater, Candle Gift, Wrecking Crew (Godot template carries the harness); Captain Run and Wick were balanced this way before being played · **Status:** shipped on every Godot game; the Stillwater bot printed "too easy" a day before Gideon said it · **Read when:** setting a balance constant, a par, a star threshold; a fight or mechanic that a bot beats every time; two policies scoring the same; a bot that loses to a dumber bot; any claim of the form "ignoring X costs the player"

Every game here is balanced by scripted policies driven through a headless tick seam: a bot
that does nothing, one that dodges, one that plays well, and on Stillwater a model of a
person with a reaction time, a misread rate, a wandering thumb and - the part that mattered -
memory. The perfect bot landed every fish and the number was read as good news; the human
bot lost 24% and the fight became measurable. This file collects how those players are built
(model the input device, not just the decision; memory that lags reality by a reaction time;
a rhythm when the input is a rhythm), how they are used (measure the claim where it holds;
per item not one mean; sweep the bot's parameter before touching the game's; several seeds,
not one), and how they are kept honest (one definition of playing well shared by bots and
tests; a bot that loses to a dumber bot is a bug report about the bot; tune the game, never
the bot).

**Generalisable takeaways**

- **A perfect bot winning is not evidence about difficulty.** Give the scripted player human
  faults and memory - it keeps doing the wrong thing until it notices - and model the input
  device: a tapping rhythm corrected a few times a second, a position with a hand that
  wanders. A bang-bang controller makes any timing mechanic look free.
- **Read the spread, not the mean, and measure the claim in the part of the game the claim is
  about.** Script the extremes first, read the ratio, then place thresholds inside it; when
  every play style scores the same, fix the game, not the thresholds; calibrate over five or
  six seeds and keep single-level numbers as regression tests only.
- **One definition of "playing well", in the repo, used by bots and tests alike.** Sweep the
  bot's one free parameter before blaming the design; make every policy fail for a different
  reason; make the pair that proves a decision differ in exactly one thing; give the bot the
  survival job too.

---

## Measure a claim in the part of the game the claim is about

**MEASURE A CLAIM IN THE PART OF THE GAME THE CLAIM IS ABOUT.** Stillwater's policy harness
could only ever play from the default starting state, so every assertion in the suite was
secretly an assertion about five tutorial fish. "Ignoring the warning costs you fish" was
being tested in the one area deliberately built so that it does NOT - and when that area was
made gentler the test failed, correctly, and looked exactly like a regression in the game. It
was a regression in the measurement.

The fix is to let the harness start anywhere - a spot, a level, a loadout - and then make each
claim where it is supposed to hold. The tutorial got its own weaker claim in the same pass:
a missed warning there costs TIME, not progress, so the opening can be forgiving without
teaching the player that the warning is decoration. **A forgiving tutorial that makes a
mechanic entirely free is training the player to ignore it, and the next area then punishes a
habit the game itself taught.**

Two smaller forms of the same thing:

- **A test whose expectation is wrong looks identical to a bug.** Asserting that better line
  reached deeper failed, because the starting bay has a bottom and no line finds a fifth metre
  in four metres of water. Better line does not deepen the water you are in, it lets you GO
  somewhere deeper - two halves of one gate, and a test expecting either to work alone is
  testing a game that was not built.
- **Do not compare two functions at a boundary they use different conventions for.** Band
  lookup was half-open (`min <= d < max`), species lookup inclusive at both ends, and they
  disagreed at exactly the depth the starting spot's full cast lands on every single time.
  Neither convention was wrong; comparing them there was. State the invariant where it is
  unambiguous - statically over the table - instead.

## Feel as tests

**"IT FEELS CLUNKY" IS THE MOST VALUABLE PLAYTEST NOTE AND THE LEAST ACTIONABLE**,
because nothing in it can be failed. Some of feel is taste and needs a person; a
useful amount of it is objective and can be a test. Five that earned their place:

| claim | assertion |
|---|---|
| affordance | every state names a visible action, and the caption matches what the control does |
| dead time | from any state, pressing the one visible control leads back to playing |
| latency | every input is answered within two frames - research puts consistent performance inside ~50 ms |
| liveness | two samples of the world a second apart are never identical |
| discrimination | one gesture never fires another gesture's verb, in both directions |

The last one **failed on its first run and found a real bug**: cancelling a
charged cast called the function that THROWS it, so looking around threw a line
every time. Feel tests find feel bugs, which no amount of simulation testing
will.

## A perfect bot winning is not evidence about difficulty

**A PERFECT BOT WINNING IS NOT EVIDENCE ABOUT DIFFICULTY.** It is a fact about perfect bots.
This is the most expensive testing lesson here so far, because the probe printed the answer a
full day before the player said it out loud and it was read as good news.

Stillwater's first fight was a threshold model - hold the tension inside a band. The scripted
angler landed 6.83 fish per session and lost **zero**. That went into NOTES.md as "the number
to watch", the build shipped, and Gideon's first sentence about it was "it is too easy". The
bot was a zero-latency, perfect-information controller: it will beat any mechanic that is fair,
so its score carries no information about whether a person will be challenged.

**The fix is a bot with human faults, and it has to have MEMORY.** Stillwater's now models
three: a 300 ms reaction time, a tell it misreads about one time in six, and a thumb that
wobbles by ±0.055. The first attempt was stateless and scored *identically* to the perfect bot,
which was a second wrong reading of the same kind - because a stateless bot corrects itself the
instant the world changes, so a misread costs it only the warning window and nothing after. A
person keeps doing the wrong thing **until they notice**. Once belief lagged reality by a
reaction time, the same build went from 0% losses to 24%, and the fight was suddenly measurable.

Two corollaries worth having:

- **Tune the GAME so the human bot struggles; never tune the bot so the game looks hard.** The
  moment the model is adjusted to produce a nicer number it stops being an instrument.
- **A tell longer than human reaction time makes a mechanic free.** Stillwater's warning was
  0.42 s against a 0.30 s reaction, so the "late" player was never actually late. That is only
  visible with a latency model; with the perfect bot both numbers score the same.

**MODEL THE INPUT DEVICE, NOT JUST THE DECISION.** The sharper version of all of the above, and
it cost a whole tuning session to find. Stillwater's third fight is tapping to hold a needle in
a band, and the first bots for it tapped whenever the needle was below their aim point,
re-evaluated every frame. That controller **automatically stops tapping during a run** - because
a run pushes the needle up - so the game's one moment of danger solved itself, and the bot that
watched the warning, the bot that ignored it, and the human model all scored an identical 100%.
Three different players, one number, and it looked like a balance problem.

Nobody taps by sampling sixty times a second. A person settles into a RATE and corrects it a few
times a second, which means they are still tapping for a moment after something changes. Once
the bots held a tap interval and adjusted it on a ~0.3 s cadence, the warning became worth
something and the spread appeared immediately.

The general rule: **when the input is a rhythm, the model has to have a rhythm; when it is a
position, it has to have a hand that wanders.** A bang-bang controller is a model of a decision,
not of a player, and it will make any mechanic whose difficulty lives in *timing* look free.

**And when the model needs memory, every caller has to hold it.** Godot evaluates a `{}` default
argument per call, so a caller that forgets the state dict silently hands the bot an empty
memory every frame - the tap rhythm re-initialised, the interval never elapsed, and the bot
**never tapped at all**. Six tests and most of a smoke suite failed at once with "correct play
landed nothing", which reads as a broken game rather than a broken caller. Grep for the call
sites the moment a policy gains state.

## Read the spread, not the mean

**Difficulty is usually the PRODUCT of two fields, and neither one tells you where a thing
sits.** Raising the bluegill's run chance while leaving its "busyness" high made the *tutorial*
fish harder than the one after it - 79% landed against the perch's 88%. Nothing in either field
looked wrong on its own. There is now a test asserting the species table is a monotonic ladder
in the order it is written, because a content table that is supposed to be ordered should say
so out loud.

**Measure per item, not as one mean.** The aggregate said "the human loses 24%", which hid that
the first fish was a 92% win and the prize fish was 54%. One mean over a difficulty ladder
describes none of its rungs.

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
- **Set balance constants from a measurement through the debug seam, not from a guess.** Wick's
  grade thresholds were first set by eye, and a run that never touched the screen graded FINE
  while every competent run hit the ceiling. Three scripted runs - do nothing, dodge, dodge and
  collect - took ten minutes to write and gave three real numbers to cut the grades against.
  Keep the script long enough to use it again; delete it once the number is recorded, and put
  the measurement in the comment beside the constant.
- **Assert the state that distinguishes outcomes, not the panel that shows both.** The
  full-ascent test checked that the camp screen opened and matched `/CAMP/`, which is true
  of both `MOUNTAIN CAMP` (won) and `CARRIED HOME` (died). It passed for the whole of a
  balance cliff where the run died every time.

## Several seeds, and the bot that lives in the repo

**Calibrate against several procedural levels, never one.** Candle Gift's four scripted
policies swing 25% from level to level on layout luck alone - its "dodge hazards only" bot
scores 18,158 on level one and 1,350 on level five, where dodging is worse than doing
nothing. A `par` set from level one put the best policy on three stars there and two
everywhere else, and nothing about that was visible from the level-one numbers, which looked
clean and well separated. Take the mean over five or six seeds, and keep the single-level
numbers as a regression test that says in its own comment that it is not the calibration.

**A bot is a definition of "playing well", so it has to live in the repo.** Candle Gift picks
`par` - the number the star rating and the end-of-run gauge are both drawn from - by running four
scripted policies over a level and choosing the value that separates them. One pass measured with
an ad-hoc policy typed into the browser console, whose lookahead was a few units longer than the
one committed in `e2e`; it scored 64,606 where the committed bot scores 39,134, and par went in
44% too high. Nobody could have caught that by reading the number. **Measure balance with the bot
anybody can re-run, name it in the comment beside the constant, and pin the ratings it produces in
a test** - otherwise the constant is not measured, it is remembered.

## When a bot loses to a dumber bot, and when that is the finding

**If the policy that reads the level loses to the policy that ignores it, the bot is wrong
before the game is.** Wrecking Crew's first aiming bot steered straight at the kerb it wanted
to hit, and scored BELOW a bot that ignored the street entirely and weaved rail to rail on the
pendulum's period. The instinct is to read that as "the game does not reward aiming" and go
tune the game. It meant the bot had not been taught the technique the mechanic requires -
here, that driving at the target throws the tool the other way. Teaching it took street one
from 120 to 492 with no change to the game at all.

So: **a bot that loses to a dumber bot is a bug report about the bot.** Fix it before
touching a single constant, or a whole balance pass gets built on a measurement of the wrong
thing.

**A bot that only optimises will die, and a mean taken over dead runs measures how long the
game lets you live rather than how well the mechanic works.** The same bot finished six streets
out of six with no lives left, so every reading was of a game nobody had played to the end.
Give the scripted player the survival job as well and let survival win where they disagree,
which is also how a person plays.

**When two policies score the same, that IS the finding - do not go looking for a third
explanation first.** The instinct on seeing a reading bot lose to a blind one is to blame the
bot, which was right once on this game and wrong the next time. What separated the two cases
was cheap: sweeping the bot's one free parameter across eleven values took a minute and showed
no setting anywhere beat the blind policy, which rules the bot out and points at the design.
**Sweep the bot's parameter before touching the game's.**

**Make every scripted policy fail for a DIFFERENT reason, and you have a design you can
read.** Wrecking Crew's four: one touches nothing and scores zero; one swings blindly and
cannot reach the outer bays; one works the bays from one end and topples; one works them in
a balanced order and sweeps. Four rows, four distinct failures, and the table is a
description of what the game rewards. When two policies fail the same way - or worse, score
the same - one of them is not testing anything, and on the earlier build of this game that
was the signal that the whole genre was wrong.

**The pair that proves a decision exists must differ in exactly ONE thing.** The balanced and
the reckless policies here share all their code and take the same argument; the only
difference is which bay they pick next. Same control, same effort, same building on the
ground - 2.2x the score. That is a claim about the design that cannot be confounded by the
bots being differently good at driving.

**A test helper that plays the game is a second, worse player.** Eight tests failed here for
a reason unrelated to anything they asserted, because the helper driving the tool had its own
sweep and was quietly worse at connecting than the committed policy - so tests meant to check
"does a column take its hit points to break" were really checking "can this particular sweep
connect at all". Export the policy's own routine and have the tests drive through it. One
definition of how the game is played, used by the bots and the tests alike.
