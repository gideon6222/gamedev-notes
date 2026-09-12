# Measuring a design, a par and an economy with scripted play

**Game:** Candle Gift (web / three.js, then rewritten on Godot) · **Status:** shipped and played; every balance constant below was set this way · **Read when:** setting par, star thresholds or any balance constant; a mechanic you suspect is scenery; two play styles that score the same; pricing a shop ladder; a total that might be contaminated by state it should not see

Split out of `candle-gift-reference-runner.md` on 2026-09-12, which had been over the 30 KB
limit since before the digest and carried a note naming this as one of the two write-ups to
lift out of it. This is the calibration half: what scripted policies measured about Candle
Gift's design, how `par` and the star thresholds were cut against the spread those policies
produced, and what adding a shop revealed about an economy that had been wrong for a long time
without looking wrong. Read it beside `human-bot-policies.md`, which is about building the bots
themselves - human reaction, a misread one time in six, a thumb with spread - where this file
is about what to do with their numbers. The rest of the game is in
`candle-gift-reference-runner.md`; the research method is in `candle-gift-copying-a-reference.md`.

**Generalisable takeaways**

- **If a system applies itself to everything you own, it is not a mechanic.** Four scripted play
  styles, from never touching the screen to playing well, produced an identical per-candle value
  while the stations spanned the whole runway. **Measure a mechanic across a bad run and a good
  run: if the number does not move, the mechanic is scenery** - and when every play style scores
  the same, fix the game, not the thresholds.
- **Calibrate with the bot anybody can re-run, over several seeds, and name it beside the
  constant.** A single level is layout luck: the same policies swing 25% level to level, and an
  ad-hoc console bot with a slightly longer lookahead scored 64,606 where the committed one
  scores 39,134, putting par in 44% too high. Measure the spread first, then place the thresholds
  inside it.
- **Test invariance, not values, wherever a quantity might be contaminated.** "The bank went up
  by what the reward screen said" is TRUE with the bug present, because both sides inflate
  together; only playing the same level twice from different starting conditions and demanding
  the same answer separates them. And simulate a progression by playing it - dividing a late
  price by early income measures a player who never got better.

---

## Measuring the design with scripted play

**If a system applies itself, the player is not playing it.** Candle Gift's stations first
spanned the whole runway, so every tray got every treatment just by reaching the end - and
four scripted play styles, from never touching the screen to playing well, produced an
*identical* per-candle value. Everything downstream still worked; there was simply no input
in it. Splitting each station into two halves across the track, one effect each, turned a
fixed consequence into a chain of decisions. **Measure a mechanic across a bad run and a good
run: if the number does not move, the mechanic is scenery.**

Measure the spread before setting the thresholds (from `archive/PIPELINE-2026-09-09.md`):

- **Measure the spread before setting the thresholds, not after.** Star ratings and grades
  are cut against a par, and the *gaps* between them have to match the real distance between
  bad and good play. Candle Gift's first thresholds were bunched inside a 1.5x band while the
  measured spread across four scripted play styles was 1.3x, so every one of them scored full
  marks - including the run that never touched the screen. Script the extremes first, read
  the ratio, then place the thresholds inside it.
- **When every play style scores the same, fix the game, not the thresholds.** That flat
  spread was the real finding: it meant the systems were applying themselves. Re-tuning par
  would have hidden it.

**Calibrate against several procedural levels, never one.** Candle Gift's four scripted
policies swing 25% from level to level on layout luck alone - its "dodge hazards only" bot
scores 18,158 on level one and 1,350 on level five, where dodging is worse than doing
nothing. A `par` set from level one put the best policy on three stars there and two
everywhere else, and nothing about that was visible from the level-one numbers, which looked
clean and well separated. Take the mean over five or six seeds, and keep the single-level
numbers as a regression test that says in its own comment that it is not the calibration.

**Removing an obstacle kind means removing its share of the danger, not redistributing it.**
Deleting Candle Gift's saw and backfilling its spawn slot with a third barrier kept the
runway exactly as busy and cost the weaving bot a fifth of its score - with the same number
of candles lost. The damage was not to what the player *had*, it was to what they had *time
to do*: in a game whose skill lives in a second system, every second spent dodging is a
second not spent weaving. **When two systems compete for the same seconds, measure the one
you care about after changing the other.**

**A bot is a definition of "playing well", so it has to live in the repo.** Candle Gift picks
`par` - the number the star rating and the end-of-run gauge are both drawn from - by running four
scripted policies over a level and choosing the value that separates them. One pass measured with
an ad-hoc policy typed into the browser console, whose lookahead was a few units longer than the
one committed in `e2e`; it scored 64,606 where the committed bot scores 39,134, and par went in
44% too high. Nobody could have caught that by reading the number. **Measure balance with the bot
anybody can re-run, name it in the comment beside the constant, and pin the ratings it produces in
a test** - otherwise the constant is not measured, it is remembered.

**Restarting the run is not restarting the game.** Candle Gift's `freeze()` restarts the level in
place but leaves `S.level` alone, and every layout decision is keyed on `hash(chunk, salt + level)`
- so the headline test, comparing a weaving policy against a gathering one back to back, was
comparing two *completely different runways*. Not "one slightly harder": level 2 happens to be a
bad draw, where the same bot brings home 14 candles instead of 29. Any A/B over a procedural world
has to reset the seed inputs, not just the position. **Ask what the seed is keyed on, and check
your reset touches all of it.**

## The economy: build the meta-game and find out what it does

A runner's economy can be wrong for a long time without looking wrong, because nothing in a
single run compares two numbers that ought to agree. Adding a shop is the first thing that
does: a price sits next to an income, and a price list that is trivially affordable is a
question mark over the income rather than over the prices.

Two bugs and one structural fault came out of asking "is this ladder priced sensibly", none of
which any test or screenshot had noticed:

**The bank was being counted as run earnings and paid back into itself.** The end-of-run
appraisal added the player's cash, and the player's cash had been seeded from the save. So a
run was appraised as (what you earned + what you already had), and that total was banked. A
balance of 5,000 became 141,699 in three runs of the same level.

**The obvious assertion cannot catch that, and it is worth understanding why.** "The bank went
up by the amount the reward screen said" is TRUE with the bug present, because both sides
inflate together: the screen says R + bank and the bank rises by R + bank. Any test written
from inside one run agrees with itself. The only shape that separates them is **playing the
same level twice with different starting conditions and demanding the same answer** - an
invariance test rather than a value test. Reach for one whenever a quantity might be
contaminated by state it should not see.

**And the value curve was hyperinflationary.** A run was worth 1.55x more per level - eighty
times over ten levels - so no fixed price list could mean anything. Even after repricing, the
whole ladder was bought out by level nine. The fix was upstream, in the curve, not in the
prices.

### Measure a progression by PLAYING it, not by dividing

The first version of the ladder table divided each price by the mean run value over the first
six levels and reported that the last shop took 75 runs. That number is meaningless: income
scales with the level, so a player who has reached the seventh rung earns many times the mean
of the first six. **Dividing a late price by early income measures a player who never got
better.**

Simulate the actual loop instead - play, bank, buy what is affordable, next level - and report
the level at which each thing is reached. That is the number the player experiences, and it is
the only one worth tuning against.

### Keep the money in the units of the game you are copying

Ours paid about 18,000 for a run where the reference paid about 540 - thirty-four times out.
That sounds cosmetic and is not. The only two prices ever observed in the reference were
$1,000 and $4,000, and against an 18,000 run those are not prices at all: the single most
useful piece of external calibration available was unusable until the units matched. It also
meant a money pill reading "148K" where the reference reads "540".

One constant, applied at one point, so everything downstream moves together and every number
stays comparable to the footage.
