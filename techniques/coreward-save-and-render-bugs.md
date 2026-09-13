# Coreward: a derived index gone stale, two constants that disagree, and destruction that reads wrong

**Game:** Coreward · **Status:** each item a shipped fault, now guarded · **Read when:** a `Set`
or index mirrors saved data; two pieces of code each decide when something is destroyed; a
render loop takes "the best of N" over near-identical candidates; picking a destruction tick size
for a dig/mine mechanic.

---

## A derived index lives in the module that OWNS the data

A `Set` mirroring a saved list is a second source of truth: `load()` replaces the list wholesale,
an index built elsewhere never hears about it, and after a reload every new entry looked
already-seen so nothing was ever written again. Export a `mark()` that writes both the list and
the index, and a `reset()` that rebuilds the index, called from every path that replaces the list
- load, wipe, new game.

**When adding a field to a save, grep the RESET path, not just the load path.** The same sweep
that found this bug found a "wipe everything" routine that had never wiped three discovery lists.

## One threshold for "gone", named once

Two pieces of code each decided when a thing was destroyed and disagreed eventually, in a band
neither could see on its own: passability was checked at `<= 1e-4` while a drill actually broke a
cell at exactly `0.0`, leaving cells flyable, unbroken, and still reporting their ore forever.
This is the second time the same shape has bitten this one file. **Name one threshold for "gone,"
and have everything else read that constant** rather than deriving its own nearby value.

## "Take the best of N" over uniform data hides a dependence on iteration order

When candidates in a render or selection loop are frequently near-identical, "take the best of N"
silently becomes "take whichever one happened to be checked last" - a hidden dependence that
surfaces the first time the geometry that was hiding it changes. Weight-average instead of taking
a single winner, and make the case that must win outright an explicit override rather than a
tie-break inside the same comparison.

## Destruction granularity has to match the rendering style, and the ratio is the number

Character width against cell width is the number that decides whether destructible terrain reads
as chunky or smooth: ~18:1 for Worms, ~32:1 for Noita (continuous), ~1:1 for SteamWorld Dig, ~0.5:1
for Terraria (blocky on purpose). Gravewell shipped at 0.76:1, which drew smooth contours - it
promised Worms and delivered Dig Dug. A finer simulation TICK cannot fix this; the limit is
spatial, in how big one destroyed unit is relative to the character standing in it.
