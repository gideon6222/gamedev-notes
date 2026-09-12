# When you replace an objective, delete the old one in the same round

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / The loop and stakes

## What happened

A game about a chain of planets became a game about one planet. The new ending
- a vault at the centre, behind nine objectives spread across the world - was
built in one milestone. The old ending was a navigation chart, a jump drive
built from five components, a nine-second crossing between worlds, a ninety-
second escape sequence, and a breakable planet core.

The temptation was to ship the new ending and leave the old one dormant: the
core row is deep, the chart only opens after you break it, nobody would see it.

**That is worse than either ending on its own.** Two objectives means the
player is collecting jump-drive components that now do nothing, and the next
session has to reason about which ending is real.

## What it cost, measured

About **1,300 lines and ninety call sites** across nineteen files. Roughly two
hours with the typechecker doing the finding. Three things worth knowing before
starting one of these:

**A derived stat quietly changes.** `drill()` was
`(1 + level * 0.95) * (1 + shards * 0.08) * relic`, and `shards` came from
destroying planets. With nothing to destroy it is one term shorter. The
re-recorded golden matched the old `shards == 0` row exactly - which is what
every fresh save always had - and that is the check that makes the removal
safe rather than a silent rebalance.

**A file can be two features wearing one name.** `transit.ts` was half the
crossing and half the title screen's ship showcase. Deleting the file took the
title screen with it. Cut the feature out and leave a comment at the seam
saying what used to be there.

**A frozen baseline keeps the dead ids forever.** The golden test's list of
"things allowed to overwrite a cell" still has to name the deleted content,
because the frozen snapshot still contains it and *an overwriter leaving a cell
is as legal as one arriving*. Removing the id reads every one of those cells as
"the world generator changed".

## The rule
When a new objective ships, the old one is a stand-in: the round is not done until it is
deleted. Two objectives in one game is worse than either, because the player collects things
that no longer do anything and the next session cannot tell which ending is real. Budget it -
Coreward's was 1,300 lines and ninety call sites - and expect a derived stat to change, a
file to turn out to be two features under one name, and the frozen golden to need the dead
ids kept in its allow-list for ever.

## Replaces or contradicts
Widens INDEX.md standing rule 12: "**Delete the stand-in in the same commit as the real
thing.**" That reads as being about scaffolding and placeholder art; it applies to DESIGN
just as hard, and a replaced objective is the most expensive stand-in there is.
