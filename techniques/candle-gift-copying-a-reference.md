# Copying a reference game: read it for the verbs

**Game:** Candle Gift (web / three.js, then rewritten on Godot) · **Status:** shipped and played; the reproduction landed on the third build, from two screenshots, one strategy-guide sentence and a four-minute video · **Read when:** rebuilding an existing game from screenshots and video; a reproduction that keeps getting closer and still does not look like the thing; deciding what research to write down before writing code

Split out of `candle-gift-reference-runner.md` on 2026-09-12, which had been over the 30 KB
limit since before the digest and carried a note naming this as one of the two write-ups to
lift out of it. This is the research method: how to find what a reference game actually is,
from sources that are not the game. Two builds of Candle Gift were made from a verbal
description and were "still pretty far off"; the third was built from a strategy guide read for
its verbs, the longest walkthrough video anyone had posted, and store screenshots magnified 4x
before anything was modelled from them - and that method, not the code, is the reusable part.
The rest of the game (the tray and the pools, stations, hazards, the end-of-run screen, the
pixel checks, the rewrite) is in `candle-gift-reference-runner.md`, and the calibration half is
in `candle-gift-measuring-the-design.md`.

**Generalisable takeaways**

- **Read the guide for the verbs, not the nouns.** A store page lists what is in a game; a
  strategy guide describes what the player is *doing*, and that is the thing being rebuilt. One
  sentence about swiping between two pools of wax was sitting in the guide from the first
  session and is what the whole third build rests on.
- **Research is the asset, so write it as its own file.** The longest playthrough video shows the
  screens a store page never does - including the ones the reference does *not* have, which is
  the hardest observation to make and the most valuable. Absence is invisible to you precisely
  because you built the extra screen on purpose.
- **Crop the reference at 4x before modelling from it.** Details 40 pixels wide in the source are
  the entire difference between "similar" and "the same game"; three passes built from
  page-sized screenshots all came out as generic shapes. The crop is the research step, not the
  glance.

---

## Read the reference for the verbs

The line that turned the third build (from `archive/PLAYTESTS-2026-09-09.md`, 2026-09-07):

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

**The most useful single sentence was in a strategy guide, not a store page:** "as your
candle stack gets longer, you need to be aware of everything happening in front of you, and
sometimes you need to start moving well before an obstacle is in reach". That is the trailing
stack, and it is what the whole rebuild is now built on. Store descriptions say what a game
contains; strategy guides say how it *feels* to play.

## Reference research: videos, absence, HUD, magnification

**A long-play video is worth ten store screenshots.** Candle Gift's eight official
screenshots show the runway and almost none of the UI, and four rebuilds off them got the
world closer and closer while every *screen* stayed wrong. One four-minute "levels 1-6"
walkthrough showed the home screen, the end-of-run ruler and the reward screen in one pass -
and showed that the reference has **no upgrade screen at all**, which no amount of staring at
screenshots would ever have revealed. **Search for the longest playthrough, not the prettiest
capture**, and note that these disappear: one of the three found for this game was already
gone a day later.

**Absence is the hardest thing to observe, and the most valuable.** The finding that moved
this game most was not a feature to add, it was a screen that was not there: no stat-upgrade
list anywhere in six levels. Our version opened one after every level. When comparing against
a reference, list what it does *not* have as deliberately as what it does - a screen you
invented is invisible to you precisely because you built it on purpose.

**A HUD is a claim about what the player should be thinking about.** The reference shows
three things: settings, level, money. This build had grown a candle counter, a live value, a
colour-chip readout and a progress bar - each individually justifiable, and together the main
reason a screenshot of it did not look like a screenshot of the thing it was copying. Adding
a readout is the cheapest change in a game and the easiest to keep adding.

**Magnify the reference before you model from it.** Three passes at Candle Gift's obstacles
were built from store screenshots viewed at page size, and all three came out as generic
shapes - a red box, beads on a string. Cropping the same images into a canvas at 4x with
`imageSmoothingEnabled = false` showed a rimmed panel with a recessed face, interlocking
diamonds on a shaft anchored to a post *outside* the rail, and a navy arrowhead that says
which way the moving one is going. Those details are 40 pixels wide in the source and they
are the entire difference between "similar" and "the same game". **If you are modelling from
an image, the crop is the research step, not the glance.**
