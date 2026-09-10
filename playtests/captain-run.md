# Playtests — Captain Run

Gideon's words, dated, verbatim. **Append only.** New entries go at the end under a `## YYYY-MM-DD` heading. Interpretation and lessons go in the topic files, not here.

---

Live at https://gideon6222.github.io/Captain_Run/

A viking crowd-runner. Drag to steer the warband up a mountain road; crates and draugr burst
into gold, iron and runes; iron fills a forge bar that upgrades the axe mid-run; each ascent
ends at a jotunn that is a pure DPS check, then a camp to spend gold.

## 2026-09-07 — how it was asked for

He sent a screenshot of a commercial viking runner: "can you make a phone game like this with
a similar level of graphics? are there tools or resources that you could be using that would
help?" and said the repo already existed.

The honest answer about tools: the good CC0 libraries — Kenney, Quaternius, Poly Pizza,
KayKit — all ship glTF/GLB, and the GitHub connector cannot push binary, so on the five-file
stack those assets are unreachable until a game earns a build step the way Coreward did.
Everything in the screenshot turned out to be reachable procedurally regardless: toon
shading, hard outlines, chunky silhouettes, and a great deal of loot in the air.

## 2026-09-07 — first build, NOT YET PLAYED

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

## 2026-09-07 - Captain Run becomes Wick, at his request

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
