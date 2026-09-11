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
