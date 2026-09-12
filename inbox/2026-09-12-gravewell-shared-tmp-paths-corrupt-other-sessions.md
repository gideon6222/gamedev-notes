# A temporary file outside the repo must use the session scratchpad, because a fixed path like `/tmp/s.keep` is shared mutable state between the sessions running side by side on this PC

**Game:** gravewell  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Toolchain, and where it lives

## What happened
A background loop verifying regression tests backed each source file up before
reintroducing a fault, using `/tmp/s.keep` and three siblings as the backup paths. A
stillwater session was running at the same time and had picked the same obvious short
names for the same obvious reason. Its `sim.gd` was restored over gravewell's, and the
file came back holding `HOLDING`, `tension`, `reeling` and `TENSION_MAX`, none of which
are words in gravewell. Nothing failed loudly: the suite simply would not compile, and
the cause was found by grepping the file for the other game's vocabulary. Recovery was
`git checkout -- src/sim/sim.gd`, which was clean only because the work happened to be
committed, and the uncommitted milestone on top of it was lost and had to be written
again.

## The rule
Every temporary file goes in the session scratchpad, whose path is unique per session, and
never in `/tmp` or any other fixed path outside the repo. This is not only about backups:
any agreed-looking short name outside the repo is a collision waiting for the second
session, and the collision presents as one game's source appearing inside another.

## Replaces or contradicts
nothing
