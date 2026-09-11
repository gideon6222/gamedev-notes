# Playtests — Gravewell

Gideon's words, dated, verbatim. **Append only.** New entries go at the end under a `## YYYY-MM-DD` heading. Interpretation and lessons go in the topic files, not here.

---

`C:\dev\gravewell`, repo gideon6222/gravewell. Godot 4.7.2, native Android, portrait.

Successor to Coreward. Dig to the core of a dead planet, mine on the way, get out before the
hole closes. Credits are mined and buy the ladder; filament is only ever found and buys every
counter to a threat. Seven planets, each a different RULE rather than a different palette.

## 2026-09-10 — first look at the lighting

"the light seems to be coming from the back of the ship in a small beam. I would like you to
do something similar to coreward, where forward light creates a dispersed beam, but also fills
the rest of the tunnel behind. as you pass corners, it should create shadows. the air should
start looking thick in the tunnels. there should he a secondary light source that shows on the
face of the rocks when the ship is near them."

A restatement from scratch, not a tuning note: five separate mechanisms named in one sentence.

## 2026-09-10 — after the first lighting rework (0.9.1)

"Instead of thick air, this looks more similar to a beam coming from the ship. Can you make it
so that the there is a soft dispersed light throughout the whole tunnel and the beam coming
from the ship looks like it's headlights cutting through the thick air? In front of the ship
should be brighter than behind and branching paths should cast shadows as you pass them."

Second restatement of the same system. The forward/behind ratio and the corner shadows he
repeated unchanged, so those were right; what he is naming as new is light present in the
WHOLE tunnel rather than only near the ship, and a beam that reads as scattering rather than
as a solid ribbon.

## 2026-09-10 — first phone session on 0.9.2, four screenshots

"there appears to be multiple separate beams when using the light on certain settings rather
than a glow that extends from the front of the ship. the face of the rock looks decent as far
as how the soft light shows. the light also appears to get caught on the edges of tunnels that
I have made because they have random edges that stick out. digging feels very rigid and chunky.
while I am digging, it takes large chunks out, slows me down, then speeds up. I would rather
dig at a more consistent speed, and feel like it is consistently digging through dense mud or
dirt. instead of taking longer to destroy a chunk I would like it to continously plow through
but get slowed down on denser materials, and the particles or effects will sell that somwthing
is taking a lot more work, or easy fluffy dirt. can you expand on all of thos, create a plan,
research, then implement it into your current plan? can you also add a pause button?"

Screenshots at 81 m (lamp at 11% power), 7 m, 2 m and 5 m (flying left). The starburst of
separate hard-edged rays is clearest in the 5 m and 2 m frames. **The rock face lighting he
explicitly approved: "looks decent". Do not change it.**

First time he has named the DIGGING itself rather than the picture.

## 2026-09-11 — on 0.10.0, the plow

"it looks like that broke something. the ship just drives directly through now without slowing
down."

Three screenshots at 21 m, 18 m and 11 m. The 18 m one is a ship in total blackness with the
power at 87% and no lamp pool at all. He is describing three separate faults at once and all
three are in the first forty metres, which is the only stretch he has ever played: a flat
3.10 m/s with no variation, `dig_load` reading 0.00 so every effect channel was silent, and
the spill unable to light a lamp buried in the rock it was cutting.
