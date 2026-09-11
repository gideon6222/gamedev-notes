# A new core verb invalidates every number tuned around the old one, and the aggregate hides it

**Game:** Gravewell. Replaced a per-block drill with a continuous plow, shipped it, and his
reply was: *"it looks like that broke something. the ship just drives directly through now
without slowing down."*

Three faults, plus a fourth he photographed. **Every one of them was in the first forty
metres, and every one was invisible in the aggregate measurement.**

The balance probe reported a healthy 1.55 m/s mean over a 200 m descent and I shipped on it.
That mean averages five depth bands of a descent **he has never once completed**. Ten seconds
of the stretch he actually plays looked like this:

```
  t= 1 s  depth  1.85 m  this second 1.85 m/s  load 0.00
  t= 2 s  depth  4.95 m  this second 3.10 m/s  load 0.00
  ...
  t=10 s  depth 29.75 m  this second 3.10 m/s  load 0.00
materials in the first 40 m: { ROCK: 312, IRON: 42, COBALT: 6 }
hardness the drill sees for each: 1.00, 1.00, 1.00
```

## The three faults, and what each teaches

**There was nothing to be slowed by.** Hardness came from the DEPTH BAND alone, so every
material in a band cut identically and "slowed down on denser materials" could not happen.
Fix: derive hardness from the material's WEIGHT, which was already in the table as `kg`. The
number the player reads in the hold is then the number that slowed them getting it, and the
two cannot drift. **When a request names a property the player should feel, check that the
property is a VARIABLE in the data before tuning anything.**

**The effect channels were switched off in exactly the range he plays.** `dig_load` mapped the
softest band to 0, and the softest band IS the first forty metres, so the drill loop, the
rumble, the tremor and the grit were all silent for the whole opening. Half of "it just drives
through" was silence, not speed. **A 0..1 feel parameter normalised across a content table
reads zero at the bottom of that table, which is where every player starts.** Give it a floor.

**The pace was set from the mean.** 3.10 m/s against 7.00 m/s flying is not digging.

## And the fourth: the new verb broke a system two files away

The plow leaves the hull embedded in material it is still cutting - that is the mechanic. The
light solver's spill took light only from OPEN neighbours, so a lamp inside rock had no lit
neighbour anywhere, every face returned zero, and **the light went out exactly while the
player was digging**, which is now most of the time. He sent a screenshot of a ship in total
blackness with the power at 87%.

The flood already gave the lamp's own cell a value of 1 by construction. The spill was the one
place refusing to read it. **When a verb changes which STATES the player spends time in, grep
for every system whose rules were written assuming the old distribution of states.**

## The rule

**Measure the stretch the player actually reaches, not the whole content.** A probe that
averages a full run is measuring a run nobody has had. Print the first ten seconds, per
second, with the derived feel parameters beside the numbers - it is twenty lines of probe and
it would have caught all four of these before the build went out.
