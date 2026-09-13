# In a run-based game with a hub, save only at the hub so quitting mid-run costs exactly what dying costs, and both save-scumming abuses disappear with one rule instead of two defences.

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / Stakes (the section on risk and reward that says doing nothing must lose and the greedy option must be near the edge)

## What happened
Coreward (a dive-dig-return-sell phone game with a hub pad and runs of about three minutes) saved its full live state every five seconds and on tab hide, wherever the ship was, and CONTINUE restored the exact mid-run position. That created two abuses the design had to defend against separately: quitting mid-run deep with a full hold and reloading was a free ride home (the notes had a whole paragraph on not letting the settle move a mid-run ship to the surface for that reason), and quitting just before a death avoided the death penalty. Gideon asked for "a quick save to be done at the launch pad so that if someone exits out of the game, they start back at the launch pad, don't lose too much progress, but can't abuse the system." The fix was a checkpoint at the hub: `save()` writes only while the ship is on the pad in play, through a pure `snapshot()` that returns null otherwise, so a run in progress is simply never on disk. That made quitting mid-run cost exactly what dying costs in that game (the hold and the run) and nothing else, which closes both abuses with one rule and no special cases; it also deleted the whole mid-run CONTINUE path (a camera drop to the ship behind a dip to black), because no mid-run save can exist. Old mid-run saves are landed on load with the hold dropped, not kept and not sold. Cost: at most one run of progress; the one edge is a milestone (an Anchor lit) reached on the abandoned run, noted as a place for a second checkpoint if it stings.

## The rule
In a run-based game with a hub, save only at the hub so that quitting mid-run costs exactly what dying costs, and both save-scumming abuses (the free ride home, quitting out of a death) disappear with one rule instead of two defences; if a milestone can be reached mid-run, add a checkpoint at the milestone rather than saving everywhere.

## Replaces or contradicts
nothing
