# Playtests — Candle Gift

Gideon's words, dated, verbatim. **Append only.** New entries go at the end under a `## YYYY-MM-DD` heading. Interpretation and lessons go in the topic files, not here.

---

## 2026-09-07 - the actual game, found

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

## 2026-09-07 - Candle Gift, first build, NOT YET PLAYED

**Verified** by driving the frame loop and screenshotting: the trailing tray lagging through
a turn, obstacles clipping the tail of a tray the leader already cleared, all four station
kinds firing, both halves of a gantry doing different things, gates growing the tray to its
cap, banknotes and guarded banknote lines, the gift table lighting each candle in turn,
star ratings spreading 1/2/2/3 across four scripted play styles, and 45-65 draw calls.

**Not verified at all**: how it feels. Ask, in this order - does a full tray feel satisfying
or sluggish; is the steering sensitivity right now the runway is wider; does the results
screen land; and does the music annoy him. The last one because the Coreward score drew the
only outright "I don't like" of that game.

## 2026-09-07 - first real report on Candle Gift, and it was a blocker

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

## 2026-09-07 - "still pretty far off", and he was right

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

## 2026-09-10 - upgrade every aspect, against the original intent

"take stock of the candle-gift game and bring it up to the new framework. Specifically the
Godot version. If you see a web based version, that is the old one. Look through the initial
plan and what I was trying to do, then expand on everything and upgrade every aspect of the
game and try achieve what I was requesting initially, rather than just modifying things that
are having issues with the game currently."

The instruction worth keeping is the last clause. **He is asking for the original intent to be
met, not for the current defect list to be worked.** The defect list is what the last three
sessions did - crash, steering, blocks, pour, music - and each of those was a reaction to a
build he had just played. This is the opposite direction: go back to what he asked for on
2026-09-07 ("an upgraded version with similar art style and better graphics", "better than the
one she remembers") and close the distance to THAT.

So the unit of work is the gap between the game and the intent, which lives in `REFERENCE.md`
under "Still open" and in `POLISH.md`, not in the last bug report.
